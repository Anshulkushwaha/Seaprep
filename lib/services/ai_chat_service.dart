import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/question.dart';
import 'storage_helper.dart';

class AiChatService extends ChangeNotifier {
  static final AiChatService instance = AiChatService._internal();
  AiChatService._internal() {
    _loadMessagesFromStorage();
  }

  static const String _storageKey = 'maritime_ai_chat_history_v1';
  static const String _defaultApiKey = '';

  final List<ChatMessageModel> _messages = [];

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  /// Loads chat history from session storage
  void _loadMessagesFromStorage() {
    try {
      final raw = StorageHelper.getItem(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _messages.clear();
        _messages.addAll(
            decoded.map((item) => ChatMessageModel.fromJson(Map<String, dynamic>.from(item))));
      }
    } catch (e) {
      debugPrint('Error loading chat history from storage: $e');
    }

    if (_messages.isEmpty) {
      _messages.add(
        ChatMessageModel(
          id: 'welcome_1',
          text:
              'Ahoy Cadet! ⚓ I am your **SeaPrep AI Assistant**.\n\nAsk me anything about Maritime Engineering, COLREGs, SOLAS/MARPOL Regulations, Shipboard Machinery, or Shipping Company Interviews!',
          sender: ChatSender.ai,
          timestamp: DateTime.now(),
        ),
      );
      _saveMessagesToStorage();
    }
  }

  void _saveMessagesToStorage() {
    try {
      final encoded = jsonEncode(_messages.map((m) => m.toJson()).toList());
      StorageHelper.setItem(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving chat history to storage: $e');
    }
  }

  /// Clears chat history for current session
  void clearHistory() {
    _messages.clear();
    _messages.add(
      ChatMessageModel(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        text:
            'Chat history cleared! ⚓ Ask me any maritime or technical question.',
        sender: ChatSender.ai,
        timestamp: DateTime.now(),
      ),
    );
    _saveMessagesToStorage();
    notifyListeners();
  }

  /// Sends a user message and streams AI response chunk by chunk
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isGenerating) return;

    // 1. Add user message
    final userMsg = ChatMessageModel(
      id: 'msg_u_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);

    // 2. Add placeholder streaming AI message
    final aiMsgId = 'msg_ai_${DateTime.now().millisecondsSinceEpoch}';
    final aiMsg = ChatMessageModel(
      id: aiMsgId,
      text: '...',
      sender: ChatSender.ai,
      timestamp: DateTime.now(),
      isStreaming: true,
    );
    _messages.add(aiMsg);
    _isGenerating = true;
    _saveMessagesToStorage();
    notifyListeners();

    // 3. Generate SSE response stream
    final responseBuffer = StringBuffer();

    try {
      final stream = _generateAiResponseStream(trimmed);
      await for (final chunk in stream) {
        responseBuffer.write(chunk);

        final idx = _messages.indexWhere((m) => m.id == aiMsgId);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(
            text: responseBuffer.toString(),
            isStreaming: true,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('AI Chat response error: $e');
    } finally {
      _isGenerating = false;
      final idx = _messages.indexWhere((m) => m.id == aiMsgId);
      if (idx != -1) {
        _messages[idx] = _messages[idx].copyWith(
          text: responseBuffer.isEmpty
              ? _generateFallbackAnswer(trimmed)
              : responseBuffer.toString(),
          isStreaming: false,
        );
      }
      _saveMessagesToStorage();
      notifyListeners();
    }
  }

  /// Real-time SSE response stream (gemini-1.5-flash with fallback to local expert Maritime engine)
  Stream<String> _generateAiResponseStream(String prompt) async* {
    const String envApiKey = String.fromEnvironment('GEMINI_API_KEY');
    final String apiKey = envApiKey.isNotEmpty ? envApiKey : _defaultApiKey;

    final modelsToTry = [
      'gemini-1.5-flash',
      'gemini-2.0-flash',
      'gemini-2.5-flash',
    ];

    bool success = false;

    if (apiKey.isNotEmpty) {
      for (final modelName in modelsToTry) {
        try {
          final uri = Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/$modelName:streamGenerateContent?key=$apiKey');
          final request = http.Request('POST', uri);
          request.headers['Content-Type'] = 'application/json';
          request.body = jsonEncode({
            'system_instruction': {
              'parts': [
                {
                  'text':
                      'You are an expert Chief Engineer and Senior Master Mariner providing technical interview prep answers for Merchant Navy cadets. Structure responses clearly with headings, bullet points, operating procedures, and safety rules.'
                }
              ]
            },
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'maxOutputTokens': 800,
              'temperature': 0.3
            }
          });

          final client = http.Client();
          final response = await client.send(request);

          if (response.statusCode == 200) {
            final stream = response.stream
                .transform(utf8.decoder)
                .transform(const LineSplitter());

            await for (final line in stream) {
              final trimmedLine = line.trim();
              if (trimmedLine.isEmpty) continue;

              String jsonStr = trimmedLine;
              if (jsonStr.startsWith('data: ')) {
                jsonStr = jsonStr.substring(6).trim();
              }
              if (jsonStr.startsWith('[')) jsonStr = jsonStr.substring(1);
              if (jsonStr.endsWith('],') || jsonStr.endsWith(']')) {
                jsonStr = jsonStr.substring(0, jsonStr.length - 1);
              }
              if (jsonStr.endsWith(',')) {
                jsonStr = jsonStr.substring(0, jsonStr.length - 1);
              }

              if (jsonStr.startsWith('{')) {
                try {
                  final data = jsonDecode(jsonStr);
                  final candidates = data['candidates'] as List<dynamic>?;
                  if (candidates != null && candidates.isNotEmpty) {
                    final parts =
                        candidates[0]['content']['parts'] as List<dynamic>?;
                    if (parts != null && parts.isNotEmpty) {
                      final textChunk = parts[0]['text'] as String?;
                      if (textChunk != null && textChunk.isNotEmpty) {
                        yield textChunk;
                        success = true;
                      }
                    }
                  }
                } catch (_) {}
              }
            }
            if (success) return;
          }
        } catch (e) {
          debugPrint('Error with streaming model $modelName: $e');
        }
      }
    }

    // Stream from local expert Maritime knowledge engine
    final answerText = _generateFallbackAnswer(prompt);
    final words = answerText.split(' ');
    for (int i = 0; i < words.length; i += 3) {
      final end = (i + 3 < words.length) ? i + 3 : words.length;
      final chunk = '${words.sublist(i, end).join(' ')} ';
      yield chunk;
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  /// Expert Maritime Technical Knowledge Engine
  String _generateFallbackAnswer(String query) {
    final lower = query.trim().toLowerCase();

    if (lower == 'hi' || lower == 'hello' || lower == 'hey' || lower.startsWith('hi ') || lower.startsWith('hello ')) {
      return '⚓ **Hello Cadet!**\n\nI am your SeaPrep AI Technical Assistant. Ask me any interview question on main engines, auxiliary machinery, COLREGs, SOLAS/MARPOL, or company oral exams!';
    }

    // Direct question bank matching
    for (final q in QuestionItem.allPDFQuestions) {
      if (lower.contains(q.question.toLowerCase()) ||
          q.question.toLowerCase().contains(lower)) {
        return '⚓ **Question:** ${q.question}\n\n**Category:** ${q.category}\n\n**Expert Technical Answer:**\n${q.answer}';
      }
    }

    // Gate Valve
    if (lower.contains('gate valve')) {
      return '''⚓ **Gate Valve (Linear Motion Isolation Valve)**

1. **Definition & Operating Principle:**
A gate valve is a linear-motion isolation valve designed to start or stop fluid flow. It operates by raising or lowering a wedge-shaped gate out of the flow path. It is designed for **fully open or fully closed** operation only (NOT for throttling).

2. **Shipboard Applications:**
- Heavy Fuel Oil (HFO) & Marine Gas Oil (MGO) storage tank suction lines.
- Main engine cooling water sea chest valves.
- Cargo oil manifold lines on crude oil & product tankers.
- Bilge and ballast main line isolation.

3. **Key Construction Features:**
- **Rising Stem:** Stem moves up as the gate opens, giving clear visual indication of valve position.
- **Non-Rising Stem:** Stem threads inside the wedge; ideal for compact engine room spaces.
- **Wedge Seats:** Precision metal-to-metal wedge seating to ensure leak-tight shutoff against viscous fluids.

4. **Operating Rules & Safety Precautions:**
- ⚠️ **Never Throttle:** Throttling causes severe fluid turbulence, chatter, and wire-drawing (seat erosion).
- 💡 **Back-seating:** When fully opened, back-seat the valve stem to isolate fluid pressure from the gland packing box.
- 🔧 **Maintenance:** Regularly inspect spindle threads, gland packing, and wedge seat faces during drydock or overhaul.''';
    }

    // Globe Valve
    if (lower.contains('globe valve')) {
      return '''⚓ **Globe Valve (Flow Control & Throttling Valve)**

1. **Operating Principle:**
A globe valve features a spherical body where flow moves up through a circular orifice. A movable disc or plug moves perpendicular to the seat to regulate or throttle flow rate.

2. **Shipboard Applications:**
- Main steam boiler stop valves & feed water regulation.
- Fuel oil burner supply lines.
- Compressed air main control valves.

3. **Advantages & Limitations:**
- ✅ **Pros:** Excellent throttling and flow regulation capability; easy seat re-facing.
- ❌ **Cons:** Higher pressure drop across the valve body compared to gate valves due to tortuous flow path.

4. **Interview Tip:** Always remember that fluid enters under the disc in standard globe valve installations so that stem packing is not pressurized when closed.''';
    }

    // Butterfly Valve
    if (lower.contains('butterfly valve')) {
      return '''⚓ **Butterfly Valve (Quarter-Turn Valve)**

1. **Operating Principle:**
A quarter-turn (90°) rotational motion valve where a circular disc rotates around a central shaft to open or seal the flow passage.

2. **Shipboard Applications:**
- Ballast water management system (BWMS) lines.
- Central fresh water cooling lines.
- Inert gas system (IGS) scrubber tower outlets.

3. **Key Features:**
- Compact, lightweight design with low torque operation.
- Resilient elastomer (EPDM/Nitrile) seating for quick shutoff.
- Gear-operated or hydraulic/pneumatic actuator control.''';
    }

    // Check / Non-Return Valve
    if (lower.contains('check valve') || lower.contains('non-return valve') || lower.contains('nrv')) {
      return '''⚓ **Non-Return Valve (NRV / Check Valve)**

1. **Operating Principle:**
Automatic valve that allows fluid flow in one direction only and automatically closes to prevent backflow (back-siphonage) when flow reverses.

2. **Shipboard Applications:**
- Boiler feed water pumps.
- Bilge suction lines (SDNRV - Screw Down Non-Return Valve).
- Air compressor discharge lines.

3. **SDNRV Feature:** A Screw Down Non-Return Valve can be screwed down to lock the valve shut, or backed off to function as an automatic check valve.''';
    }

    // Relief Valve / Safety Valve
    if (lower.contains('safety valve') || lower.contains('relief valve')) {
      return '''⚓ **Safety Valve & Relief Valve**

1. **Function:**
Over-pressure protection device designed to automatically discharge fluid/gas when system pressure exceeds set relief limits.

2. **Difference:**
- **Safety Valve:** Rapid pop-action full opening used for compressible gases/steam (e.g. Boiler Main Safety Valve).
- **Relief Valve:** Proportional opening relative to pressure increase used for non-compressible liquids (e.g. Fuel Oil Pump discharge relief valve).

3. **Safety Requirement:** Boiler safety valves must be tested using manual easing gear and set by Class Surveyors.''';
    }

    // OWS / Oily Water Separator
    if (lower.contains('ows') || lower.contains('oily water')) {
      return '''⚓ **Oily Water Separator (OWS) & 15 PPM Monitor**

1. **Operating Principle:**
Separates oil from bilge water using gravity separation (difference in density) and multi-stage coalescer filters before overboard discharge.

2. **SOLAS / MARPOL Annex I Requirement:**
- Overboard discharge oil concentration **MUST NOT exceed 15 PPM**.
- Equipped with an automatic stopping device (3-way solenoid valve) and 15 PPM Bilge Alarm Monitor.
- Operating position: Must be outside Special Areas, vessel en route, and recording all operations in Oil Record Book (ORB Part I).

3. **Safety Interlock:** If oil concentration reaches 15 PPM, the monitor triggers alarm and 3-way valve recirculates water back to bilge holding tank.''';
    }

    // Purifier / Clarifier
    if (lower.contains('purifier') || lower.contains('clarifier')) {
      return '''⚓ **Centrifugal Oil Purifier vs Clarifier**

1. **Purifier Mode:**
- Separates two immiscible liquids (water and oil) plus solid impurities.
- Uses a **Gravity Disc** (Dam Ring) to form a water seal interface.
- Requires water seal supply during start sequence.

2. **Clarifier Mode:**
- Separates fine solid impurities from oil.
- Uses a **Blind Disc** (no water outlet). No water seal required.

3. **Operating Parameters:**
- Feed Temperature: HFO heated to ~95°C - 98°C for optimal density difference.
- Throughput: Reduced flow rate increases separation efficiency.''';
    }

    // Blackout / Emergency Generator
    if (lower.contains('blackout') || lower.contains('emergency generator')) {
      return '''⚓ **Shipboard Blackout Recovery Procedure**

1. **Immediate Actions:**
- Confirm Emergency Generator starts automatically and connects to Emergency Switchboard within **45 seconds** (SOLAS rule).
- Verify navigation lights, steering gear, and emergency lighting are powered.

2. **Main Engine & Aux Engine Recovery:**
- Isolate fault on Main Switchboard (MSB).
- Start primary Auxiliary Engine manually or via auto-standby.
- Close main generator Air Circuit Breaker (ACB).
- Restart essential pumps: LT fresh water pump, lube oil pump, fuel supply pump.
- Reset main engine safety trips and resume propulsion safely.''';
    }

    // Scavenge Fire
    if (lower.contains('scavenge fire')) {
      return '''⚓ **Main Engine Scavenge Fire Procedure**

1. **Causes:**
Unburnt fuel oil, cylinder lube oil accumulation, and blow-by past piston rings reacting with hot scavenge air.

2. **Symptoms:**
Scavenge trunk high temperature alarm, exhaust temp rise, smoke from scavenge drains, turbocharger surging.

3. **Emergency Procedure:**
- Inform Bridge and Chief Engineer; slow down engine speed.
- Cut fuel to affected cylinder. Increase cylinder lubrication to affected unit.
- Close scavenge drains.
- If fire persists, stop engine, engage turning gear, and operate fixed CO2 or steam smothering system.
- Do NOT open scavenge door until space has cooled down (danger of crankcase/scavenge explosion).''';
    }

    // Crankcase Explosion
    if (lower.contains('crankcase explosion')) {
      return '''⚓ **Crankcase Explosion & Relief Valves**

1. **Mechanism:**
Hot spot (bearing friction) causes oil mist formation (>50 mg/L lower flammable limit). Spark ignites primary explosion, creating pressure wave.

2. **Crankcase Relief Valves:**
- Equipped with flame trap (gauze) and spring-loaded non-return disc.
- Opens at 0.2 bar over-pressure and closes instantly to prevent air ingress (secondary explosion).

3. **Action:** Stop engine immediately, notify bridge, keep clear of relief valves, do NOT open crankcase doors for at least 20-30 minutes.''';
    }

    // Steering Gear
    if (lower.contains('steering gear')) {
      return '''⚓ **Steering Gear System & Emergency Operations**

1. **SOLAS Requirements:**
- Capable of putting rudder from 35° one side to 35° other side; and 35° to 30° on opposite side within **28 seconds** at maximum service speed.
- Main & auxiliary steering power units with automatic isolation (SAFEMATIC).

2. **Emergency Steering Procedure:**
- Switch steering control from Bridge to Local Engine Room Steering Flat.
- Disconnect remote telemotor.
- Operate hydraulic solenoid valve manually or use emergency hand pump while communicating with Bridge via sound-powered telephone.''';
    }

    // COLREGs
    if (lower.contains('colreg') || lower.contains('rule 14') || lower.contains('rule 15') || lower.contains('rule 19')) {
      return '''⚓ **COLREGs Key Rules & Interview Summary**

• **Rule 14 (Head-On Situation):** Two power-driven vessels meeting on reciprocal courses. Both must alter course to **Starboard** so each passes on port side of the other.
• **Rule 15 (Crossing Situation):** Vessel having the other on her **Starboard** side must keep clear and avoid crossing ahead.
• **Rule 19 (Restricted Visibility):** Applicable when not in sight of one another. Every vessel must proceed at a **safe speed**, have engines ready for immediate maneuver, and take early avoiding action.

💡 **Sound Signals:** 1 short blast = altering course to starboard; 2 short blasts = altering course to port; 5 short/rapid blasts = doubt/warning signal.''';
    }

    // Generic Structured Expert Technical Answer Template
    final titleTerm = _capitalizeWords(query);
    return '''⚓ **$titleTerm — Maritime Technical & Interview Brief**

1. **Overview & Working Principle:**
In maritime engineering and shipboard operations, **$titleTerm** plays a vital role in maintaining vessel safety, machinery reliability, and regulatory compliance. It is evaluated under standard MMD Class IV / Class II oral examinations and shipping company interviews.

2. **Key Construction & Components:**
- Designed according to **class society rules** (DNV, ClassNK, ABS, LRS) and IMO conventions.
- Built using corrosion-resistant marine materials (bronze, nodular cast iron, stainless steel, or composite alloys).
- Integrated with protective safety interlocks, alarms, and emergency manual overrides.

3. **Shipboard Operation & Safety Procedures:**
- **Pre-Start Checks:** Inspect lube oil levels, line valve line-ups, pressure gauges, and electrical power availability.
- **Operating Precautions:** Monitor operational parameters (temperature, pressure, vibration, flow rate) continuously.
- **Emergency Actions:** In case of abnormal noise or alarm activation, isolate the unit, activate standby machinery, and record entry in the Engine Room Logbook.

4. **Interview Examination Tips:**
When asked about **$titleTerm** by a superintendent or surveyor, state the **purpose first**, followed by **operating pressure/temp limits**, **safety interlocks**, and **SOLAS/MARPOL regulations** applicable to the equipment.''';
  }

  String _capitalizeWords(String input) {
    if (input.isEmpty) return 'Maritime Topic';
    return input.split(' ').map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + (w.length > 1 ? w.substring(1).toLowerCase() : '');
    }).join(' ');
  }
}
