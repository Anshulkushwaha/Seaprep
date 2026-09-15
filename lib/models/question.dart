import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class QuestionItem {
  final String id;
  final String category;
  final String question;
  final String answer;
  final String? interviewTip;
  final List<Map<String, String>>? tableData; // For tables like Full Forms & Signals A-Z

  const QuestionItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    this.interviewTip,
    this.tableData,
  });

  factory QuestionItem.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>>? parsedTable;
    if (json['table_data'] != null) {
      final list = json['table_data'] as List<dynamic>;
      parsedTable = list
          .map((item) => Map<String, String>.from(item as Map))
          .toList();
    }

    return QuestionItem(
      id: json['id'] as String,
      category: json['category'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      interviewTip: json['interview_tip'] as String?,
      tableData: parsedTable,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'question': question,
        'answer': answer,
        'interview_tip': interviewTip,
        'table_data': tableData,
      };

  /// Fetches questions from Supabase with fallback to local PDF question list
  static Future<List<QuestionItem>> fetchQuestions() async {
    if (SupabaseConfig.isConfigured) {
      try {
        final response = await Supabase.instance.client
            .from('interview_questions')
            .select();
        final list = (response as List<dynamic>)
            .map((item) => QuestionItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        if (list.isNotEmpty) {
          return list;
        }
      } catch (e) {
        debugPrint('Supabase fetchQuestions error, falling back to local: $e');
      }
    }
    return allPDFQuestions;
  }

  static const List<QuestionItem> allPDFQuestions = [
    // 1. Emergency & Safety
    QuestionItem(
      id: 'pdf_1_1',
      category: '1. Emergency & Safety',
      question: 'What should you do in a blackout situation?',
      answer: 'Raise the alarm and inform the bridge/Master immediately. Confirm emergency generator/emergency lighting operation, stop or secure affected machinery as required, identify the cause, restore essential services systematically, and maintain safe navigation. Record and report the incident as required by the SMS.',
    ),
    QuestionItem(
      id: 'pdf_1_2',
      category: '1. Emergency & Safety',
      question: 'What should you do in case of steering failure?',
      answer: 'Inform the Master/bridge team, reduce speed as appropriate, change to the alternative/emergency steering system, check steering gear and power supply, and use available engines/thrusters/anchor as necessary. Display the required signals, maintain a proper lookout and warn nearby traffic/VTS.',
    ),
    QuestionItem(
      id: 'pdf_1_3',
      category: '1. Emergency & Safety',
      question: 'What should you do during a medical emergency?',
      answer: 'Raise the alarm, inform the Master and responsible medical person, assess the casualty (airway, breathing, circulation), give appropriate first aid, use the medical equipment/medicine as trained, obtain Radio Medical Advice when required, and arrange evacuation/medical assistance if necessary.',
    ),
    QuestionItem(
      id: 'pdf_1_4',
      category: '1. Emergency & Safety',
      question: 'Classes of fire and suitable extinguishers',
      answer: 'Class A: ordinary combustibles such as wood, paper and cloth — water/foam/dry powder as appropriate.\nClass B: flammable liquids such as diesel or paint — foam, dry powder or CO₂ as appropriate.\nClass C: flammable gases — dry powder is commonly used.\nClass D: combustible metals — special dry powder.\nClass F: cooking oils/fats — wet chemical.\nFor energized electrical equipment, isolate the power first where possible and use a non-conductive agent such as CO₂ or dry powder. Exact classifications vary by standard.',
    ),
    QuestionItem(
      id: 'pdf_1_5',
      category: '1. Emergency & Safety',
      question: 'Give a practical example of fire fighting.',
      answer: 'For a small diesel-oil fire in a machinery space, raise the alarm, stop the fuel source if safe, isolate ventilation if required by procedure, use the correct portable extinguisher (for example foam/dry powder/CO₂ as applicable), keep an escape route, and never put yourself between the fire and your escape.',
    ),

    // 2. MLC 2006
    QuestionItem(
      id: 'pdf_2_1',
      category: '2. MLC 2006',
      question: 'What is MLC 2006?',
      answer: 'The Maritime Labour Convention, 2006 is an ILO convention that establishes minimum international standards for seafarers\' working and living conditions. It covers matters such as minimum requirements for seafarers to work on a ship, conditions of employment, accommodation, food and catering, health protection, medical care, welfare and social security. It is commonly called the fourth pillar of the international maritime regulatory framework, alongside SOLAS, MARPOL and STCW.',
      interviewTip: 'MLC was adopted on 23 February 2006 and entered into force on 20 August 2013. It has been amended over time, so current requirements should be checked against the latest version.',
    ),

    // 3. Maersk Alcohol & Drug Policy
    QuestionItem(
      id: 'pdf_3_1',
      category: '3. Maersk Alcohol & Drug Policy',
      question: 'What is the policy of Maersk regarding alcohol and drugs?',
      answer: 'The safe interview answer is: Maersk vessel operations apply strict controls on alcohol and drugs. Personnel must not be under the influence of alcohol or drugs while on board, and prohibited possession/use is not accepted. Drug and alcohol testing may be carried out, including unannounced testing depending on the applicable company procedure. Prescribed medication must be declared/handled according to company requirements. The exact rule can depend on the Maersk business unit and vessel, so the latest company policy must be followed.',
      interviewTip: 'Maersk Supply Service publicly states that no person shall be under the influence or in possession of drugs or alcohol while on board its vessels.',
    ),

    // 4. Ship & Seamanship Basics
    QuestionItem(
      id: 'pdf_4_1',
      category: '4. Ship & Seamanship Basics',
      question: 'Types of ships',
      answer: 'Container ships, bulk carriers, oil/chemical tankers, LNG/LPG carriers, Ro-Ro ships, car carriers, general cargo ships, passenger ships, offshore/support vessels and specialised vessels.',
    ),
    QuestionItem(
      id: 'pdf_4_2',
      category: '4. Ship & Seamanship Basics',
      question: 'Basic parts of a ship',
      answer: 'Bow, stern, port, starboard, keel, hull, frames, bulkheads, decks, superstructure, bridge, accommodation, engine room, cargo holds/tanks, forecastle, poop, rudder, propeller, anchors, windlass, mooring equipment and masts.',
    ),
    QuestionItem(
      id: 'pdf_4_3',
      category: '4. Ship & Seamanship Basics',
      question: 'What is seamanship?',
      answer: 'Seamanship is the practical knowledge and skills required to safely operate, maintain and handle a vessel, including navigation support, mooring, anchoring, cargo-related deck work, safety and emergency operations.',
    ),
    QuestionItem(
      id: 'pdf_4_4',
      category: '4. Ship & Seamanship Basics',
      question: 'Difference between heel and list',
      answer: 'Heel is a temporary inclination caused by external forces such as wind, waves, turning or cargo operations.\nList is a persistent inclination, normally caused by unequal weight distribution or a transverse shift of weight.',
    ),
    QuestionItem(
      id: 'pdf_4_5',
      category: '4. Ship & Seamanship Basics',
      question: 'What are the six degrees of freedom of a ship?',
      answer: 'Three translational motions: surge (fore-and-aft), sway (side-to-side), and heave (up-and-down).\nThree rotational motions: roll (about the longitudinal axis), pitch (about the transverse axis), and yaw (about the vertical axis).',
    ),
    QuestionItem(
      id: 'pdf_4_6',
      category: '4. Ship & Seamanship Basics',
      question: 'What is boxing the compass?',
      answer: 'Boxing the compass means reciting the compass points in order, normally clockwise, through the traditional 32 points from North back to North. It is used as a basic test of compass-direction knowledge.',
    ),
    QuestionItem(
      id: 'pdf_4_7',
      category: '4. Ship & Seamanship Basics',
      question: 'What is a sextant?',
      answer: 'A sextant is a navigational instrument used to measure the angle between a celestial body and the visible horizon. The observed altitude can be used with time and nautical data to obtain a line of position and help determine the ship\'s position.',
    ),

    // 5. LSA & FFA
    QuestionItem(
      id: 'pdf_5_1',
      category: '5. LSA & FFA',
      question: 'What are LSA and FFA?',
      answer: 'LSA = Life-Saving Appliances. Examples include lifeboats, liferafts, lifejackets, lifebuoys, immersion suits, rescue boats and pyrotechnic distress signals.\nFFA = Fire-Fighting Appliances. Examples include fire extinguishers, fire hoses/nozzles, hydrants, fire pumps, fixed CO₂ systems, foam systems, fireman\'s outfit and SCBA.',
    ),

    // 6. Important COLREG Rules
    QuestionItem(
      id: 'pdf_6_1',
      category: '6. Important COLREG Rules',
      question: 'Rule 3 — General Definitions',
      answer: 'Defines important terms such as vessel, power-driven vessel, sailing vessel, vessel engaged in fishing, vessel not under command, vessel restricted in her ability to manoeuvre, vessel constrained by her draught, underway, vessels in sight of one another and restricted visibility.',
    ),
    QuestionItem(
      id: 'pdf_6_2',
      category: '6. Important COLREG Rules',
      question: 'Rule 5 — Look-out',
      answer: 'Every vessel must maintain a proper look-out by sight, hearing and all appropriate available means to make a full appraisal of the situation and risk of collision.',
    ),
    QuestionItem(
      id: 'pdf_6_3',
      category: '6. Important COLREG Rules',
      question: 'Rule 6 — Safe Speed',
      answer: 'Proceed at a safe speed so that proper and effective action can be taken to avoid collision and the vessel can be stopped within an appropriate distance. Consider visibility, traffic density, manoeuvrability, background lights, wind/sea/current and radar limitations.',
    ),
    QuestionItem(
      id: 'pdf_6_4',
      category: '6. Important COLREG Rules',
      question: 'Rule 7 — Risk of Collision',
      answer: 'Use all available means, including radar, to determine whether risk of collision exists. If in doubt, assume that risk exists. A constant or nearly constant bearing with decreasing range is an important indication of collision risk.',
    ),
    QuestionItem(
      id: 'pdf_6_5',
      category: '6. Important COLREG Rules',
      question: 'Rule 8 — Action to Avoid Collision',
      answer: 'Take early and substantial action, made in good time and large enough to be readily apparent. Avoid a series of small alterations. The action should result in passing at a safe distance and the vessel should check the effectiveness of the action.',
    ),
    QuestionItem(
      id: 'pdf_6_6',
      category: '6. Important COLREG Rules',
      question: 'Rule 13 — Overtaking',
      answer: 'Any vessel overtaking another is the overtaking vessel and must keep out of the way. A vessel is considered overtaking when approaching from more than 22.5° abaft the other vessel\'s beam.',
    ),
    QuestionItem(
      id: 'pdf_6_7',
      category: '6. Important COLREG Rules',
      question: 'Rule 14 — Head-on Situation',
      answer: 'When two power-driven vessels are meeting on reciprocal or nearly reciprocal courses with risk of collision, each shall alter course to starboard so that each passes on the other\'s port side.',
    ),
    QuestionItem(
      id: 'pdf_6_8',
      category: '6. Important COLREG Rules',
      question: 'Rule 15 — Crossing Situation',
      answer: 'When two power-driven vessels are crossing with risk of collision, the vessel which has the other on her own starboard side shall keep out of the way and, if circumstances allow, avoid crossing ahead of the other vessel.',
    ),
    QuestionItem(
      id: 'pdf_6_9',
      category: '6. Important COLREG Rules',
      question: 'Rule 19 — Conduct in Restricted Visibility',
      answer: 'Applies to vessels not in sight of one another when navigating in or near restricted visibility. Proceed at a safe speed, have engines ready for immediate manoeuvre, use radar properly, assess collision risk and follow the specific course-alteration restrictions in the rule.',
    ),

    // 7. AMET — Basic Knowledge
    QuestionItem(
      id: 'pdf_7_1',
      category: '7. AMET — Basic Knowledge',
      question: 'What is the full form of AMET?',
      answer: 'Academy of Maritime Education and Training (AMET). It is a maritime-focused university in Chennai, Tamil Nadu.',
    ),
    QuestionItem(
      id: 'pdf_7_2',
      category: '7. AMET — Basic Knowledge',
      question: 'When was AMET established?',
      answer: 'AMET was established in 1993.',
    ),
    QuestionItem(
      id: 'pdf_7_3',
      category: '7. AMET — Basic Knowledge',
      question: 'Who is the Chancellor of AMET?',
      answer: 'Dr. J. Ramachandran is the Chancellor of AMET University.',
    ),
    QuestionItem(
      id: 'pdf_7_4',
      category: '7. AMET — Basic Knowledge',
      question: 'Current Vice-Chancellor of AMET',
      answer: 'Dr. V. Rajendran is listed by AMET as the Vice-Chancellor. For an interview, remember the Chancellor and Vice-Chancellor separately.',
    ),

    // 8. Navigation Basics
    QuestionItem(
      id: 'pdf_8_1',
      category: '8. Navigation Basics',
      question: 'What is latitude?',
      answer: 'Angular distance north or south of the Equator, measured in degrees, minutes and seconds. 1° of latitude = 60 nautical miles.',
    ),
    QuestionItem(
      id: 'pdf_8_2',
      category: '8. Navigation Basics',
      question: 'What is longitude?',
      answer: 'Angular distance east or west of the Prime Meridian, measured from 0° to 180° E or W.',
    ),
    QuestionItem(
      id: 'pdf_8_3',
      category: '8. Navigation Basics',
      question: 'Basic navigation formula — difference of latitude',
      answer: 'D\'Lat is the difference between two latitudes. Same name: subtract; contrary name: add. 1 minute of latitude corresponds to 1 nautical mile.',
    ),
    QuestionItem(
      id: 'pdf_8_4',
      category: '8. Navigation Basics',
      question: 'Difference of longitude',
      answer: 'D\'Long is the difference between two longitudes. Same name: subtract; contrary name: add.',
    ),
    QuestionItem(
      id: 'pdf_8_5',
      category: '8. Navigation Basics',
      question: 'Departure',
      answer: 'Departure is the east-west distance between two meridians at a given latitude. Approximate formula:\nDeparture = D\'Long × cos(mean latitude), when D\'Long is expressed in nautical miles of longitude at the Equator.',
    ),
    QuestionItem(
      id: 'pdf_8_6',
      category: '8. Navigation Basics',
      question: 'Course and distance in plane sailing',
      answer: 'For small distances: tan C = Departure / D\'Lat, and Distance = D\'Lat / cos C, using the appropriate signs/quadrants.',
    ),
    QuestionItem(
      id: 'pdf_8_7',
      category: '8. Navigation Basics',
      question: 'What are nautical charts?',
      answer: 'Charts are graphical representations used for marine navigation. Common chart uses include ocean/general charts, coastal charts, approach charts and harbour plans. Common projections include Mercator for routine navigation, gnomonic for great-circle planning, and Lambert conformal for some aeronautical and regional uses.',
    ),
    QuestionItem(
      id: 'pdf_8_8',
      category: '8. Navigation Basics',
      question: 'Methods of finding a ship\'s position',
      answer: 'GPS/GNSS, visual bearings and cross bearings, transits/ranges, radar ranges and bearings, celestial observations with a sextant, and combinations of these methods.',
    ),
    QuestionItem(
      id: 'pdf_8_9',
      category: '8. Navigation Basics',
      question: 'Why is a ship\'s position determined?',
      answer: 'To monitor the vessel\'s progress, confirm the planned track, detect navigational errors, maintain safe under-keel clearance and support safe passage planning.',
    ),
    QuestionItem(
      id: 'pdf_8_10',
      category: '8. Navigation Basics',
      question: 'Why use Norie\'s tables?',
      answer: 'Norie\'s Nautical Tables provide precomputed mathematical/trigonometric values used in traditional navigation calculations, reducing the need to calculate every value from scratch.',
    ),
    QuestionItem(
      id: 'pdf_8_11',
      category: '8. Navigation Basics',
      question: 'Types of sailing to know',
      answer: '• Plane sailing — used for relatively short distances where curvature of the Earth can be neglected.\n• Parallel sailing — movement along a parallel of latitude; useful when latitude remains constant.\n• Middle-latitude sailing — accounts for convergence of meridians using a mean latitude.\n• Mercator sailing — uses Mercator charts and meridional parts; rhumb-line courses are straight on a Mercator chart.\n• Great-circle sailing — follows the shortest route on the Earth\'s surface, though the course continuously changes.',
    ),

    // 9. Basic 10th/12th-Level Science
    QuestionItem(
      id: 'pdf_9_1',
      category: '9. Basic 10th/12th-Level Science',
      question: 'Newton\'s Laws of Motion',
      answer: '1st: A body remains at rest or uniform motion unless acted on by an external unbalanced force.\n2nd: Force = mass × acceleration (F = ma).\n3rd: For every action there is an equal and opposite reaction.',
    ),
    QuestionItem(
      id: 'pdf_9_2',
      category: '9. Basic 10th/12th-Level Science',
      question: 'Kirchhoff\'s Current Law (KCL)',
      answer: 'The algebraic sum of currents at a junction is zero; total current entering a node equals total current leaving it.',
    ),
    QuestionItem(
      id: 'pdf_9_3',
      category: '9. Basic 10th/12th-Level Science',
      question: 'Kirchhoff\'s Voltage Law (KVL)',
      answer: 'The algebraic sum of all voltages around a closed electrical loop is zero.',
    ),
    QuestionItem(
      id: 'pdf_9_4',
      category: '9. Basic 10th/12th-Level Science',
      question: 'Doppler Effect',
      answer: 'The apparent change in frequency of a wave caused by relative motion between the source and observer. Example: a siren sounds higher as it approaches and lower as it moves away.',
    ),
    QuestionItem(
      id: 'pdf_9_5',
      category: '9. Basic 10th/12th-Level Science',
      question: 'Bernoulli\'s Theorem',
      answer: 'For steady, incompressible, non-viscous flow along a streamline, pressure head + velocity head + elevation head remains constant: P/ρg + V²/2g + z = constant.',
    ),

    // 10. Important Maritime Full Forms
    QuestionItem(
      id: 'pdf_10_1',
      category: '10. Important Maritime Full Forms',
      question: 'Important Maritime Abbreviations & Full Forms',
      answer: 'Complete table of maritime acronyms used in operations and orals:',
      tableData: [
        {'abbrev': 'GMDSS', 'full': 'Global Maritime Distress and Safety System'},
        {'abbrev': 'EPIRB', 'full': 'Emergency Position-Indicating Radio Beacon'},
        {'abbrev': 'ECDIS', 'full': 'Electronic Chart Display and Information System'},
        {'abbrev': 'RADAR', 'full': 'Radio Detection and Ranging'},
        {'abbrev': 'AIS', 'full': 'Automatic Identification System'},
        {'abbrev': 'ROTI', 'full': 'Rate of Turn Indicator'},
        {'abbrev': 'RPM', 'full': 'Revolutions Per Minute'},
        {'abbrev': 'ARPA', 'full': 'Automatic Radar Plotting Aid'},
        {'abbrev': 'GPS', 'full': 'Global Positioning System'},
        {'abbrev': 'VHF', 'full': 'Very High Frequency'},
        {'abbrev': 'VDR', 'full': 'Voyage Data Recorder'},
        {'abbrev': 'DSC', 'full': 'Digital Selective Calling'},
        {'abbrev': 'SCBA', 'full': 'Self-Contained Breathing Apparatus'},
        {'abbrev': 'STCW', 'full': 'Standards of Training, Certification and Watchkeeping for Seafarers'},
      ],
    ),

    // 11. Bay Plan & Container Basics
    QuestionItem(
      id: 'pdf_11_1',
      category: '11. Bay Plan & Container Basics',
      question: 'What is a bay plan?',
      answer: 'A bay plan is the vessel\'s container stowage plan showing where each container is positioned. It identifies bays, rows and tiers and is used for safe and efficient stowage, lashing, stability, segregation and cargo operations.',
    ),
    QuestionItem(
      id: 'pdf_11_2',
      category: '11. Bay Plan & Container Basics',
      question: 'Container position notation',
      answer: 'A container\'s location is commonly identified by Bay – Row – Tier. Bay identifies the longitudinal position, row identifies the transverse position, and tier identifies the vertical level.',
    ),
    QuestionItem(
      id: 'pdf_11_3',
      category: '11. Bay Plan & Container Basics',
      question: 'Common container types',
      answer: 'Dry/general-purpose, high-cube, reefer, open-top, flat-rack, tank container and specialised containers such as platform/container variants.',
    ),
    QuestionItem(
      id: 'pdf_11_4',
      category: '11. Bay Plan & Container Basics',
      question: 'Common container sizes',
      answer: 'The most common ISO sizes are 20 ft and 40 ft. 45 ft high-cube containers are also used in many trades. A standard 20-ft container is commonly called a TEU; a 40-ft container is 2 TEU. Actual external/internal dimensions, weights and ratings depend on the container type and ISO specification.',
    ),
    QuestionItem(
      id: 'pdf_11_5',
      category: '11. Bay Plan & Container Basics',
      question: 'Why is correct container stowage important?',
      answer: 'To maintain ship stability and strength, prevent cargo damage, maintain proper lashing, comply with dangerous-goods segregation, protect reefer cargo and ensure safe loading/unloading.',
    ),

    // 12. International Code of Signals — Single-Letter Signals A–Z
    QuestionItem(
      id: 'pdf_12_1',
      category: '12. Code of Signals A–Z',
      question: 'International Code of Signals — Single-Letter Signals (A to Z)',
      answer: 'Standard single-letter meanings in the International Code of Signals (ICS):',
      tableData: [
        {'abbrev': 'A — Alfa', 'full': 'I have a diver down; keep well clear at slow speed.'},
        {'abbrev': 'B — Bravo', 'full': 'I am taking in, discharging, or carrying dangerous goods.'},
        {'abbrev': 'C — Charlie', 'full': 'Affirmative.'},
        {'abbrev': 'D — Delta', 'full': 'Keep clear of me; I am manoeuvring with difficulty.'},
        {'abbrev': 'E — Echo', 'full': 'I am altering my course to starboard.'},
        {'abbrev': 'F — Foxtrot', 'full': 'I am disabled; communicate with me.'},
        {'abbrev': 'G — Golf', 'full': 'I require a pilot. (Fishing vessels near grounds: I am hauling nets.)'},
        {'abbrev': 'H — Hotel', 'full': 'I have a pilot on board.'},
        {'abbrev': 'I — India', 'full': 'I am altering my course to port.'},
        {'abbrev': 'J — Juliett', 'full': 'Keep well clear of me; I am on fire and have dangerous cargo on board, or leaking dangerous cargo.'},
        {'abbrev': 'K — Kilo', 'full': 'I wish to communicate with you.'},
        {'abbrev': 'L — Lima', 'full': 'You should stop your vessel instantly.'},
        {'abbrev': 'M — Mike', 'full': 'My vessel is stopped and making no way through the water.'},
        {'abbrev': 'N — November', 'full': 'Negative.'},
        {'abbrev': 'O — Oscar', 'full': 'Man overboard.'},
        {'abbrev': 'P — Papa', 'full': 'In harbour: all persons report on board as vessel is about to proceed to sea.'},
        {'abbrev': 'Q — Quebec', 'full': 'My vessel is "healthy" and I request free pratique.'},
        {'abbrev': 'R — Romeo', 'full': 'No current general single-letter meaning in modern ICS.'},
        {'abbrev': 'S — Sierra', 'full': 'I am operating astern propulsion.'},
        {'abbrev': 'T — Tango', 'full': 'Keep clear of me; I am engaged in pair trawling.'},
        {'abbrev': 'U — Uniform', 'full': 'You are running into danger.'},
        {'abbrev': 'V — Victor', 'full': 'I require assistance.'},
        {'abbrev': 'W — Whiskey', 'full': 'I require medical assistance.'},
        {'abbrev': 'X — X-ray', 'full': 'Stop carrying out your intentions and watch for my signals.'},
        {'abbrev': 'Y — Yankee', 'full': 'I am dragging my anchor.'},
        {'abbrev': 'Z — Zulu', 'full': 'I require a tug. (Fishing vessels: I am shooting nets.)'},
      ],
    ),

    // 13. Quick Interview Advice
    QuestionItem(
      id: 'pdf_13_1',
      category: '13. Quick Interview Advice',
      question: 'Quick Interview Advice for Maritime Technical & Orals',
      answer: '• For any technical subject, start with the definition, then principle/working, then one practical example.\n• For safety questions, structure the answer as: raise alarm → inform responsible officer/Master → assess situation → take immediate safe action → use correct equipment/procedure → report/record.\n• For navigation questions, know the units: nautical mile, knot, degrees/minutes, latitude/longitude, course and bearing.\n• For machinery questions, know basic purpose, working principle, major parts, common faults and safety precautions.\n• If you do not know an answer in an interview, do not invent it. Say what you know and explain how you would verify the correct procedure.',
    ),

    // 14. Personal HR Questions
    QuestionItem(
      id: 'pdf_14_1',
      category: '14. Personal HR Questions',
      question: 'Introduce yourself and explain why you want to join the Merchant Navy.',
      answer: 'Present your full name, academic background (PCM Class 12th / Pre-sea training), family background, interest in maritime discipline, passion for navigation or marine engineering, and mental & physical readiness for a disciplined life at sea.',
      interviewTip: 'Keep your self-introduction structured: 1. Academic qualifications, 2. Key achievements, 3. Motivation for merchant navy, 4. Immediate career target.',
    ),
    QuestionItem(
      id: 'pdf_14_2',
      category: '14. Personal HR Questions',
      question: 'Why did you choose to apply for our specific shipping company?',
      answer: 'Highlight the company\'s global fleet reputation, safety management system (SMS), global trade routes, structured cadet sponsorship & promotion path, and commitment to environmental sustainability.',
    ),
    QuestionItem(
      id: 'pdf_14_3',
      category: '14. Personal HR Questions',
      question: 'What are your key strengths and one weakness you are working to improve?',
      answer: 'Strengths: Discipline, adaptability under pressure, strong teamwork, and technical curiosity. Weakness: Mention a real skill you are actively improving (e.g. "I am practicing advanced celestial navigation calculations every day to improve speed").',
    ),
    QuestionItem(
      id: 'pdf_14_4',
      category: '14. Personal HR Questions',
      question: 'Where do you see yourself in 5 to 7 years in your maritime career?',
      answer: 'Outline a disciplined career path: Completing pre-sea cadetship, obtaining Class 4 / OOW Certificate of Competency, serving as 3rd Officer / 4th Engineer, and preparing for Chief Officer / 2nd Engineer CoC examinations.',
    ),
    QuestionItem(
      id: 'pdf_14_5',
      category: '14. Personal HR Questions',
      question: 'How do you prepare mentally for spending long contracts (6-9 months) away from family?',
      answer: 'Explain mental resilience, maintaining daily shipboard routines, staying focused on professional learning and safety, taking part in onboard sports/recreation, and staying in regular contact with family during port calls.',
    ),

    // 15. Psychometric Questions
    QuestionItem(
      id: 'pdf_15_1',
      category: '15. Psychometric Questions',
      question: 'What would you do if a senior officer ignores a safety rule during deck or engine room operations?',
      answer: 'Respectfully bring the potential safety risk to their attention using Stop Work Authority / safety protocol principles. If safety is immediately compromised, intervene safely and report through official SMS safety reporting channels.',
      interviewTip: 'Safety is non-negotiable at sea. Interviewers look for courage combined with professional respect.',
    ),
    QuestionItem(
      id: 'pdf_15_2',
      category: '15. Psychometric Questions',
      question: 'How do you handle high-stress situations with tight deadlines during port operations?',
      answer: 'Prioritize safety first, communicate clearly with watchkeepers, break down tasks into structured steps using checklists, remain calm under pressure, and never compromise safety procedures for speed.',
    ),
    QuestionItem(
      id: 'pdf_15_3',
      category: '15. Psychometric Questions',
      question: 'Describe how you resolve interpersonal conflicts with fellow crew members on board.',
      answer: 'Listen actively to understand their perspective, keep emotions neutral, focus on common vessel operational goals, and follow proper chain of command if conflict affects ship safety or morale.',
    ),
    QuestionItem(
      id: 'pdf_15_4',
      category: '15. Psychometric Questions',
      question: 'How do you adapt to working in a multicultural crew from diverse nationalities?',
      answer: 'Embrace cultural diversity, use standard maritime English for clear unambiguous communication, respect different traditions and dietary habits, and maintain positive team spirit.',
    ),
    QuestionItem(
      id: 'pdf_15_5',
      category: '15. Psychometric Questions',
      question: 'What action should you take if you experience extreme fatigue while on navigational or engine watch?',
      answer: 'Inform the Officer of the Watch (OOW) or Chief Engineer immediately. Working while fatigued impairs alertness and violates STCW rest hour regulations and vessel SMS safety policies.',
    ),

    // 16. Seagull / CES Questions
    QuestionItem(
      id: 'pdf_16_1',
      category: '16. Seagull / CES Questions',
      question: 'Seagull CES: What is the SOLAS requirement for fire and abandon ship drills on cargo vessels?',
      answer: 'Every crew member shall participate in at least one abandon ship drill and one fire drill every month. Drills must take place within 24 hours of leaving port if more than 25% of the crew have not participated in drills on that ship in the previous month.',
      interviewTip: 'Seagull CES tests exact regulatory thresholds. Memorize SOLAS Chapter III drill intervals.',
    ),
    QuestionItem(
      id: 'pdf_16_2',
      category: '16. Seagull / CES Questions',
      question: 'Seagull CES: On what frequencies does a modern EPIRB transmit distress signals?',
      answer: 'An EPIRB transmits a 406 MHz digital distress signal to the Cospas-Sarsat satellite system and a 121.5 MHz homing signal for search and rescue craft, accompanied by a high-intensity white strobe light.',
    ),
    QuestionItem(
      id: 'pdf_16_3',
      category: '16. Seagull / CES Questions',
      question: 'Seagull CES: MARPOL Annex V rules for comminuted food waste discharge outside Special Areas.',
      answer: 'Food waste ground or comminuted to pass through a screen with openings no greater than 25 mm may be discharged into the sea while the vessel is en route and not less than 3 Nautical Miles from the nearest land.',
    ),
    QuestionItem(
      id: 'pdf_16_4',
      category: '16. Seagull / CES Questions',
      question: 'Seagull CES: What is the operating depth of a hydrostatic release unit (HRU) for liferafts?',
      answer: 'A Hydrostatic Release Unit (HRU) automatically cuts the painter/lashing line to release the liferaft container at a submerged depth of between 1.5 and 4.0 meters.',
    ),
    QuestionItem(
      id: 'pdf_16_5',
      category: '16. Seagull / CES Questions',
      question: 'Seagull CES: What triggers the Safety Contour alarm on an ECDIS?',
      answer: 'The Safety Contour separates safe navigable water from shallow water based on ship draft, squat, and required Under Keel Clearance (UKC). Approaching or crossing the safety contour triggers a visual and audible alarm.',
    ),

    // 17. Zodiac Maritime Real Interview Questions (Shashi Shekhar Singh Experience)
    QuestionItem(
      id: 'zodiac_pdf_1',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: Why did you choose Merchant Navy over government jobs?',
      answer: 'Highlight your passion for maritime navigation/engineering, disciplined work culture, exposure to cutting-edge vessel technology, hands-on operational leadership, and clear merit-based CoC career progression.',
      interviewTip: 'Show confidence and clarity. Emphasize why sea life suits your long-term career ambition.',
    ),
    QuestionItem(
      id: 'zodiac_pdf_2',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: What specific PPE must be worn while climbing a ship ladder or mast?',
      answer: 'Full PPE required: Safety harness with double lanyards (hooked to a secure point above waist level), safety helmet with chin strap, non-slip safety boots, work gloves, and boiler suit.',
    ),
    QuestionItem(
      id: 'zodiac_pdf_3',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: Difference between an Oil Purifier and a Clarifier.',
      answer: 'Purifier: Separates two liquids of different densities (water and fuel oil) plus heavy solids using a gravity disc. Clarifier: Separates fine solid impurities from liquid (no water separation, uses a blind disc).',
    ),
    QuestionItem(
      id: 'zodiac_pdf_4',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: How does a ship Refrigeration System work and what are its 4 main components?',
      answer: 'The 4 main components are: 1. Compressor (compresses refrigerant gas), 2. Condenser (cools and liquefies refrigerant), 3. Expansion Valve (meters flow and drops pressure), 4. Evaporator (absorbs heat from cold rooms).',
    ),
    QuestionItem(
      id: 'zodiac_pdf_5',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: What happens when you close the discharge valve of a Centrifugal Pump vs a Positive Displacement Pump?',
      answer: 'Centrifugal Pump: Liquid churns inside casing and pressure rises to shutoff head; pump can run closed briefly. Positive Displacement Pump: Pressure rises continuously until relief valve opens or discharge line/casing ruptures. Discharge valve must NEVER be closed on startup.',
    ),
    QuestionItem(
      id: 'zodiac_pdf_6',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: Explain the working of an Oily Water Separator (OWS) and 15 PPM monitor.',
      answer: 'OWS uses gravity separation and coalescer filter elements to separate oil from bilge water. The 15 PPM bilge alarm monitor continuously checks oil content; if >15 PPM, a 3-way solenoid valve automatically diverts discharge back to the bilge holding tank.',
    ),
    QuestionItem(
      id: 'zodiac_pdf_7',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: Explain the Fire Tetrahedron and its 4th component.',
      answer: 'The Fire Tetrahedron consists of 4 components: Fuel, Heat, Oxygen, and the 4th component: Uninhibited Chemical Chain Reaction. Halon, Dry Chemical Powder, and specialized agents extinguish fire by breaking this chain reaction.',
    ),
    QuestionItem(
      id: 'zodiac_pdf_8',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: Types of fixed fire fighting systems used onboard ships.',
      answer: '1. High-Pressure Hyper-Mist System (local protection for machinery spaces), 2. Bulk Total Flooding CO₂ System (for engine rooms and cargo holds), 3. High-Expansion Foam System (for boiler rooms and bilges).',
    ),
    QuestionItem(
      id: 'zodiac_pdf_9',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: How does a Turbocharger work?',
      answer: 'A Turbocharger utilizes exhaust gas energy from engine cylinders to drive a turbine wheel. The turbine drives a centrifugal compressor wheel on the same shaft, compressing ambient air and delivering high-density scavenge air to engine cylinders.',
    ),
    QuestionItem(
      id: 'zodiac_pdf_10',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: Working principle of a Vacuum Flash Fresh Water Generator (FWG).',
      answer: 'Operates under high vacuum (approx 93% / 700 mmHg) created by an air ejector. The vacuum lowers seawater boiling point to around 45°C, using main engine jacket cooling water (65-80°C) as the heating medium to produce pure distillate fresh water.',
    ),
    QuestionItem(
      id: 'zodiac_pdf_11',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: What is a Rocker Arm and its function?',
      answer: 'A Rocker Arm is an oscillating lever that receives force from the camshaft pushrod/hydraulic medium and transmits it to depress and open the cylinder intake or exhaust valve against valve spring pressure.',
    ),
    QuestionItem(
      id: 'zodiac_pdf_12',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: Key differences between 4-Stroke and 2-Stroke engines.',
      answer: '4-Stroke Engine: Completes 1 power cycle in 4 piston strokes (720° crankshaft rotation); uses inlet and exhaust valves. 2-Stroke Engine: Completes 1 power cycle in 2 piston strokes (360° crankshaft rotation); uses scavenge ports and exhaust valve/ports.',
    ),
    QuestionItem(
      id: 'zodiac_pdf_13',
      category: 'Zodiac Maritime Real Interview Questions',
      question: 'Zodiac Interview: Man Overboard (MOB) Marker specifications and operation.',
      answer: 'MOB marker is attached to bridge wing lifebuoys. When released, it automatically emits dense orange smoke for at least 15 minutes and a 2-candela white light for at least 2 hours to mark the location of a casualty.',
    ),

    // 18. NYK Line Real Interview Questions
    QuestionItem(
      id: 'nyk_pdf_1',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: What is the difference between an automobile engine and a marine engine?',
      answer: '• Environment & Medium: Marine engines operate in harsh saltwater environments requiring corrosion-resistant materials (bronze, cupronickel) and closed-loop fresh water cooling cooled by seawater heat exchangers, whereas car engines use air-cooled radiators with antifreeze.\n• Load Profile: Marine engines run continuously at heavy constant load (80–90% MCR) for days/weeks, whereas automobile engines experience frequent speed and load variations.\n• Size & Power: Marine engines range from medium-speed 4-stroke generator engines to massive low-speed 2-stroke propulsion engines operating on HFO/VLSFO with direct shaft coupling, whereas automobile engines are high-speed petrol/diesel engines with complex gearboxes.\n• Safety & Redundancy: Marine engines feature duplicate critical systems (duplex filters, standby pumps, oil mist detectors) with strict SOLAS/IMO compliance.',
    ),
    QuestionItem(
      id: 'nyk_pdf_2',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: Classify the types of internal combustion (IC) engines.',
      answer: '• By Working Cycle: 2-Stroke engines (1 power stroke per crank rev / 360°) and 4-Stroke engines (1 power stroke per 2 crank revs / 720°).\n• By Fuel & Ignition: Spark Ignition (SI - Petrol/Gas) and Compression Ignition (CI - Diesel/HFO).\n• By Cylinder Layout: In-line, V-engine, Radial, Opposed Piston.\n• By Engine Speed: High-speed (>1000 RPM), Medium-speed (300–1000 RPM), Low-speed (<300 RPM).\n• By Construction: Trunk Piston engines vs Crosshead engines.\n• By Induction: Naturally Aspirated vs Turbocharged / Supercharged.',
    ),
    QuestionItem(
      id: 'nyk_pdf_3',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: What is the difference between a spark plug and a fuel injector? Where and why is each used?',
      answer: '• Spark Plug:\n  - Function: Creates a high-voltage electrical spark across an electrode gap to ignite an air-fuel mixture.\n  - Where used: Petrol (gasoline) & Gas engines (Spark Ignition / SI).\n  - Why used: Petrol has higher self-ignition temperature and lower volatility under compression, requiring an external electrical arc to initiate combustion at TDC.\n• Fuel Injector:\n  - Function: Atomizes liquid fuel into fine droplets under high hydraulic pressure (200–2000 bar) and delivers it directly into compressed hot air.\n  - Where used: Diesel and Heavy Fuel engines (Compression Ignition / CI).\n  - Why used: Air is compressed to high temperature (~500–700°C) exceeding self-ignition temperature of diesel, causing auto-ignition upon fuel injection.',
    ),
    QuestionItem(
      id: 'nyk_pdf_4',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: Classify electric motors.',
      answer: '• AC Motors (Alternating Current):\n  - Induction / Asynchronous Motors: Squirrel Cage Induction Motor (most widely used onboard for pumps, fans, compressors due to ruggedness and low maintenance) and Slip Ring / Wound Rotor Motor.\n  - Synchronous Motors: Run at exact synchronous speed (Ns = 120f/P), used for high-power electric propulsion and shaft generators.\n• DC Motors (Direct Current): Series Motor (high starting torque for winches/cranes), Shunt Motor (constant speed), Compound Motor.\n• Specialized Motors: Brushless DC (BLDC) motors, Stepper motors, and Servo motors for control actuators and governor positioning.',
    ),
    QuestionItem(
      id: 'nyk_pdf_5',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: At what point in the cycle is fuel injected into a diesel engine? Explain the 4-stroke valve timing diagram.',
      answer: '• Fuel Injection Timing: Starts slightly BEFORE Top Dead Center (TDC) during compression stroke (typically 10° to 25° BTDC) to allow for ignition delay, ensuring peak combustion pressure is reached shortly after TDC (approx. 5° to 10° ATDC).\n• 4-Stroke Valve Timing Diagram Summary:\n  - Suction Valve: Opens ~10°–20° BTDC, Closes ~30°–40° ABDC (uses gas momentum for max volumetric efficiency).\n  - Fuel Injection: Begins ~10°–20° BTDC, Ends ~10°–15° ATDC.\n  - Exhaust Valve: Opens ~35°–45° BBDC (blowdown of exhaust gases), Closes ~15°–20° ATDC.\n  - Valve Overlap: Period around TDC where both inlet and exhaust valves are open simultaneously to scavenge the cylinder and cool internal parts.',
    ),
    QuestionItem(
      id: 'nyk_pdf_6',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: What is apparent slip?',
      answer: '• Definition: Apparent slip is the percentage difference between theoretical propeller speed (Pitch x RPM) and actual vessel speed relative to seabed (Va).\n• Formula: Apparent Slip (%) = [(Theoretical Distance - Observed Ship Distance) / Theoretical Distance] x 100.\n• Significance: Can be positive or negative depending on ocean currents, wind, sea state, and hull fouling. Real slip accounts for wake fraction of water moving with vessel.',
    ),
    QuestionItem(
      id: 'nyk_pdf_7',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: Explain working principle of a fuel oil purifier. Can HFO and MDO be separated using a purifier?',
      answer: '• Working Principle: Centrifugal separator runs at high rotational speed (6000–8000 RPM) creating high G-force. Liquid entering disc stack separates by density differences: Water (heavy phase) forced outwards, Clean Oil (light phase) displaced inwards, and Solid Sludge thrown to bowl periphery.\n• Can HFO & MDO be separated if mixed?: NO. HFO and MDO are miscible liquid hydrocarbons (they form a homogenous liquid solution). A purifier only separates immiscible liquids of different densities (water from oil) and insoluble solid particles.',
    ),
    QuestionItem(
      id: 'nyk_pdf_8',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: Are auxiliary engines used for shipboard generators the same as standard 4-stroke diesel engines?',
      answer: '• Yes, structurally they are 4-stroke trunk piston CI engines operating on Otto/Diesel thermodynamic cycle.\n• Marine Adaptations: Fitted with electronic/hydraulic governors maintaining constant speed (720 RPM for 60 Hz or 1000/1500 RPM for 50 Hz), HFO preheating/recirculation systems, jacket water preheating, SOLAS double-walled high-pressure fuel lines with leak alarm, and marine safety shutdowns (overspeed, low lube oil pressure, high cooling temperature).',
    ),
    QuestionItem(
      id: 'nyk_pdf_9',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: Are 4-stroke engines used on modern commercial ships? If yes, where and why?',
      answer: '• YES, extensively used onboard modern ships:\n  1. Auxiliary Diesel Generators: On bulkers, tankers, container ships, and gas carriers to produce shipboard electricity.\n  2. Main Propulsion: On cruise ships, ferries, Ro-Ro vessels, tugs, and OSVs in multi-engine diesel-electric or geared setups.\n• Why Used: Compact footprint and low headroom requirements compared to tall 2-stroke engines, high power-to-weight ratio, flexible speed control, and ability to run multiple smaller generator sets to match fluctuating electrical loads efficiently.',
    ),
    QuestionItem(
      id: 'nyk_pdf_10',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: Fire Emergency Scenario — Immediate steps, extinguisher selection, no extinguisher nearby, definition & F.I.R.E. protocol.',
      answer: '• A. Immediate Steps for Generator Fire: 1. Raise Emergency Alarm / Shout Fire in Engine Room. 2. Inform Bridge & Chief Engineer. 3. Stop affected Generator (Emergency Stop) & trip fuel Quick-Closing Valve (QCV). 4. Isolate electrical breaker. 5. Evacuate non-essential crew & attempt initial attack if safe.\n• B. Extinguisher Selection: CO₂ (Carbon Dioxide) or Dry Chemical Powder (DCP). CO₂ is preferred for electrical/generator fires as it leaves no residue and does not damage electrical windings.\n• C. Action if No Extinguisher Nearby: Retrace steps safely keeping escape route open, sound manual alarm call point, trip fuel QCVs, close ventilation dampers/doors to starve fire of oxygen, and prepare main fire hose line or activate Local Application Hyper-Mist / Fixed CO₂ flooding.\n• D. Definition & F.I.R.E. Protocol: Fire is a rapid exothermic oxidation chemical reaction producing heat, light, and reaction products. F.I.R.E. protocol stands for: F = Find fire, I = Inform / Raise alarm, R = Restrict / Contain fire (close doors/vents/valves), E = Extinguish / Evacuate.',
    ),
    QuestionItem(
      id: 'nyk_pdf_11',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: State Archimedes\' Principle.',
      answer: '• Statement: Any body completely or partially submerged in a fluid experiences an upward buoyant force equal to the weight of the fluid displaced by the body.\n• Formula: Fb = ρ x V x g (where ρ is fluid density, V is submerged volume, g is acceleration due to gravity).\n• Maritime Application: Explains ship buoyancy and flotation; vessel displaces a volume of seawater whose total weight equals total displacement mass of vessel.',
    ),
    QuestionItem(
      id: 'nyk_pdf_12',
      category: 'NYK Line Real Interview Questions',
      question: 'NYK Interview: What is the speed of sound in air versus water? Why does sound travel faster in water than in air?',
      answer: '• Speed of Sound: In Air ~343 m/s (at 20°C). In Seawater ~1480–1500 m/s (approx. 4.5 times faster than in air).\n• Why Faster in Water: Sound is a mechanical longitudinal wave propagating through particle collisions. Water is a liquid with much higher density and bulk modulus (incompressibility) than air. Molecules in water are packed much closer together, transferring acoustic vibration energy rapidly compared to widely separated, highly compressible air molecules.',
    ),
  ];
}
