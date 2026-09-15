enum AppUpdateCategory {
  companyNews,
  courseUpdate,
  appNews,
}

extension AppUpdateCategoryExtension on AppUpdateCategory {
  String get displayName {
    switch (this) {
      case AppUpdateCategory.companyNews:
        return 'Company News';
      case AppUpdateCategory.courseUpdate:
        return 'Course Update';
      case AppUpdateCategory.appNews:
        return 'App Announcement';
    }
  }

  String get iconLabel {
    switch (this) {
      case AppUpdateCategory.companyNews:
        return '🏢 Company';
      case AppUpdateCategory.courseUpdate:
        return '📚 Course';
      case AppUpdateCategory.appNews:
        return '🚀 App News';
    }
  }
}

class AppUpdate {
  final String id;
  final String title;
  final String summary;
  final String content;
  final AppUpdateCategory category;
  final DateTime postedDate;
  final String badgeText;
  final String author;
  final String readTime;
  final String? companyId;
  final String? actionButtonText;
  final bool isUrgent;

  AppUpdate({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.postedDate,
    required this.badgeText,
    required this.author,
    required this.readTime,
    this.companyId,
    this.actionButtonText,
    this.isUrgent = false,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(postedDate);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${postedDate.day}/${postedDate.month}/${postedDate.year}';
    }
  }
}
