import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';

class CompanyQuestionsScreen extends StatefulWidget {
  final Company company;
  final VoidCallback onBack;
  final ValueChanged<Company> onProceedToPractice;

  const CompanyQuestionsScreen({
    super.key,
    required this.company,
    required this.onBack,
    required this.onProceedToPractice,
  });

  @override
  State<CompanyQuestionsScreen> createState() => _CompanyQuestionsScreenState();
}

class _CompanyQuestionsScreenState extends State<CompanyQuestionsScreen> {
  String _searchQuery = '';
  final Set<String> _expandedIds = {};

  List<QuestionItem> get _companyQuestions {
    String targetCategory;
    if (widget.company.id == 'nyk') {
      targetCategory = 'NYK Line Real Interview Questions';
    } else {
      targetCategory = 'Zodiac Maritime Real Interview Questions';
    }

    var questions = QuestionItem.allPDFQuestions
        .where((q) => q.category == targetCategory)
        .toList();

    if (questions.isEmpty) {
      questions = QuestionItem.allPDFQuestions
          .where((q) => q.category == 'Zodiac Maritime Real Interview Questions')
          .toList();
    }

    if (_searchQuery.trim().isEmpty) {
      return questions;
    }

    final query = _searchQuery.toLowerCase();
    return questions.where((q) {
      return q.question.toLowerCase().contains(query) ||
          q.answer.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final company = widget.company;
    final isMobile = MediaQuery.of(context).size.width < 768;
    final questions = _companyQuestions;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Column(
        children: [
          // Header Bar
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 31, 63, 0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  tooltip: 'Back to Company Overview',
                ),
                const SizedBox(width: 8),
                if (company.logoUrl != null && company.logoUrl!.isNotEmpty)
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.outlineVariant),
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
                  )
                else
                  _buildFallbackLogo(company),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${company.name} — Technical Interview Questions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 16 : 20,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.actionBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.actionBlue.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              '${questions.length} Real Questions',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.actionBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Authentic questions previously asked by Zodiac Marine Superintendents & Captains (Shashi Shekhar Singh Experience)',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Scrollable Area
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search questions, keywords (e.g. OWS, Purifier, Pumps, PPE, Turbocharger)...',
                        prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Notice Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.actionBlue.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.actionBlue.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified, color: AppColors.actionBlue, size: 24),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'These technical questions were directly asked during real Zodiac Maritime cadet sponsorship interviews. Master each answer before your interview!',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Question Cards List
                  if (questions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No questions match "$_searchQuery"',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: questions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = questions[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 31, 63, 0.03),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              onExpansionChanged: (_) => _toggleExpand(item.id),
                              leading: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.actionBlue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.actionBlue,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                item.question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  height: 1.3,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Divider(color: AppColors.outlineVariant),
                                      const SizedBox(height: 8),

                                      // Answer Header
                                      const Row(
                                        children: [
                                          Icon(Icons.check_circle_outline,
                                              size: 16, color: AppColors.success),
                                          SizedBox(width: 6),
                                          Text(
                                            'Detailed Model Answer:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.answer,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: AppColors.onSurface,
                                        ),
                                      ),

                                      // Pro Interview Tip (If available)
                                      if (item.interviewTip != null &&
                                          item.interviewTip!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.outlineVariant),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.lightbulb_outline,
                                                  size: 16, color: Colors.orange),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Interviewer Advice: ${item.interviewTip}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.onSurfaceVariant,
                                                    fontStyle: FontStyle.italic,
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: const BoxDecoration(
          color: Colors.white,
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
                label: const Text('Back to Zodiac Details'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onProceedToPractice(company),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Start Full Practice Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackLogo(Company company) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Center(
        child: Text(
          company.logoText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
