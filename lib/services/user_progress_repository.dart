import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/dashboard_stats.dart';
import '../models/user_model.dart';
import 'storage_helper.dart';

class UserProgressRepository extends ChangeNotifier {
  static final UserProgressRepository instance =
      UserProgressRepository._internal();
  UserProgressRepository._internal() {
    _loadFromStorage();
  }

  final Map<String, UserProgressModel> _localStorage = {};
  final Map<String, int> _quizScores = {};

  void _loadFromStorage() {
    try {
      final rawJson = StorageHelper.getItem('maritime_user_progress_v1');
      if (rawJson != null && rawJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(rawJson);
        decoded.forEach((uid, val) {
          _localStorage[uid] =
              UserProgressModel.fromJson(Map<String, dynamic>.from(val));
        });
      }
      final rawScores = StorageHelper.getItem('maritime_quiz_scores_v1');
      if (rawScores != null && rawScores.isNotEmpty) {
        final Map<String, dynamic> decodedScores = jsonDecode(rawScores);
        decodedScores.forEach((k, v) {
          _quizScores[k] = (v as num).toInt();
        });
      }
    } catch (e) {
      debugPrint('Error loading user progress from web storage: $e');
    }
  }

  void _saveToStorage() {
    try {
      final mapToSave = <String, dynamic>{};
      _localStorage.forEach((uid, model) {
        mapToSave[uid] = model.toJson();
      });
      StorageHelper.setItem(
          'maritime_user_progress_v1', jsonEncode(mapToSave));
      StorageHelper.setItem(
          'maritime_quiz_scores_v1', jsonEncode(_quizScores));
    } catch (e) {
      debugPrint('Error saving user progress to web storage: $e');
    }
  }

  static const String defaultUid = 'guest_cadet';

  String _normalizeUid(String uid) =>
      (uid.isEmpty || uid == 'guest') ? defaultUid : uid;

  /// Retrieves user progress for [uid], syncing with Supabase if configured.
  UserProgressModel getUserProgress(String uid) {
    final key = _normalizeUid(uid);

    // Merge any legacy 'guest' state into 'guest_cadet'
    if (key == defaultUid && _localStorage.containsKey('guest')) {
      final legacy = _localStorage['guest']!;
      final existing =
          _localStorage[defaultUid] ?? UserProgressModel.empty(defaultUid);

      final mergedCompleted =
          Set<String>.from(existing.completedQuestionIds)..addAll(legacy.completedQuestionIds);
      final mergedBookmarked =
          Set<String>.from(existing.bookmarkedQuestionIds)..addAll(legacy.bookmarkedQuestionIds);
      final mergedIncorrect =
          Set<String>.from(existing.incorrectQuestionIds)..addAll(legacy.incorrectQuestionIds);
      final mergedTopics =
          Set<String>.from(existing.reviewTopics)..addAll(legacy.reviewTopics);

      _localStorage[defaultUid] = UserProgressModel(
        uid: defaultUid,
        completedQuestionIds: mergedCompleted,
        bookmarkedQuestionIds: mergedBookmarked,
        incorrectQuestionIds: mergedIncorrect,
        reviewTopics: mergedTopics,
        mockHistory: [...existing.mockHistory, ...legacy.mockHistory],
        companyProgress: {...existing.companyProgress, ...legacy.companyProgress},
      );
      _localStorage.remove('guest');
      _saveToStorage();
    }

    // Merge guest progress into logged-in user if key != defaultUid and key's progress is empty
    if (key != defaultUid && _localStorage.containsKey(defaultUid)) {
      final guestData = _localStorage[defaultUid]!;
      final existing = _localStorage[key] ?? UserProgressModel.empty(key);

      if (existing.incorrectQuestionIds.isEmpty && guestData.incorrectQuestionIds.isNotEmpty) {
        final mergedIncorrect =
            Set<String>.from(existing.incorrectQuestionIds)..addAll(guestData.incorrectQuestionIds);
        final mergedTopics =
            Set<String>.from(existing.reviewTopics)..addAll(guestData.reviewTopics);

        _localStorage[key] = UserProgressModel(
          uid: key,
          completedQuestionIds:
              Set<String>.from(existing.completedQuestionIds)..addAll(guestData.completedQuestionIds),
          bookmarkedQuestionIds:
              Set<String>.from(existing.bookmarkedQuestionIds)..addAll(guestData.bookmarkedQuestionIds),
          incorrectQuestionIds: mergedIncorrect,
          reviewTopics: mergedTopics,
          mockHistory: [...existing.mockHistory, ...guestData.mockHistory],
          companyProgress: {...existing.companyProgress, ...guestData.companyProgress},
        );
        _saveToStorage();
      }
    }

    if (!_localStorage.containsKey(key)) {
      _localStorage[key] = UserProgressModel.empty(key);
      _saveToStorage();
    }
    return _localStorage[key]!;
  }

  /// Syncs user question progress and mock results from Supabase into local app state.
  Future<void> syncFromSupabase(String uid) async {
    final key = _normalizeUid(uid);
    if (!SupabaseConfig.isConfigured || key.isEmpty) return;

    try {
      final progressRows = await Supabase.instance.client
          .from('user_question_progress')
          .select()
          .eq('user_id', uid);

      final completed = <String>{};
      final bookmarked = <String>{};

      for (final row in progressRows as List<dynamic>) {
        final qId = row['question_id'] as String;
        if (row['is_completed'] == true) completed.add(qId);
        if (row['is_bookmarked'] == true) bookmarked.add(qId);
      }

      final mockRows = await Supabase.instance.client
          .from('mock_interview_results')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: true);

      final mockHistory = (mockRows as List<dynamic>).map((row) {
        return MockResultRecord(
          id: row['id'] as String,
          title: row['title'] as String? ?? 'Mock Test',
          score: (row['score'] as num?)?.toInt() ?? 0,
          totalQuestions: (row['total_questions'] as num?)?.toInt() ?? 10,
          correctCount: (row['correct_count'] as num?)?.toInt() ?? 0,
          date: DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
          weakCategoryIds: List<String>.from(row['weak_category_ids'] ?? []),
        );
      }).toList();

      final current = getUserProgress(uid);
      _localStorage[uid] = UserProgressModel(
        uid: uid,
        completedQuestionIds: completed,
        bookmarkedQuestionIds: bookmarked,
        incorrectQuestionIds: current.incorrectQuestionIds,
        reviewTopics: current.reviewTopics,
        mockHistory: mockHistory,
        companyProgress: current.companyProgress,
      );
      _saveToStorage();
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing from Supabase: $e');
    }
  }

  /// Ensures a newly registered user starts with a completely fresh empty progress object.
  UserProgressModel initFreshUser(String uid) {
    final key = _normalizeUid(uid);
    _localStorage[key] = UserProgressModel.empty(key);
    _saveToStorage();
    notifyListeners();
    return _localStorage[key]!;
  }

  /// Toggles question completion status for [uid].
  Future<void> toggleQuestionCompleted(String uid, String questionId) async {
    final key = _normalizeUid(uid);
    final current = getUserProgress(key);
    final updatedCompleted = Set<String>.from(current.completedQuestionIds);
    if (updatedCompleted.contains(questionId)) {
      updatedCompleted.remove(questionId);
    } else {
      updatedCompleted.add(questionId);
    }

    _localStorage[key] = UserProgressModel(
      uid: key,
      completedQuestionIds: updatedCompleted,
      bookmarkedQuestionIds: current.bookmarkedQuestionIds,
      incorrectQuestionIds: current.incorrectQuestionIds,
      reviewTopics: current.reviewTopics,
      mockHistory: current.mockHistory,
      companyProgress: current.companyProgress,
    );
    _saveToStorage();
    notifyListeners();

    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.from('user_question_progress').upsert({
          'user_id': key,
          'question_id': questionId,
          'is_completed': updatedCompleted.contains(questionId),
          'is_bookmarked': current.bookmarkedQuestionIds.contains(questionId),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Supabase question progress sync notice: $e');
      }
    }
  }

  /// Toggles question bookmark for [uid].
  Future<void> toggleBookmark(String uid, String questionId) async {
    final key = _normalizeUid(uid);
    final current = getUserProgress(key);
    final updatedBookmarks = Set<String>.from(current.bookmarkedQuestionIds);
    if (updatedBookmarks.contains(questionId)) {
      updatedBookmarks.remove(questionId);
    } else {
      updatedBookmarks.add(questionId);
    }

    _localStorage[key] = UserProgressModel(
      uid: key,
      completedQuestionIds: current.completedQuestionIds,
      bookmarkedQuestionIds: updatedBookmarks,
      incorrectQuestionIds: current.incorrectQuestionIds,
      reviewTopics: current.reviewTopics,
      mockHistory: current.mockHistory,
      companyProgress: current.companyProgress,
    );
    _saveToStorage();
    notifyListeners();

    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.from('user_question_progress').upsert({
          'user_id': key,
          'question_id': questionId,
          'is_completed': current.completedQuestionIds.contains(questionId),
          'is_bookmarked': updatedBookmarks.contains(questionId),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Supabase bookmark sync notice: $e');
      }
    }
  }

  /// Records an incorrect answer for a question and adds its topic to the Review Section.
  Future<void> recordIncorrectAnswer(
      String uid, String questionId, String topic) async {
    final key = _normalizeUid(uid);
    final current = getUserProgress(key);
    final updatedIncorrect = Set<String>.from(current.incorrectQuestionIds)
      ..add(questionId);
    final updatedTopics = Set<String>.from(current.reviewTopics);
    if (topic.isNotEmpty) {
      updatedTopics.add(topic);
    }

    _localStorage[key] = UserProgressModel(
      uid: key,
      completedQuestionIds: current.completedQuestionIds,
      bookmarkedQuestionIds: current.bookmarkedQuestionIds,
      incorrectQuestionIds: updatedIncorrect,
      reviewTopics: updatedTopics,
      mockHistory: current.mockHistory,
      companyProgress: current.companyProgress,
    );
    _saveToStorage();
    notifyListeners();
  }

  /// Records a correct answer for a question, clearing it from the review queue if needed.
  Future<void> recordCorrectAnswer(
      String uid, String questionId, String topic) async {
    final key = _normalizeUid(uid);
    final current = getUserProgress(key);
    final updatedIncorrect = Set<String>.from(current.incorrectQuestionIds);
    updatedIncorrect.remove(questionId);

    _localStorage[key] = UserProgressModel(
      uid: key,
      completedQuestionIds: current.completedQuestionIds,
      bookmarkedQuestionIds: current.bookmarkedQuestionIds,
      incorrectQuestionIds: updatedIncorrect,
      reviewTopics: current.reviewTopics,
      mockHistory: current.mockHistory,
      companyProgress: current.companyProgress,
    );
    _saveToStorage();
    notifyListeners();
  }

  /// Toggles whether a question is flagged for review / marked incorrect manually.
  Future<void> toggleIncorrectAnswer(
      String uid, String questionId, String topic) async {
    final key = _normalizeUid(uid);
    final current = getUserProgress(key);
    if (current.incorrectQuestionIds.contains(questionId)) {
      await recordCorrectAnswer(key, questionId, topic);
    } else {
      await recordIncorrectAnswer(key, questionId, topic);
    }
  }

  /// Manually adds a topic to the review list (e.g. from mock interview results).
  Future<void> addWeakTopic(String uid, String topic) async {
    final key = _normalizeUid(uid);
    final current = getUserProgress(key);
    final updatedTopics = Set<String>.from(current.reviewTopics)..add(topic);

    _localStorage[key] = UserProgressModel(
      uid: key,
      completedQuestionIds: current.completedQuestionIds,
      bookmarkedQuestionIds: current.bookmarkedQuestionIds,
      incorrectQuestionIds: current.incorrectQuestionIds,
      reviewTopics: updatedTopics,
      mockHistory: current.mockHistory,
      companyProgress: current.companyProgress,
    );
    _saveToStorage();
    notifyListeners();
  }

  /// Removes a topic from the review section.
  Future<void> removeWeakTopic(String uid, String topic) async {
    final key = _normalizeUid(uid);
    final current = getUserProgress(key);
    final updatedTopics = Set<String>.from(current.reviewTopics)..remove(topic);

    _localStorage[key] = UserProgressModel(
      uid: key,
      completedQuestionIds: current.completedQuestionIds,
      bookmarkedQuestionIds: current.bookmarkedQuestionIds,
      incorrectQuestionIds: current.incorrectQuestionIds,
      reviewTopics: updatedTopics,
      mockHistory: current.mockHistory,
      companyProgress: current.companyProgress,
    );
    _saveToStorage();
    notifyListeners();
  }

  /// Adds a mock interview result record for [uid].
  Future<void> addMockResult(String uid, MockResultRecord record) async {
    final key = _normalizeUid(uid);
    final current = getUserProgress(key);
    final updatedHistory = List<MockResultRecord>.from(current.mockHistory)
      ..add(record);

    final updatedTopics = Set<String>.from(current.reviewTopics);
    updatedTopics.addAll(record.weakCategoryIds);

    _localStorage[key] = UserProgressModel(
      uid: key,
      completedQuestionIds: current.completedQuestionIds,
      bookmarkedQuestionIds: current.bookmarkedQuestionIds,
      incorrectQuestionIds: current.incorrectQuestionIds,
      reviewTopics: updatedTopics,
      mockHistory: updatedHistory,
      companyProgress: current.companyProgress,
    );
    _saveToStorage();
    notifyListeners();

    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.from('mock_interview_results').insert({
          'user_id': key,
          'title': record.title,
          'score': record.score,
          'total_questions': record.totalQuestions,
          'correct_count': record.correctCount,
          'weak_category_ids': record.weakCategoryIds,
          'created_at': record.date.toIso8601String(),
        });
      } catch (e) {
        debugPrint('Supabase mock result sync notice: $e');
      }
    }
  }

  /// Computes dynamic DashboardStats for [uid].
  DashboardStats getDashboardStats(String uid,
      {int totalAvailableQuestions = 50}) {
    final progress = getUserProgress(uid);
    return DashboardStats.fromUserProgress(progress,
        totalAvailableQuestions: totalAvailableQuestions);
  }

  /// Gets stored high score for a specific quiz (e.g. 'quiz_1')
  int? getQuizScore(String uid, String quizId) {
    final key = '${_normalizeUid(uid)}_$quizId';
    return _quizScores[key];
  }

  /// Records score for a completed quiz
  void recordQuizAttempt(
      String uid, String quizId, int score, int totalQuestions) {
    final key = '${_normalizeUid(uid)}_$quizId';
    final existing = _quizScores[key];
    if (existing == null || score > existing) {
      _quizScores[key] = score;
    }
    _saveToStorage();
    notifyListeners();
  }
}
