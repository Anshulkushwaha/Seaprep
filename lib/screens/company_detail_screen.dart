import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/company.dart';
import '../theme/app_theme.dart';
import '../widgets/company_experiences_advice_widget.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Company company;
  final ValueChanged<Company> onProceedToPractice;
  final VoidCallback onBack;
  final VoidCallback? onOpenQuestionsScreen;

  const CompanyDetailScreen({
    super.key,
    required this.company,
    required this.onProceedToPractice,
    required this.onBack,
    this.onOpenQuestionsScreen,
  });

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen>
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
    final isMobile = screenWidth < 650;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: widget.onBack,
        ),
        title: Text(
          company.name,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.actionBlue,
              indicatorWeight: 3,
              labelColor: AppColors.actionBlue,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
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
        ),
      ),
      body: Column(
        children: [
          // Banner Top Profile Card
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompanyLogo(company),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.fullName,
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        company.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${company.questionCount} Questions Available',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.actionBlue,
                              ),
                            ),
                          ),
                          if (company.isRecommended)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, size: 12, color: Colors.orange),
                                  SizedBox(width: 4),
                                  Text(
                                    'Recommended',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Contents
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(company, isMobile),
                _buildHiringProcedureTab(company, isMobile),
              ],
            ),
          ),
        ],
      ),

      // Sticky Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(isMobile ? 'Back' : 'Back to Companies'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onOpenQuestionsScreen != null) {
                      widget.onOpenQuestionsScreen!();
                    } else {
                      widget.onProceedToPractice(company);
                    }
                  },
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: Text('Apply / Start Practice Questions (${company.questionCount})'),
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
        ),
      ),
    );
  }

  Widget _buildCompanyLogo(Company company) {
    if (company.logoUrl != null && company.logoUrl!.isNotEmpty) {
      final isAsset = company.logoUrl!.startsWith('assets/');
      return Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 31, 63, 0.08),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isAsset
              ? Image.asset(
                  company.logoUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallbackLogo(company),
                )
              : Image.network(
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
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Text(
        company.logoText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildAboutTab(Company company, bool isMobile) {
    final isZodiac = company.id == 'zodiac';

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company Profile & Overview',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isZodiac
                ? 'Zodiac Maritime Limited is an international ship management company headquartered in London, UK. Managing a modern, highly diversified fleet of over 180 ocean-going vessels, Zodiac is renowned worldwide for its technical excellence, strict maritime safety culture, and comprehensive cadet development programs.'
                : company.description,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Fleet & Global Operations',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.directions_boat_outlined,
            'Operating Fleet Types',
            isZodiac
                ? 'Ultra Large Container Ships, Crude & Product Tankers, LPG Carriers, Dry Bulk Carriers, PCTCs'
                : '${company.category}, General Cargo & Chemical Tanker Fleets',
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Global Headquarters',
            isZodiac ? 'London, United Kingdom' : 'Global Shipping Hub',
          ),
          _buildInfoRow(
            Icons.verified_user_outlined,
            'Safety & Vetting Accreditation',
            'ISO 9001 / 14001, ISM Code Certified, ClassNK Grade A1, SIRE Vetting Approved',
          ),
          const SizedBox(height: 24),
          const Text(
            'Cadet & Officer Eligibility Criteria',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletItem('IMU-CET Rank / DG Shipping Approved Pre-Sea Training Institute Registration'),
          _buildBulletItem('Minimum 60% Aggregate in PCM (Physics, Chemistry, Mathematics) in Class 12th'),
          _buildBulletItem('DG Shipping Approved Medical Fitness & Eyesight (6/6 color vision)'),
          _buildBulletItem('Strong Fundamentals in COLREGs, Emergency Procedures, Machinery & Seamanship'),
        ],
      ),
    );
  }

  Widget _buildHiringProcedureTab(Company company, bool isMobile) {
    final isZodiac = company.id == 'zodiac';
    final nameStr = company.name;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Procedure of Hiring for $nameStr',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Follow the 4 mandatory steps below to prepare for recruitment and sponsorship at $nameStr:',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

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
                SizedBox(height: 10),
                Text(
                  'Shortlisting Criteria:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                SizedBox(height: 4),
                Text('• Academic minimum 60% in PCM in Class 12th.', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                Text('• Valid Indian passport & IMU CET rank scorecard.', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onOpenQuestionsScreen != null) {
                      widget.onOpenQuestionsScreen!();
                    } else {
                      setState(() {
                        _showTechnicalQuestions = !_showTechnicalQuestions;
                      });
                    }
                  },
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: const Text(
                    'See Previously Asked Technical Questions',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                if (_showTechnicalQuestions) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.actionBlue.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.help_outline, color: AppColors.actionBlue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Technical Questions Previously Asked by $nameStr Interviewers:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (company.id == 'nyk') ...[
                          _buildTechnicalQuestionItem(
                            '1. Automobile vs Marine Engine: Key differences in environment, load, and safety.',
                            'Marine engines operate in harsh saltwater with closed-loop freshwater/seawater heat exchangers, continuous heavy load (80-90% MCR), HFO/VLSFO fuel, and SOLAS safety redundancy.',
                          ),
                          _buildTechnicalQuestionItem(
                            '2. IC Engine Classification: How are internal combustion engines classified?',
                            'By cycle (2-stroke/4-stroke), ignition (SI/CI), layout (inline/V/opposed), speed (low/medium/high), and construction (trunk piston/crosshead).',
                          ),
                          _buildTechnicalQuestionItem(
                            '3. Spark Plug vs Fuel Injector: Differences, location, and purpose.',
                            'Spark plug creates electrical spark in petrol/gas SI engines. Fuel injector atomizes fuel under high hydraulic pressure into compressed hot air in diesel CI engines.',
                          ),
                          _buildTechnicalQuestionItem(
                            '4. Electric Motor Classification: How are electric motors categorized?',
                            'AC Motors (Squirrel Cage Induction, Slip Ring, Synchronous) and DC Motors (Series, Shunt, Compound) plus BLDC/Servo motors for actuators.',
                          ),
                          _buildTechnicalQuestionItem(
                            '5. Diesel Injection & 4-Stroke Timing: Injection timing & valve timing diagram.',
                            'Injection starts 10-25° BTDC on compression stroke. Valve overlap occurs at TDC with both inlet and exhaust valves open for cylinder scavenging.',
                          ),
                          _buildTechnicalQuestionItem(
                            '6. Apparent Slip: Definition, formula, and significance.',
                            'Apparent Slip % = [(Theoretical Distance - Observed Distance) / Theoretical Distance] x 100. Accounts for current, wind, and hull fouling.',
                          ),
                          _buildTechnicalQuestionItem(
                            '7. Purifier Principle & HFO/MDO Separation: Can HFO & MDO be separated?',
                            'Purifier uses centrifugal G-force to separate immiscible liquids (water & oil) + solids. NO, HFO and MDO cannot be separated as they are miscible hydrocarbons.',
                          ),
                          _buildTechnicalQuestionItem(
                            '8. Generator Auxiliary Engines: Are they standard 4-stroke diesels?',
                            'Yes, 4-stroke trunk piston diesels adapted with constant-speed governors (720/1000/1500 RPM), HFO preheating, and double-walled fuel lines with leak alarms.',
                          ),
                          _buildTechnicalQuestionItem(
                            '9. 4-Stroke Engines on Ships: Where and why are they used?',
                            'Used for auxiliary diesel generators & propulsion on cruise/ferries due to compact headroom, high power-to-weight ratio, and flexible generator set loading.',
                          ),
                          _buildTechnicalQuestionItem(
                            '10. Fire Emergency Scenario: Generator fire steps, CO2 selection, and F.I.R.E. protocol.',
                            'Sound alarm, inform bridge, trip emergency stop & fuel QCV, isolate breaker. Select CO2 (no residue/windings damage). F.I.R.E. = Find, Inform, Restrict, Extinguish.',
                          ),
                          _buildTechnicalQuestionItem(
                            '11. Archimedes\' Principle: State principle and maritime application.',
                            'Submerged body experiences upward buoyant force equal to displaced fluid weight (Fb = ρVg). Explains vessel buoyancy and flotation.',
                          ),
                          _buildTechnicalQuestionItem(
                            '12. Speed of Sound: Air vs Water propagation differences.',
                            'Air: ~343 m/s; Seawater: ~1500 m/s (4.5x faster). Water molecules are tightly packed with higher bulk modulus, transferring sound waves faster.',
                          ),
                        ] else ...[
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
                          _buildTechnicalQuestionItem(
                            '9. Fresh Water Generator (FWG): Vacuum Flash FWG working principle.',
                            'Operates under 93% vacuum (700 mmHg) lowering seawater boiling point to ~45°C using main engine jacket cooling water (65-80°C) as heat source.',
                          ),
                          _buildTechnicalQuestionItem(
                            '10. Engine Components: What is a Rocker Arm and its function?',
                            'Pivoting lever that receives motion from pushrod/hydraulic pressure and depresses intake/exhaust valves to open against spring tension.',
                          ),
                          _buildTechnicalQuestionItem(
                            '11. Engine Basics: 4-Stroke vs 2-Stroke engine differences.',
                            '4-Stroke: 1 power cycle per 4 strokes (720° crank rotation) with valves. 2-Stroke: 1 power cycle per 2 strokes (360° crank rotation) with scavenge ports.',
                          ),
                          _buildTechnicalQuestionItem(
                            '12. Safety Equipment: MOB Marker specifications & release mechanism.',
                            'Bridge wing lifebuoy marker emitting dense orange smoke for at least 15 mins and 2-candela light for at least 2 hours to mark casualty position.',
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onProceedToPractice(company),
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: Text('Apply / Start Full Practice for $nameStr'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
          const SizedBox(height: 24),

          // Multi-Company Alumni Experiences & Advice Hub Option
          CompanyExperiencesAdviceWidget(currentCompanyId: company.id),

          const SizedBox(height: 24),

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
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '• Benchmark Score Required: 85%+ overall (Minimum 80% in listening & grammar).',
                    style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(
                        'https://www.youtube.com/watch?v=ISEXtR5OJ_E&list=PLQlGMC_E3fJZN57FShWALavihaSttAGfK');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.play_circle_fill, color: Colors.red, size: 20),
                  label: const Text('Open Marlins Test Preparation Playlist'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4th Step: Final Result
          _buildStepCard(
            stepNumber: 4,
            title: 'Final Result & Sponsorship Letter',
            badgeText: '4th Step — Final Result',
            description:
                'Publication of selection merit list, DG Shipping medical examination clearance, CDC & passport verification, and issuance of Official Cadet Sponsorship Letter / Employment Contract.',
            contentWidget: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '• Final Step: Pre-sea medical clearance & signing of cadet agreement before vessel join call.',
                style: TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalQuestionItem(String qText, String ansText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            qText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Ans: $ansText',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.35,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.actionBlue.withValues(alpha: 0.06)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? AppColors.actionBlue : AppColors.outlineVariant,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
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
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
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
                          fontSize: 15,
                          color: highlight ? AppColors.actionBlue : AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: highlight
                            ? AppColors.actionBlue.withValues(alpha: 0.15)
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: highlight ? AppColors.actionBlue : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.actionBlue),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
