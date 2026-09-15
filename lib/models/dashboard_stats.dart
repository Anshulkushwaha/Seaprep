import 'question.dart';
import 'user_model.dart';

class FocusTopic {
  final String title;
  final int percentage;
  final bool isWeak;

  const FocusTopic({
    required this.title,
    required this.percentage,
    required this.isWeak,
  });
}

class DashboardStats {
  final int readinessPercentage;
  final int questionsPracticed;
  final int bookmarkedCount;
  final int daysUntilExam;
  final List<FocusTopic> weakAreas;
  final List<FocusTopic> masteredSubjects;

  const DashboardStats({
    required this.readinessPercentage,
    required this.questionsPracticed,
    required this.bookmarkedCount,
    required this.daysUntilExam,
    required this.weakAreas,
    required this.masteredSubjects,
  });

  static const DashboardStats zero = DashboardStats(
    readinessPercentage: 0,
    questionsPracticed: 0,
    bookmarkedCount: 0,
    daysUntilExam: 45,
    weakAreas: [],
    masteredSubjects: [],
  );

  factory DashboardStats.fromUserProgress(UserProgressModel progress, {int totalAvailableQuestions = 52}) {
    final questionsPracticed = progress.completedQuestionIds.length;
    final bookmarkedCount = progress.bookmarkedQuestionIds.length;

    int readinessPercentage = 0;
    if (questionsPracticed > 0 || bookmarkedCount > 0) {
      final questionPart = (questionsPracticed / (totalAvailableQuestions > 0 ? totalAvailableQuestions : 52)) * 70;
      final bookmarkPart = (bookmarkedCount / 10.0).clamp(0.0, 1.0) * 30;
      readinessPercentage = (questionPart + bookmarkPart).round().clamp(0, 100);
    }

    List<FocusTopic> weakAreas = [];
    List<FocusTopic> masteredSubjects = [];

    // Aggregate all weak topics from reviewTopics, incorrect questions, and mock history
    final Set<String> allWeakTopicNames = Set<String>.from(progress.reviewTopics);

    for (final mockRecord in progress.mockHistory) {
      allWeakTopicNames.addAll(mockRecord.weakCategoryIds);
    }

    // Map each incorrect question ID to its topic category
    for (final qId in progress.incorrectQuestionIds) {
      final pdfMatch = QuestionItem.allPDFQuestions.where((q) => q.id == qId).firstOrNull;
      if (pdfMatch != null && pdfMatch.category.isNotEmpty) {
        allWeakTopicNames.add(pdfMatch.category);
      }
    }

    if (progress.incorrectQuestionIds.isNotEmpty && allWeakTopicNames.isEmpty) {
      allWeakTopicNames.add('Incorrect Practice Answers');
    }

    for (final topicName in allWeakTopicNames) {
      weakAreas.add(
        FocusTopic(
          title: topicName,
          percentage: 45, // Highlighted topic requiring review
          isWeak: true,
        ),
      );
    }

    if (questionsPracticed > 0) {
      masteredSubjects.add(
        FocusTopic(
          title: 'Practiced Questions ($questionsPracticed completed)',
          percentage: ((questionsPracticed / totalAvailableQuestions) * 100).round().clamp(0, 100),
          isWeak: false,
        ),
      );
    }

    if (bookmarkedCount > 0) {
      masteredSubjects.add(
        FocusTopic(
          title: 'Bookmarked Questions ($bookmarkedCount saved)',
          percentage: (bookmarkedCount * 10).clamp(0, 100),
          isWeak: false,
        ),
      );
    }

    return DashboardStats(
      readinessPercentage: readinessPercentage,
      questionsPracticed: questionsPracticed,
      bookmarkedCount: bookmarkedCount,
      daysUntilExam: 45,
      weakAreas: weakAreas,
      masteredSubjects: masteredSubjects,
    );
  }
}
