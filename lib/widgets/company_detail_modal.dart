import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/company.dart';
import '../theme/app_theme.dart';
import 'company_experiences_advice_widget.dart';

class CompanyDetailModal extends StatefulWidget {
  final Company company;
  final ValueChanged<Company> onProceedToPractice;
  final VoidCallback? onOpenQuestionsScreen;

  const CompanyDetailModal({
    super.key,
    required this.company,
    required this.onProceedToPractice,
    this.onOpenQuestionsScreen,
  });

  static void show(
    BuildContext context, {
    required Company company,
    required ValueChanged<Company> onProceedToPractice,
    VoidCallback? onOpenQuestionsScreen,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CompanyDetailModal(
        company: company,
        onProceedToPractice: onProceedToPractice,
        onOpenQuestionsScreen: onOpenQuestionsScreen,
      ),
    );
  }

  @override
  State<CompanyDetailModal> createState() => _CompanyDetailModalState();
}

class _CompanyDetailModalState extends State<CompanyDetailModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showTechnicalQuestions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final company = widget.company;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Container(
        width: isMobile ? double.infinity : 660,
        height: isMobile ? 580 : 640,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header (Logo + Company Name + Category Badges)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompanyLogo(company),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        company.fullName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              company.category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${company.questionCount} Questions',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.actionBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Bar Switcher (About vs Procedure for Hiring)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.actionBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13),
                padding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 18),
                        SizedBox(width: 8),
                        Text('About Company'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Procedure of Hiring'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab View Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAboutTab(company),
                  _buildHiringProcedureTab(company),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons Footer
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onProceedToPractice(company);
                    },
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: const Text('Practice Technical Questions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.actionBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyLogo(Company company) {
    if (company.logoUrl != null && company.logoUrl!.isNotEmpty) {
      return Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 31, 63, 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            company.logoUrl!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackLogo(company),
          ),
        ),
      );
    }
    return _buildFallbackLogo(company);
  }

  Widget _buildFallbackLogo(Company company) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Text(
        company.logoText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildAboutTab(Company company) {
    final isZodiac = company.id == 'zodiac';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company Overview',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isZodiac
                ? 'Zodiac Maritime Limited is an international ship management company headquartered in London, UK. Managing a modern, highly diversified fleet of over 180 ocean-going vessels, Zodiac is renowned for its technical excellence, strict maritime safety culture, and cadet development programs.'
                : company.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Fleet & Operations',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.directions_boat_outlined,
            'Vessel Fleet Types',
            isZodiac
                ? 'Container Ships, Crude/Product Tankers, LPG Carriers, Dry Bulk Carriers, PCTCs'
                : '${company.category}, General Cargo & Chemical Carriers',
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Headquarters',
            isZodiac ? 'London, United Kingdom' : 'Global Shipping Network',
          ),
          _buildInfoRow(
            Icons.verified_user_outlined,
            'Safety & Vetting Standard',
            'ISO 9001 / 14001, ISM Code Compliant, SIRE Vetting Approved',
          ),
          const SizedBox(height: 16),
          const Text(
            'Cadet & Officer Eligibility',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletItem('IMU-CET Rank / DG Shipping Approved Pre-Sea Training'),
          _buildBulletItem('Minimum 60% Aggregate in PCM (Physics, Chemistry, Maths)'),
          _buildBulletItem('DG Shipping Approved Medical Fitness & Eyesight (6/6 color vision)'),
          _buildBulletItem('Strong Fundamentals in COLREGs, Emergency Procedures, & Seamanship'),
        ],
      ),
    );
  }

  Widget _buildHiringProcedureTab(Company company) {
    final isZodiac = company.id == 'zodiac';
    final nameStr = company.name;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Procedure of Hiring for $nameStr',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Follow the 4 mandatory steps below to prepare for recruitment at $nameStr:',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // 1st Step: Shortlisting
          _buildStepCard(
            stepNumber: 1,
            title: 'Shortlisting & Eligibility Verification',
            badgeText: '1st Step',
            description:
                'Initial screening based on IMU-CET rank, academic scores (PCM 60%+), pre-sea training institute records, and resume application vetting.',
            contentWidget: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  'Key Shortlisting Requirements:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                SizedBox(height: 4),
                Text('• Academic minimum 60% in PCM in Class 12th.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                Text('• Valid passport & IMU CET rank scorecard.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2nd Step: Interview (WITH TECHNICAL QUESTIONS OPTION!)
          _buildStepCard(
            stepNumber: 2,
            title: 'Technical & HR Interview',
            badgeText: '2nd Step — Core Stage',
            highlight: true,
            description: isZodiac
                ? 'Technical oral interview conducted by Zodiac Marine Superintendents & Captains evaluating COLREGs, Emergency Procedures, Machinery, and Safety.'
                : 'Technical oral examination with Senior Marine Captains / Chief Engineers evaluating technical knowledge, emergency response, and watchkeeping.',
            contentWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (widget.onOpenQuestionsScreen != null) {
                            Navigator.of(context).pop();
                            widget.onOpenQuestionsScreen!();
                          } else {
                            setState(() {
                              _showTechnicalQuestions = !_showTechnicalQuestions;
                            });
                          }
                        },
                        icon: const Icon(Icons.menu_book, size: 16),
                        label: const Text(
                          'See Previously Asked Technical Questions',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.actionBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showTechnicalQuestions) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.actionBlue.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.help_outline, color: AppColors.actionBlue, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Technical Questions Previously Asked by $nameStr Interviewers:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildTechnicalQuestionItem(
                          '1. Personal & HR: Why Merchant Navy over government jobs & strengths/weaknesses?',
                          'Express passion for maritime navigation/engineering, disciplined work culture, cutting-edge technology, and CoC career progression.',
                        ),
                        _buildTechnicalQuestionItem(
                          '2. PPE & Height Safety: What specific PPE must be worn while climbing a ladder or mast?',
                          'Safety harness with double lanyards hooked above waist level, helmet with chin strap, non-slip safety boots, gloves, and boiler suit.',
                        ),
                        _buildTechnicalQuestionItem(
                          '3. Oily Water Separator (OWS): Explain working of OWS and 15 PPM monitor.',
                          'OWS uses gravity separation & coalescer filters. 15 PPM monitor continuously tests discharge; if >15 PPM, 3-way valve recirculates to bilge tank.',
                        ),
                        _buildTechnicalQuestionItem(
                          '4. Purifier vs Clarifier: Explain in-depth working & fundamental differences.',
                          'Purifier: Separates 2 liquids of different densities (water & fuel) + solids using gravity disc. Clarifier: Separates fine solids from liquid using blind disc.',
                        ),
                        _buildTechnicalQuestionItem(
                          '5. Marine Pumps: Closing discharge valve on Centrifugal vs Positive Displacement pump?',
                          'Centrifugal: Pressure rises to shutoff head (can run closed briefly). Positive Displacement: Pressure rises until relief valve opens or casing ruptures (NEVER start closed).',
                        ),
                        _buildTechnicalQuestionItem(
                          '6. Refrigeration System: Explain 4 main components & Expansion Valve function.',
                          '4 components: Compressor, Condenser, Expansion Valve, Evaporator. Expansion valve meters refrigerant flow and drops pressure to enable evaporation.',
                        ),
                        _buildTechnicalQuestionItem(
                          '7. Fire Fighting: Fire Tetrahedron 4th component & Extinguisher systems.',
                          'Fire Tetrahedron 4th component: Chemical Chain Reaction. Onboard systems: Hyper-mist (local machinery), Bulk CO₂ (flooding), High-Expansion Foam.',
                        ),
                        _buildTechnicalQuestionItem(
                          '8. Turbocharger: Explain working principle & major components.',
                          'Exhaust gas drives turbine wheel which rotates centrifugal compressor wheel on common shaft to deliver high-density scavenge air to engine.',
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onProceedToPractice(company);
                            },
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: Text('Apply / Start Full Practice for $nameStr'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Multi-Company Alumni Experiences & Advice Hub Option
          CompanyExperiencesAdviceWidget(currentCompanyId: company.id),

          const SizedBox(height: 20),

          // 3rd Step: Marlin Test
          _buildStepCard(
            stepNumber: 3,
            title: 'Marlins English Test',
            badgeText: '3rd Step — Language Test',
            description:
                'Standardized Marlins English evaluation for seafarers assessing maritime vocabulary, listening comprehension, grammar, time & numbers, and pronunciation required by $nameStr.',
            contentWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    '• Benchmark Score Required: 85%+ overall (Minimum 80% in listening & grammar).',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(
                        'https://www.youtube.com/watch?v=ISEXtR5OJ_E&list=PLQlGMC_E3fJZN57FShWALavihaSttAGfK');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.play_circle_fill, color: Colors.red, size: 18),
                  label: const Text('Open Marlins Test Preparation Playlist'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4th Step: Final Result
          _buildStepCard(
            stepNumber: 4,
            title: 'Final Result & Sponsorship Letter',
            badgeText: '4th Step — Final Result',
            description:
                'Publication of selection merit list, DG Shipping medical examination clearance, CDC & passport verification, and issuance of Official Cadet Sponsorship Letter / Employment Contract.',
            contentWidget: const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                '• Final Step: Pre-sea medical clearance & signing of cadet agreement before vessel join call.',
                style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalQuestionItem(String qText, String ansText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            qText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Ans: $ansText',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String description,
    required String badgeText,
    bool highlight = false,
    Widget? contentWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.actionBlue.withValues(alpha: 0.06)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? AppColors.actionBlue : AppColors.outlineVariant,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: highlight ? AppColors.actionBlue : AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: highlight ? AppColors.actionBlue : AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: highlight
                            ? AppColors.actionBlue.withValues(alpha: 0.15)
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: highlight ? AppColors.actionBlue : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                if (contentWidget != null) contentWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.actionBlue),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
