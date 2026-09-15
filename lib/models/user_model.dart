import 'dart:convert';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}

class MockResultRecord {
  final String id;
  final String title;
  final int score;
  final int totalQuestions;
  final int correctCount;
  final DateTime date;
  final List<String> weakCategoryIds;

  MockResultRecord({
    required this.id,
    required this.title,
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    DateTime? date,
    required this.weakCategoryIds,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'score': score,
        'totalQuestions': totalQuestions,
        'correctCount': correctCount,
        'date': date.toIso8601String(),
        'weakCategoryIds': weakCategoryIds,
      };

  factory MockResultRecord.fromJson(Map<String, dynamic> json) =>
      MockResultRecord(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Mock Interview',
        score: json['score'] as int? ?? 0,
        totalQuestions: json['totalQuestions'] as int? ?? 10,
        correctCount: json['correctCount'] as int? ?? 0,
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        weakCategoryIds: List<String>.from(json['weakCategoryIds'] ?? []),
      );
}

class UserProgressModel {
  final String uid;
  final Set<String> completedQuestionIds;
  final Set<String> bookmarkedQuestionIds;
  final Set<String> incorrectQuestionIds;
  final Set<String> reviewTopics;
  final List<MockResultRecord> mockHistory;
  final Map<String, int> companyProgress;

  UserProgressModel({
    required this.uid,
    Set<String>? completedQuestionIds,
    Set<String>? bookmarkedQuestionIds,
    Set<String>? incorrectQuestionIds,
    Set<String>? reviewTopics,
    List<MockResultRecord>? mockHistory,
    Map<String, int>? companyProgress,
  })  : completedQuestionIds = completedQuestionIds ?? {},
        bookmarkedQuestionIds = bookmarkedQuestionIds ?? {},
        incorrectQuestionIds = incorrectQuestionIds ?? {},
        reviewTopics = reviewTopics ?? {},
        mockHistory = mockHistory ?? [],
        companyProgress = companyProgress ?? {};

  factory UserProgressModel.empty(String uid) {
    return UserProgressModel(
      uid: uid,
      completedQuestionIds: {},
      bookmarkedQuestionIds: {},
      incorrectQuestionIds: {},
      reviewTopics: {},
      mockHistory: [],
      companyProgress: {},
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'completedQuestionIds': completedQuestionIds.toList(),
        'bookmarkedQuestionIds': bookmarkedQuestionIds.toList(),
        'incorrectQuestionIds': incorrectQuestionIds.toList(),
        'reviewTopics': reviewTopics.toList(),
        'mockHistory': mockHistory.map((m) => m.toJson()).toList(),
        'companyProgress': companyProgress,
      };

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      UserProgressModel(
        uid: json['uid'] as String,
        completedQuestionIds:
            Set<String>.from(json['completedQuestionIds'] ?? []),
        bookmarkedQuestionIds:
            Set<String>.from(json['bookmarkedQuestionIds'] ?? []),
        incorrectQuestionIds:
            Set<String>.from(json['incorrectQuestionIds'] ?? []),
        reviewTopics:
            Set<String>.from(json['reviewTopics'] ?? []),
        mockHistory: (json['mockHistory'] as List<dynamic>?)
                ?.map((e) =>
                    MockResultRecord.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        companyProgress:
            Map<String, int>.from(json['companyProgress'] ?? {}),
      );

  String serialize() => jsonEncode(toJson());

  factory UserProgressModel.deserialize(String jsonString) =>
      UserProgressModel.fromJson(jsonDecode(jsonString));
}
