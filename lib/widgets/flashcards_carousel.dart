import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_progress_repository.dart';
import '../theme/app_theme.dart';

class FlashcardData {
  final String id;
  final String category;
  final String question;
  final String answer;
  final String? tip;
  final List<Color> gradientColors;
  final IconData categoryIcon;

  FlashcardData({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    this.tip,
    required this.gradientColors,
    required this.categoryIcon,
  });
}

class FlashcardsCarouselWidget extends StatefulWidget {
  const FlashcardsCarouselWidget({super.key});

  @override
  State<FlashcardsCarouselWidget> createState() => _FlashcardsCarouselWidgetState();
}

class _FlashcardsCarouselWidgetState extends State<FlashcardsCarouselWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentIndex = 0;
  final Set<String> _flippedCardIds = {};

  static final List<FlashcardData> _cards = [
    FlashcardData(
      id: 'fc_1',
      category: 'COLREGs Rule 14 & 15',
      categoryIcon: Icons.sailing,
      question: 'What are the exact actions for Head-on (Rule 14) and Crossing (Rule 15) situations?',
      answer: 'Rule 14 (Head-on): Two power-driven vessels meeting on reciprocal courses shall BOTH alter course to STARBOARD so each passes on the port side of the other.\n\nRule 15 (Crossing): When two power-driven vessels cross, the vessel having the other on her STARBOARD side shall keep out of the way and avoid crossing ahead.',
      tip: 'Remember: On head-on meeting, both alter STARBOARD. Never cross ahead of a give-way vessel.',
      gradientColors: const [Color(0xFF0F172A), Color(0xFF1E3A8A)],
    ),
    FlashcardData(
      id: 'fc_2',
      category: 'Oily Water Separator (OWS)',
      categoryIcon: Icons.water_drop,
      question: 'Explain the working of 15 PPM Bilge Alarm Monitor and 3-Way Valve.',
      answer: 'The 15 PPM Bilge Alarm continuously samples oily water discharge using light scattering sensors. If oil concentration exceeds 15 PPM, the monitor triggers an alarm and energizes the 3-way solenoid valve to immediately stop overboard discharge and divert water back to the bilge holding tank.',
      tip: 'Key MARPOL Annex I requirement: 15 PPM max discharge with auto-stopping device.',
      gradientColors: const [Color(0xFF064E3B), Color(0xFF0D9488)],
    ),
    FlashcardData(
      id: 'fc_3',
      category: 'Fire Fighting & Safety',
      categoryIcon: Icons.local_fire_department,
      question: 'What is the Fire Tetrahedron and its 4th component?',
      answer: 'The Fire Tetrahedron represents the 4 essential elements needed for combustion:\n1. Fuel\n2. Heat\n3. Oxygen\n4. Uninhibited Chemical Chain Reaction (4th Component).\n\nExtinguishing agents like Halon & Dry Powder work by interrupting this chemical chain reaction.',
      tip: 'Traditional triangle only had Fuel, Heat, Oxygen. Tetrahedron adds the chemical reaction.',
      gradientColors: const [Color(0xFF4C1D95), Color(0xFF7C3AED)],
    ),
    FlashcardData(
      id: 'fc_4',
      category: 'Auxiliary Machinery',
      categoryIcon: Icons.precision_manufacturing,
      question: 'What happens if you start a Centrifugal Pump vs Positive Displacement Pump with discharge valve closed?',
      answer: 'Centrifugal Pump: Liquid churns inside casing; pressure rises to shutoff head. Can run closed briefly without instant damage.\n\nPositive Displacement Pump: Pressure rises continuously until safety relief valve opens or casing/piping ruptures. Discharge valve MUST ALWAYS BE OPEN before starting!',
      tip: 'Never start positive displacement pumps (gear, screw, piston) against a closed valve.',
      gradientColors: const [Color(0xFF7C2D12), Color(0xFFD97706)],
    ),
    FlashcardData(
      id: 'fc_5',
      category: 'Fresh Water Generator',
      categoryIcon: Icons.invert_colors,
      question: 'Why does seawater boil at ~45°C in a Vacuum Flash FWG?',
      answer: 'An air ejector creates high vacuum (~93% / 700 mmHg) inside the FWG shell. High vacuum significantly drops the boiling point of water from 100°C to approx 45°C, allowing seawater to evaporate using main engine jacket cooling water (65–80°C) as the heating source.',
      tip: 'Vacuum Flash FWG saves fuel by utilizing waste heat from engine cooling water.',
      gradientColors: const [Color(0xFF881337), Color(0xFFE11D48)],
    ),
    FlashcardData(
      id: 'fc_6',
      category: 'Personal HR Interview',
      categoryIcon: Icons.person_search,
      question: 'Why did you choose Merchant Navy over government or corporate shore jobs?',
      answer: 'Express genuine passion for global maritime trade, international exposure, disciplined lifestyle, exposure to advanced shipboard automation, hands-on operational leadership, and clear merit-based CoC career progression to Captain/Chief Engineer.',
      tip: 'Show confidence, physical resilience, and commitment to long sea contracts away from home.',
      gradientColors: const [Color(0xFF083344), Color(0xFF0284C7)],
    ),
    FlashcardData(
      id: 'fc_7',
      category: 'SOLAS & LSA Regulations',
      categoryIcon: Icons.shield,
      question: 'What are the SOLAS drill intervals and EPIRB distress frequencies?',
      answer: 'SOLAS Drills: Abandon ship drill and fire drill must be conducted EVERY MONTH (or within 24h of port departure if >25% crew changed).\n\nEPIRB Frequencies: Transmits 406 MHz digital signal to Cospas-Sarsat satellites and 121.5 MHz homing signal for search and rescue aircraft.',
      tip: 'EPIRB strobe light operates for at least 48 hours continuously.',
      gradientColors: const [Color(0xFF1E1B4B), Color(0xFF4338CA)],
    ),
    FlashcardData(
      id: 'fc_8',
      category: 'Oil Purifier & Clarifier',
      categoryIcon: Icons.settings_suggest,
      question: 'How do Gravity Disc and Blind Disc differ in Purifier vs Clarifier operation?',
      answer: 'Purifier: Uses a Gravity Disc (discharge collar) selected based on oil density to establish a water seal/interface between water and oil inside the bowl.\n\nClarifier: Has NO water outlet and uses a solid Blind Disc (sealing disc) to remove fine solid impurities from oil without water separation.',
      tip: 'If gravity disc size is wrong in purifier, oil will overflow from water outlet.',
      gradientColors: const [Color(0xFF451A03), Color(0xFFB45309)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleCardFlip(String id) {
    setState(() {
      if (_flippedCardIds.contains(id)) {
        _flippedCardIds.remove(id);
      } else {
        _flippedCardIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Navigation Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '🎴 Daily Revision Flashcards',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Tap any card to flip & reveal answer • Swipe to explore all cards',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (!isMobile)
              Row(
                children: [
                  IconButton.outlined(
                    onPressed: _currentIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    tooltip: 'Previous Card',
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: _currentIndex < _cards.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    tooltip: 'Next Card',
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Carousel Container
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _cards.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final card = _cards[index];
              final isFlipped = _flippedCardIds.contains(card.id);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _toggleCardFlip(card.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: card.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: card.gradientColors.last.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header: Category Badge + Flip Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(card.categoryIcon, size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    card.category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFlipped ? Icons.flip_to_back : Icons.flip_to_front,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Card Body: Question OR Answer
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isFlipped) ...[
                                  const Text(
                                    'QUESTION:',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    card.question,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      height: 1.35,
                                    ),
                                  ),
                                ] else ...[
                                  const Text(
                                    'MODEL ANSWER:',
                                    style: TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    card.answer,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (card.tip != null) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      '💡 Tip: ${card.tip}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 11.5,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            final uid = AuthService.instance.currentUser?.uid ?? 'guest';
                                            UserProgressRepository.instance.recordIncorrectAnswer(uid, card.id, card.category);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Added "${card.category}" to Review Section 📌'),
                                                duration: const Duration(seconds: 2),
                                                backgroundColor: AppColors.error,
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade900.withValues(alpha: 0.6),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Needs Review ❌',
                                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            final uid = AuthService.instance.currentUser?.uid ?? 'guest';
                                            UserProgressRepository.instance.recordCorrectAnswer(uid, card.id, card.category);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Marked "${card.category}" as Mastered! 🎉'),
                                                duration: const Duration(seconds: 2),
                                                backgroundColor: AppColors.success,
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade900.withValues(alpha: 0.6),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.check_circle_outline, size: 14, color: Colors.white),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Got It Right ✅',
                                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Card Footer Prompt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isFlipped ? 'Tap to see Question ↩️' : 'Tap to Reveal Answer 🔄',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${index + 1} / ${_cards.length}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Indicator Dots for mobile
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_cards.length, (index) {
              final isSelected = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isSelected ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.actionBlue : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
