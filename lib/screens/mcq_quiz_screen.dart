import 'package:flutter/material.dart';
import '../models/mcq_quiz_data.dart';
import '../services/auth_service.dart';
import '../services/user_progress_repository.dart';
import '../theme/app_theme.dart';

class McqQuizScreen extends StatefulWidget {
  const McqQuizScreen({super.key});

  @override
  State<McqQuizScreen> createState() => _McqQuizScreenState();
}

class _McqQuizScreenState extends State<McqQuizScreen> {
  QuizModel? _activeQuiz;
  int _currentQuestionIndex = 0;
  final Map<int, int> _userAnswers = {}; // questionIndex -> selectedOptionIndex
  bool _isSubmitted = false;

  void _startQuiz(QuizModel quiz) {
    setState(() {
      _activeQuiz = quiz;
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _isSubmitted = false;
    });
  }

  void _exitQuiz() {
    setState(() {
      _activeQuiz = null;
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _isSubmitted = false;
    });
  }

  void _submitQuiz() {
    if (_activeQuiz == null) return;
    setState(() {
      _isSubmitted = true;
    });

    final user = AuthService.instance.currentUser;
    if (user != null) {
      int score = 0;
      for (int i = 0; i < _activeQuiz!.questions.length; i++) {
        if (_userAnswers[i] == _activeQuiz!.questions[i].correctOptionIndex) {
          score++;
        }
      }
      UserProgressRepository.instance.recordQuizAttempt(
        user.uid,
        _activeQuiz!.id,
        score,
        _activeQuiz!.questions.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 800;

    return AnimatedBuilder(
      animation: UserProgressRepository.instance,
      builder: (context, _) {
        if (_activeQuiz == null) {
          return _buildQuizHubView(isWide);
        }

        if (_isSubmitted) {
          return _buildQuizResultView(isWide);
        }

        return _buildActiveQuizView(isWide);
      },
    );
  }

  // -----------------------------------------------------------------
  // 1. QUIZZES HUB (Select Quiz 1 through Quiz 10)
  // -----------------------------------------------------------------
  Widget _buildQuizHubView(bool isWide) {
    final user = AuthService.instance.currentUser;
    final uid = user?.uid ?? 'guest';

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.actionBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: AppColors.actionBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MCQ Exam Center',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '10 Full-Length Quizzes • Exactly 20 MCQs per Quiz',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Grid of 10 Quizzes
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 2 : 1,
              childAspectRatio: isWide ? 2.2 : 1.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: McqQuizData.allQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = McqQuizData.allQuizzes[index];
              final savedScore =
                  UserProgressRepository.instance.getQuizScore(uid, quiz.id);

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: savedScore != null && savedScore >= 16
                        ? Colors.green.shade400
                        : AppColors.outlineVariant,
                    width: savedScore != null && savedScore >= 16 ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quiz Number Pill & Score
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                quiz.title, // "Quiz 1", "Quiz 2", etc.
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (savedScore != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: savedScore >= 14
                                      ? Colors.green.shade50
                                      : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: savedScore >= 14
                                        ? Colors.green
                                        : Colors.amber.shade800,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      savedScore >= 14
                                          ? Icons.check_circle
                                          : Icons.stars,
                                      size: 14,
                                      color: savedScore >= 14
                                          ? Colors.green
                                          : Colors.amber.shade800,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$savedScore/20 (${(savedScore * 5)}%)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: savedScore >= 14
                                            ? Colors.green.shade800
                                            : Colors.amber.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Topic Title
                        Text(
                          quiz.topicName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quiz.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),

                    // Bottom info & Start Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.format_list_bulleted,
                                size: 16, color: AppColors.onSurfaceVariant),
                            SizedBox(width: 4),
                            Text(
                              '20 MCQs',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.timer_outlined,
                                size: 16, color: AppColors.onSurfaceVariant),
                            SizedBox(width: 4),
                            Text(
                              '20 Mins',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _startQuiz(quiz),
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: Text('Start ${quiz.title}'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // 2. ACTIVE QUIZ VIEW (Question 1 to 20)
  // -----------------------------------------------------------------
  Widget _buildActiveQuizView(bool isWide) {
    final quiz = _activeQuiz!;
    final question = quiz.questions[_currentQuestionIndex];
    final selectedOption = _userAnswers[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / quiz.questions.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Exit ${quiz.title}?'),
                      content: const Text(
                          'Your current progress in this quiz will not be saved.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _exitQuiz();
                          },
                          child: const Text('Exit Quiz',
                              style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('All Quizzes'),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${quiz.title} • Question ${_currentQuestionIndex + 1} of 20',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              color: AppColors.actionBlue,
            ),
          ),

          const SizedBox(height: 24),

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.actionBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Question Text
                Text(
                  question.question,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // Options List
                Column(
                  children: List.generate(question.options.length, (optIdx) {
                    final isSelected = selectedOption == optIdx;
                    final optionLabel = String.fromCharCode(65 + optIdx); // A, B, C, D

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _userAnswers[_currentQuestionIndex] = optIdx;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.actionBlue.withValues(alpha: 0.08)
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.actionBlue
                                  : AppColors.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.actionBlue
                                      : AppColors.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  optionLabel,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  question.options[optIdx],
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.actionBlue
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bottom Action Bar (Previous, Next, Submit)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: _currentQuestionIndex > 0
                    ? () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                label: const Text('Previous'),
              ),
              Row(
                children: [
                  Text(
                    '${_userAnswers.length}/20 Answered',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_currentQuestionIndex < quiz.questions.length - 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      },
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text('Next Question'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _submitQuiz,
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: Text('Submit ${quiz.title}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // 3. QUIZ RESULT SUMMARY VIEW
  // -----------------------------------------------------------------
  Widget _buildQuizResultView(bool isWide) {
    final quiz = _activeQuiz!;
    int correctCount = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (_userAnswers[i] == quiz.questions[i].correctOptionIndex) {
        correctCount++;
      }
    }

    final percentage = ((correctCount / quiz.questions.length) * 100).round();
    final isPassed = percentage >= 70;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPassed ? Colors.green : AppColors.error,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 64,
                  color: isPassed ? Colors.amber.shade700 : AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  '${quiz.title} Completed!',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isPassed
                      ? '🎉 Excellent Performance! You passed ${quiz.title}.'
                      : '📖 Needs Review. Try taking ${quiz.title} again to master all topics.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // Score Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isPassed
                        ? Colors.green.shade50
                        : AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Score: $correctCount / 20 ($percentage%)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isPassed
                          ? Colors.green.shade800
                          : AppColors.error,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _startQuiz(quiz),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text('Retake ${quiz.title}'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _exitQuiz,
                      icon: const Icon(Icons.grid_view_rounded, size: 18),
                      label: const Text('Back to All Quizzes'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Detailed Answer Key & Review (20 MCQs)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Question Review List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quiz.questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, idx) {
              final q = quiz.questions[idx];
              final userAns = _userAnswers[idx];
              final isCorrect = userAns == q.correctOptionIndex;

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorrect
                        ? Colors.green.shade300
                        : AppColors.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Q${idx + 1}. ${q.category}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? Colors.green : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      q.question,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Answer: ${userAns != null ? q.options[userAns] : 'Not Answered'}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCorrect ? Colors.green.shade800 : AppColors.error,
                      ),
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Correct Answer: ${q.options[q.correctOptionIndex]}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '💡 Explanation: ${q.explanation}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
