import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../models/question.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_progress_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_progress_gauge.dart';
import '../widgets/flashcards_carousel.dart';
import '../widgets/updates_section_widget.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onResumePractice;
  final Function(String? companyId)? onOpenCompanyDetail;

  const DashboardScreen({
    super.key,
    required this.onResumePractice,
    this.onOpenCompanyDetail,
  });

  void _showTopicReviewModal(
      BuildContext context, String uid, UserProgressModel progress) {
    final incorrectQuestionIds = progress.incorrectQuestionIds;
    final reviewTopics = progress.reviewTopics;

    final matchingQuestions = QuestionItem.allPDFQuestions.where((q) {
      return incorrectQuestionIds.contains(q.id) ||
          reviewTopics.contains(q.category);
    }).toList();

    final allAvailableTopics = [
      '1. Emergency & Safety',
      '2. COLREG Rules',
      '3. Navigation & Seamanship',
      '4. Oily Water Separator (OWS)',
      '5. Ship Stability',
      '6. MLC 2006 & Maritime Labour',
      '7. LSA & FFA Regulations',
      '8. Auxiliary Machinery & Pumps',
      '9. Personal & HR Questions',
      '10. Maritime Abbreviations & Full Forms',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.error, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Weak Topics & Review Summary',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Names of topics where your score requires attention based on quiz, flashcard, and practice attempts.',
                style:
                    TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),

              // Active Weak Topics Header & Chips
              if (reviewTopics.isNotEmpty) ...[
                const Text(
                  '🚩 Topics Needing Immediate Attention:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: reviewTopics.map((topic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 16, color: AppColors.error),
                          const SizedBox(width: 6),
                          Text(
                            topic,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              UserProgressRepository.instance
                                  .removeWeakTopic(uid, topic);
                              Navigator.pop(ctx);
                            },
                            child: const Icon(Icons.close,
                                size: 16, color: AppColors.error),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.actionBlue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Topics Analyzed for Review',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Below are all standard interview topics evaluated for performance:',
                        style: TextStyle(
                            fontSize: 12.5, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allAvailableTopics.map((topic) {
                          final isWeak = reviewTopics.contains(topic);
                          return InkWell(
                            onTap: () {
                              if (isWeak) {
                                UserProgressRepository.instance
                                    .removeWeakTopic(uid, topic);
                              } else {
                                UserProgressRepository.instance
                                    .addWeakTopic(uid, topic);
                              }
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isWeak
                                    ? Colors.red.shade50
                                    : AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isWeak
                                      ? AppColors.error
                                      : AppColors.outlineVariant,
                                ),
                              ),
                              child: Text(
                                topic,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isWeak
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isWeak
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Text(
                'Flagged Questions for Review:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: matchingQuestions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 56, color: Colors.green.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No specific questions flagged!',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Take an MCQ quiz or practice questions to flag any answers needing review.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: matchingQuestions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final q = matchingQuestions[idx];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppColors.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    q.category,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  q.question,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Answer: ${q.answer}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      UserProgressRepository.instance
                                          .recordCorrectAnswer(
                                              uid, q.id, q.category);
                                      Navigator.pop(ctx);
                                    },
                                    icon: const Icon(Icons.check_circle,
                                        size: 16, color: Colors.green),
                                    label: const Text('Mark Mastered'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close Review'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final uid = user?.uid ?? 'guest';
    
    // Listen to repository updates
    return AnimatedBuilder(
      animation: UserProgressRepository.instance,
      builder: (context, _) {
        final progressModel = UserProgressRepository.instance.getUserProgress(uid);
        final stats = UserProgressRepository.instance.getDashboardStats(uid);
        final screenWidth = MediaQuery.of(context).size.width;
        final isWide = screenWidth >= 800;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Header
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome, ${user?.displayName ?? 'Cadet'}. Your personal preparation overview.',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Bento Top Area: Readiness Gauge Card + Stats Stack
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildReadinessCard(stats),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 4,
                      child: _buildStatsStack(stats),
                    ),
                  ],
                )
              else ...[
                _buildReadinessCard(stats),
                const SizedBox(height: 20),
                _buildStatsStack(stats),
              ],

              const SizedBox(height: 32),

              // App Team Updates Feature (Company News & Course Updates)
              UpdatesSectionWidget(
                onOpenCompanyDetail: onOpenCompanyDetail,
                onOpenPractice: onResumePractice,
              ),

              const SizedBox(height: 32),

              // Interactive Multi-Colored Revision Flashcards
              const FlashcardsCarouselWidget(),

              const SizedBox(height: 32),

              // Targeted Focus Areas Section
              const Text(
                'Targeted Focus Areas',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: _buildWeakAreasCard(
                            stats,
                            () => _showTopicReviewModal(
                                context, uid, progressModel))),
                    const SizedBox(width: 20),
                    Expanded(child: _buildMasteredAreasCard(stats)),
                  ],
                )
              else ...[
                _buildWeakAreasCard(
                    stats,
                    () => _showTopicReviewModal(
                        context, uid, progressModel)),
                const SizedBox(height: 16),
                _buildMasteredAreasCard(stats),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadinessCard(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 480;

          final gaugeWidget = CircularProgressGauge(
            percentage: stats.readinessPercentage.toDouble(),
            size: 160,
            strokeWidth: 12,
            progressColor: stats.readinessPercentage > 0
                ? AppColors.actionBlue
                : AppColors.outlineVariant,
            backgroundColor: AppColors.surfaceContainerHigh,
            centerLabel: '${stats.readinessPercentage}%',
            centerSubtitle: 'Preparation',
          );

          final detailsWidget = Column(
            crossAxisAlignment:
                isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Overall Preparation',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stats.readinessPercentage > 0
                    ? 'You are actively building your readiness. Keep practicing questions and reviewing target companies to improve your score.'
                    : 'Your personal dashboard starts fresh. Start practicing interview questions and bookmarks to build your readiness score.',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: isNarrow ? WrapAlignment.center : WrapAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: onResumePractice,
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: const Text('Start Practice'),
                  ),
                ],
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              children: [
                gaugeWidget,
                const SizedBox(height: 20),
                detailsWidget,
              ],
            );
          } else {
            return Row(
              children: [
                gaugeWidget,
                const SizedBox(height: 0, width: 28),
                Expanded(child: detailsWidget),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildStatsStack(DashboardStats stats) {
    return Column(
      children: [
        _buildStatCard(
          'Questions Practiced',
          '${stats.questionsPracticed}',
          Icons.library_books,
          AppColors.secondaryFixed,
          AppColors.onSecondaryFixedVariant,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Bookmarked Questions',
          '${stats.bookmarkedCount}',
          Icons.bookmark_outline,
          AppColors.primaryContainer.withValues(alpha: 0.15),
          AppColors.primaryContainer,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Recruiting Companies',
          '6 Active',
          Icons.business,
          AppColors.surfaceContainerHigh,
          AppColors.actionBlue,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color bgIconColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgIconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakAreasCard(DashboardStats stats, VoidCallback onReview) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
              SizedBox(width: 8),
              Text(
                'ATTENTION REQUIRED',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (stats.weakAreas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No weak areas flagged yet. Complete mock tests to analyze focus topics.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            )
          else
            ...stats.weakAreas.map((topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildProgressBar(
                    topic.title,
                    topic.percentage,
                    topic.percentage < 55 ? AppColors.error : AppColors.warning,
                  ),
                )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onReview,
              child: const Text('Review Topics'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteredAreasCard(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
              SizedBox(width: 8),
              Text(
                'MASTERED SUBJECTS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (stats.masteredSubjects.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No mastered subjects yet. Complete practice questions to log progress.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            )
          else
            ...stats.masteredSubjects.map((topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildProgressBar(
                    topic.title,
                    topic.percentage,
                    AppColors.success,
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String title, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 6,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
