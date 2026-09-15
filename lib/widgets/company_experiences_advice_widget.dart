import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CompanyExperienceItem {
  final String id;
  final String companyId;
  final String companyName;
  final String authorName;
  final String rank;
  final String year;
  final String experienceSummary;
  final List<String> keyAdvice;
  final double rating;

  const CompanyExperienceItem({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.authorName,
    required this.rank,
    required this.year,
    required this.experienceSummary,
    required this.keyAdvice,
    this.rating = 5.0,
  });
}

class CompanyExperiencesAdviceWidget extends StatefulWidget {
  final String? currentCompanyId;

  const CompanyExperiencesAdviceWidget({
    super.key,
    this.currentCompanyId,
  });

  @override
  State<CompanyExperiencesAdviceWidget> createState() =>
      _CompanyExperiencesAdviceWidgetState();
}

class _CompanyExperiencesAdviceWidgetState
    extends State<CompanyExperiencesAdviceWidget> {
  String _selectedCompanyFilter = 'All';

  final List<CompanyExperienceItem> _allExperiences = const [
    CompanyExperienceItem(
      id: 'exp_1',
      companyId: 'comp_synergy',
      companyName: 'Synergy Marine Group',
      authorName: 'Cadet Rahul Nair',
      rank: 'Deck Cadet',
      year: '2025 Intake',
      rating: 5.0,
      experienceSummary:
          'The Synergy technical panel focused 70% on COLREGs Rule 14 & 15 scenario diagrams and 30% on OWS 15 PPM solenoid valve logic. They asked me to draw a crossing situation on paper and state give-way obligations clearly.',
      keyAdvice: [
        'State COLREG Rule numbers and exact wording accurately.',
        'Be thorough with OWS Bilge Alarm 3-way valve recirculation logic.',
        'Maintain clear, confident communication when explaining emergency steering changeover.',
      ],
    ),
    CompanyExperienceItem(
      id: 'exp_2',
      companyId: 'comp_anglo_eastern',
      companyName: 'Anglo-Eastern (AEMA)',
      authorName: 'Eng. Ankit Sharma',
      rank: 'GME Cadet',
      year: '2026 Intake',
      rating: 5.0,
      experienceSummary:
          'AEMA superintendents tested practical safety awareness and IC Engine fundamentals. They asked me the exact differences between a Purifier and a Clarifier, and the step-by-step procedure during a Scavenge Fire.',
      keyAdvice: [
        'Understand the function of the Gravity Disc (Dam Ring) in purifiers.',
        'Memorize the SOLAS 45-second emergency generator auto-start rule.',
        'Demonstrate an uncompromising safety-first mindset throughout the panel round.',
      ],
    ),
    CompanyExperienceItem(
      id: 'exp_3',
      companyId: 'comp_fleet_mgmt',
      companyName: 'Fleet Management Ltd. (FML)',
      authorName: 'Cadet Vikram Das',
      rank: 'Deck Cadet',
      year: '2025 Intake',
      rating: 4.8,
      experienceSummary:
          'FML interviewers tested both Deck and Engine basics. Questions included Archimedes principle, centrifugal pump cavitation, and MARPOL Annex V plastic dumping regulations.',
      keyAdvice: [
        'Never guess an answer; if unsure, clearly state your underlying safety principles.',
        'Memorize MARPOL Annexes I to VI discharge distance limits.',
        'Prepare thoroughly for the Marlins English test benchmark (85%+ required).',
      ],
    ),
    CompanyExperienceItem(
      id: 'exp_4',
      companyId: 'bw',
      companyName: 'BW Group / BW LPG',
      authorName: 'Cadet Siddharth Mehta',
      rank: 'Engine Cadet',
      year: '2026 Intake',
      rating: 5.0,
      experienceSummary:
          'BW Group technical interviewers placed high emphasis on gas carrier safety, Inert Gas System (IGS) deck water seal operation, and SOLAS LSA immersion suit donning procedures.',
      keyAdvice: [
        'Understand Inert Gas System <8% oxygen limits inside cargo tanks.',
        'Explain lifeboat fall wire 5-year renewal and end-for-ending rules.',
        'Highlight personal commitment to environmental protection and ESG values.',
      ],
    ),
    CompanyExperienceItem(
      id: 'exp_5',
      companyId: 'nyk',
      companyName: 'NYK Line',
      authorName: 'Cadet Priya Patel',
      rank: 'Deck Cadet',
      year: '2025 Intake',
      rating: 4.9,
      experienceSummary:
          'NYK superintendents evaluated technical fundamentals (4-stroke vs 2-stroke diesel timing), apparent slip formula, and situational decision-making under stress.',
      keyAdvice: [
        'Be ready to explain apparent slip formula and its practical sea significance.',
        'Practice drawing fuel injector and governor control diagrams.',
        'Maintain fluent English communication during HR situational questions.',
      ],
    ),
    CompanyExperienceItem(
      id: 'exp_6',
      companyId: 'zodiac',
      companyName: 'Zodiac Maritime',
      authorName: 'Cadet Rohan Verma',
      rank: 'Deck / Engine',
      year: '2025 Intake',
      rating: 5.0,
      experienceSummary:
          'Zodiac interviewers focused heavily on COLREGs sound signals, NUC lights/shapes, and emergency blackout recovery steps on main switchboards.',
      keyAdvice: [
        'Know all COLREG sound signals (Rule 34 & 35) by heart.',
        'Explain blackout recovery sequence step-by-step without skipping safety steps.',
        'Show enthusiasm for long sea voyages and multi-cultural fleet teamwork.',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.currentCompanyId != null) {
      _selectedCompanyFilter = widget.currentCompanyId!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExperiences = _allExperiences.where((exp) {
      if (_selectedCompanyFilter == 'All') return true;
      return exp.companyId.toLowerCase().contains(_selectedCompanyFilter.toLowerCase()) ||
          exp.companyName.toLowerCase().contains(_selectedCompanyFilter.toLowerCase());
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.actionBlue.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.actionBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.forum_rounded,
                        color: AppColors.actionBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alumni Interview Experiences & Advice',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Real interview experiences & tips shared by placed cadets across top shipping lines',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showShareExperienceModal,
                icon: const Icon(Icons.add_comment_rounded, size: 16),
                label: const Text('Share Advice', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Company Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'All Companies'),
                const SizedBox(width: 8),
                _buildFilterChip('synergy', 'Synergy'),
                const SizedBox(width: 8),
                _buildFilterChip('anglo', 'Anglo-Eastern'),
                const SizedBox(width: 8),
                _buildFilterChip('fleet', 'Fleet Mgmt'),
                const SizedBox(width: 8),
                _buildFilterChip('bw', 'BW Group'),
                const SizedBox(width: 8),
                _buildFilterChip('nyk', 'NYK Line'),
                const SizedBox(width: 8),
                _buildFilterChip('zodiac', 'Zodiac'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Experiences List
          if (filteredExperiences.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                'No student experiences available for this company filter yet.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredExperiences.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final exp = filteredExperiences[index];
                return _buildExperienceCard(exp);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String companyKey, String label) {
    final isSelected = _selectedCompanyFilter.toLowerCase() == companyKey.toLowerCase();
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.primary,
      ),
      backgroundColor: AppColors.surfaceContainerLow,
      selectedColor: AppColors.actionBlue,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.actionBlue : AppColors.outlineVariant,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCompanyFilter = companyKey;
        });
      },
    );
  }

  Widget _buildExperienceCard(CompanyExperienceItem exp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Author Name, Rank, Company Badge
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                radius: 18,
                child: Text(
                  exp.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          exp.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            exp.rank,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${exp.companyName} • ${exp.year}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 14,
                    color: Colors.amber.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Experience Summary
          Text(
            '"${exp.experienceSummary}"',
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Key Advice Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.actionBlue.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 16, color: AppColors.actionBlue),
                    SizedBox(width: 6),
                    Text(
                      'Key Interview Advice & Tips:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.actionBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...exp.keyAdvice.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.actionBlue)),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShareExperienceModal() {
    final companyController = TextEditingController();
    final adviceController = TextEditingController();
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Share Your Interview Experience & Advice',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Help fellow cadets prepare by sharing your shipping line interview experience and top 3 advice points.',
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name & Rank (e.g. Cadet Amit Sharma - Deck)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(
                  labelText: 'Shipping Line (e.g. Synergy / Anglo-Eastern / FML)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adviceController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Interview Experience & Advice Tips',
                  hintText: 'Describe the panel questioning style, key topics tested, and top advice for candidates...',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you! Your interview experience has been submitted for community review.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Submit Advice & Experience'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
