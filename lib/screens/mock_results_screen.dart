import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_progress_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_progress_gauge.dart';

class MockResultsScreen extends StatefulWidget {
  final VoidCallback onReviewWrongAnswers;
  final VoidCallback onPracticeWeakAreas;

  const MockResultsScreen({
    super.key,
    required this.onReviewWrongAnswers,
    required this.onPracticeWeakAreas,
  });

  @override
  State<MockResultsScreen> createState() => _MockResultsScreenState();
}

class _MockResultsScreenState extends State<MockResultsScreen> {
  String get _currentUid => AuthService.instance.currentUser?.uid ?? 'guest';

  void _showTakeMockDialog(BuildContext context) {
    int selectedScore = 85;
    String selectedCompany = 'Maersk Engineering Orals';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Take Mock Oral Interview'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Simulate an oral examination for your target company and record your result.',
                    style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCompany,
                    decoration: const InputDecoration(
                      labelText: 'Select Mock Module',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Maersk Engineering Orals',
                        child: Text('Maersk Engineering Orals'),
                      ),
                      DropdownMenuItem(
                        value: 'MSC Deck Officer Mock',
                        child: Text('MSC Deck Officer Mock'),
                      ),
                      DropdownMenuItem(
                        value: 'Anglo-Eastern Cadet Assessment',
                        child: Text('Anglo-Eastern Cadet Assessment'),
                      ),
                      DropdownMenuItem(
                        value: 'COLREG & Emergency Safety Practice',
                        child: Text('COLREG & Emergency Safety Practice'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCompany = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Simulated Exam Score: $selectedScore%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: selectedScore.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '$selectedScore%',
                    onChanged: (val) {
                      setDialogState(() {
                        selectedScore = val.round();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newRecord = MockResultRecord(
                      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
                      title: selectedCompany,
                      score: selectedScore,
                      totalQuestions: 10,
                      correctCount: (selectedScore / 10).round(),
                      date: DateTime.now(),
                      weakCategoryIds: selectedScore < 70
                          ? ['Ship Stability', 'COLREG Scenarios']
                          : [],
                    );

                    UserProgressRepository.instance.addMockResult(_currentUid, newRecord);
                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Mock Result Saved! Score: $selectedScore%. Dashboard updated.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Save & Finish Mock'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UserProgressRepository.instance,
      builder: (context, _) {
        final progress = UserProgressRepository.instance.getUserProgress(_currentUid);
        final mockHistory = progress.mockHistory;

        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 800;

        if (mockHistory.isEmpty) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mock Interview Results',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'No mock interviews completed for this user account yet.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.quiz_outlined,
                          size: 64, color: AppColors.actionBlue),
                      const SizedBox(height: 16),
                      const Text(
                        'Ready for your first mock oral exam?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Take a practice mock test to generate real-time feedback, topic breakdown, and readiness scores.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showTakeMockDialog(context),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Mock Oral Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.actionBlue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final latestMock = mockHistory.last;
        final totalScore =
            mockHistory.fold<int>(0, (sum, item) => sum + item.score);
        final avgScore = (totalScore / mockHistory.length).round();

        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latestMock.title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Latest Mock: ${latestMock.date.day}/${latestMock.date.month}/${latestMock.date.year} • Total Completed: ${mockHistory.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showTakeMockDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Take Another Mock'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bento Layout Row: Overall Score + History Breakdown
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildOverallScoreCard(latestMock.score, avgScore),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 6,
                      child: _buildHistoryCard(mockHistory),
                    ),
                  ],
                )
              else ...[
                _buildOverallScoreCard(latestMock.score, avgScore),
                const SizedBox(height: 16),
                _buildHistoryCard(mockHistory),
              ],

              const SizedBox(height: 28),

              // Bottom Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: widget.onReviewWrongAnswers,
                    child: const Text('Review Practice Questions'),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: widget.onPracticeWeakAreas,
                    child: const Text('Practice Question Bank'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverallScoreCard(int latestScore, int avgScore) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          CircularProgressGauge(
            percentage: latestScore.toDouble(),
            size: 160,
            strokeWidth: 12,
            progressColor:
                latestScore >= 70 ? AppColors.actionBlue : AppColors.warning,
            backgroundColor: AppColors.surfaceContainerHigh,
            centerLabel: '$latestScore%',
            centerSubtitle: 'Latest Score',
          ),
          const SizedBox(height: 20),
          Text(
            latestScore >= 75
                ? 'Strong Performance!'
                : 'Needs Continued Revision',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your average score across all mock tests is $avgScore%.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(List<MockResultRecord> history) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mock Exam History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = history[history.length - 1 - index]; // latest first
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: item.score >= 70
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.warning.withValues(alpha: 0.15),
                  child: Icon(
                    item.score >= 70 ? Icons.check : Icons.priority_high,
                    color: item.score >= 70 ? AppColors.success : AppColors.warning,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${item.date.day}/${item.date.month}/${item.date.year}',
                ),
                trailing: Text(
                  '${item.score}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: item.score >= 70
                        ? AppColors.actionBlue
                        : AppColors.warning,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
