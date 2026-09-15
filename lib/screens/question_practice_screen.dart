import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/company.dart';
import '../models/question.dart';
import '../services/auth_service.dart';
import '../services/user_progress_repository.dart';
import '../theme/app_theme.dart';

class QuestionPracticeScreen extends StatefulWidget {
  final Company? selectedCompany;
  final VoidCallback onBack;

  const QuestionPracticeScreen({
    super.key,
    this.selectedCompany,
    required this.onBack,
  });

  @override
  State<QuestionPracticeScreen> createState() =>
      _QuestionPracticeScreenState();
}

class _QuestionPracticeScreenState extends State<QuestionPracticeScreen> {
  String _searchQuery = '';
  late String _selectedCategory;
  final Set<String> _expandedQuestionIds = {};

  final List<String> _categories = [
    'Zodiac Maritime Real Interview Questions',
    '14. Personal HR Questions',
    '15. Psychometric Questions',
    '16. Seagull / CES Questions',
    'All Topics',
    '1. Emergency & Safety',
    '2. MLC 2006',
    '3. Maersk Alcohol & Drug Policy',
    '4. Ship & Seamanship Basics',
    '5. LSA & FFA',
    '6. Important COLREG Rules',
    '7. AMET — Basic Knowledge',
    '8. Navigation Basics',
    '9. Basic 10th/12th-Level Science',
    '10. Important Maritime Full Forms',
    '11. Bay Plan & Container Basics',
    '12. Code of Signals A–Z',
    '13. Quick Interview Advice',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = '14. Personal HR Questions';
  }

  String get _currentUid => AuthService.instance.currentUser?.uid ?? 'guest';

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedQuestionIds.contains(id)) {
        _expandedQuestionIds.remove(id);
      } else {
        _expandedQuestionIds.add(id);
      }
    });
  }

  void _toggleRead(String id) {
    UserProgressRepository.instance.toggleQuestionCompleted(_currentUid, id);
  }

  void _toggleBookmark(String id) {
    UserProgressRepository.instance.toggleBookmark(_currentUid, id);
  }

  void _toggleNeedsReview(String id, String category) {
    UserProgressRepository.instance.toggleIncorrectAnswer(_currentUid, id, category);
  }

  void _expandAll(List<QuestionItem> items) {
    setState(() {
      _expandedQuestionIds.addAll(items.map((e) => e.id));
    });
  }

  void _collapseAll() {
    setState(() {
      _expandedQuestionIds.clear();
    });
  }

  void _markAllAsRead(List<QuestionItem> items) {
    for (final item in items) {
      final progress = UserProgressRepository.instance.getUserProgress(_currentUid);
      if (!progress.completedQuestionIds.contains(item.id)) {
        UserProgressRepository.instance.toggleQuestionCompleted(_currentUid, item.id);
      }
    }
  }

  void _clearAllRead() {
    final progress = UserProgressRepository.instance.getUserProgress(_currentUid);
    for (final id in List<String>.from(progress.completedQuestionIds)) {
      UserProgressRepository.instance.toggleQuestionCompleted(_currentUid, id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UserProgressRepository.instance,
      builder: (context, _) {
        final progressModel =
            UserProgressRepository.instance.getUserProgress(_currentUid);
        final readQuestionIds = progressModel.completedQuestionIds;
        final bookmarkedQuestionIds = progressModel.bookmarkedQuestionIds;

        final filteredQuestions = QuestionItem.allPDFQuestions.where((q) {
          final matchesCategory = _selectedCategory == 'All Topics' ||
              q.category == _selectedCategory;
          final matchesSearch = _searchQuery.isEmpty ||
              q.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              q.answer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              q.category.toLowerCase().contains(_searchQuery.toLowerCase());

          return matchesCategory && matchesSearch;
        }).toList();

        final totalQuestionsCount = QuestionItem.allPDFQuestions.length;
        final totalReadCount = readQuestionIds.length;
        final progressPercentage = (totalQuestionsCount > 0)
            ? (totalReadCount / totalQuestionsCount * 100).toInt()
            : 0;

        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 800;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.actionBlue),
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedCompany != null
                              ? '${widget.selectedCompany!.name} Interview Question Bank'
                              : 'Merchant Navy Interview Revision Guide',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text(
                          'Tap any question to reveal the answer. Click the tick (✓) to mark as read.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Overall Reading Progress Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.task_alt,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Revision Completion Status',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '$totalReadCount / $totalQuestionsCount Read ($progressPercentage%)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB9F3C5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: totalQuestionsCount > 0
                                  ? totalReadCount / totalQuestionsCount
                                  : 0,
                              minHeight: 6,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFB9F3C5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Practice Session Mode Selector (Personal, Psychometric, Seagull)
              _buildPracticeModeSelector(),
              const SizedBox(height: 16),

              if (_selectedCategory == '16. Seagull / CES Questions') ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Marlins English Test Official Preparation Video Playlist',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Watch video walkthroughs & practice questions for Marlins English Test for seafarers.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(
                              'https://www.youtube.com/watch?v=ISEXtR5OJ_E&list=PLQlGMC_E3fJZN57FShWALavihaSttAGfK');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Open Playlist'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Search & Filter Bar Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search questions, keywords, or rules...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.outlineVariant),
                              ),
                            ),
                          ),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: 12),
                          _buildCategoryDropdown(),
                        ],
                      ],
                    ),
                    if (!isDesktop) ...[
                      const SizedBox(height: 12),
                      _buildCategoryDropdown(),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${filteredQuestions.length} Questions',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: () => _expandAll(filteredQuestions),
                              icon: const Icon(Icons.unfold_more, size: 16),
                              label: const Text('Expand All',
                                  style: TextStyle(fontSize: 12)),
                            ),
                            TextButton.icon(
                              onPressed: _collapseAll,
                              icon: const Icon(Icons.unfold_less, size: 16),
                              label: const Text('Collapse All',
                                  style: TextStyle(fontSize: 12)),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _markAllAsRead(filteredQuestions),
                              icon: const Icon(Icons.check_circle_outline,
                                  size: 16, color: AppColors.success),
                              label: const Text('Mark Page Read',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.success)),
                            ),
                            if (totalReadCount > 0)
                              TextButton(
                                onPressed: _clearAllRead,
                                child: const Text('Reset Read',
                                    style: TextStyle(
                                        fontSize: 12, color: AppColors.error)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Questions List View
              if (filteredQuestions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No questions match your search query or selected topic category.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredQuestions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredQuestions[index];
                    final isExpanded = _expandedQuestionIds.contains(item.id);
                    final isRead = readQuestionIds.contains(item.id);
                    final isBookmarked = bookmarkedQuestionIds.contains(item.id);
                    final isNeedsReview = progressModel.incorrectQuestionIds.contains(item.id);

                    return _buildQuestionCard(
                      item: item,
                      isExpanded: isExpanded,
                      isRead: isRead,
                      isBookmarked: isBookmarked,
                      isNeedsReview: isNeedsReview,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: false,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedCategory = val;
              });
            }
          },
          items: _categories.map((cat) {
            return DropdownMenuItem<String>(
              value: cat,
              child: Text(
                cat,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required QuestionItem item,
    required bool isExpanded,
    required bool isRead,
    required bool isBookmarked,
    required bool isNeedsReview,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isNeedsReview
            ? Colors.red.shade50
            : isRead
                ? const Color(0xFFF1F8E9)
                : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNeedsReview
              ? AppColors.error
              : isRead
                  ? const Color(0xFF81C784)
                  : AppColors.outlineVariant,
          width: isNeedsReview || isRead ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question Header Tile
          InkWell(
            onTap: () => _toggleExpanded(item.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? const Color(0xFFC8E6C9)
                                    : AppColors.secondaryFixed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isRead
                                      ? const Color(0xFF1B5E20)
                                      : AppColors.onSecondaryFixedVariant,
                                ),
                              ),
                            ),
                            if (isNeedsReview) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        size: 13, color: AppColors.error),
                                    SizedBox(width: 4),
                                    Text(
                                      'NEEDS REVIEW 📌',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (isRead && !isNeedsReview) ...[
                              const SizedBox(width: 8),
                              const Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 14, color: Color(0xFF2E7D32)),
                                  SizedBox(width: 4),
                                  Text(
                                    'READ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.question,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isNeedsReview
                                ? Colors.red.shade900
                                : isRead
                                    ? const Color(0xFF1B5E20)
                                    : AppColors.primary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Needs Review / Flag Incorrect Button
                  IconButton(
                    tooltip: isNeedsReview
                        ? 'Remove from Review Section'
                        : 'Add Topic to Review Section (Incorrect Answer)',
                    onPressed: () {
                      _toggleNeedsReview(item.id, item.category);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            !isNeedsReview
                                ? 'Added topic "${item.category}" to Review Section 📌'
                                : 'Removed "${item.category}" from Review Section',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      isNeedsReview ? Icons.warning_rounded : Icons.warning_amber_rounded,
                      color: isNeedsReview ? AppColors.error : AppColors.outline,
                      size: 24,
                    ),
                  ),

                  // Bookmark Button
                  IconButton(
                    tooltip: isBookmarked ? 'Remove Bookmark' : 'Bookmark Question',
                    onPressed: () => _toggleBookmark(item.id),
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked
                          ? AppColors.actionBlue
                          : AppColors.outline,
                      size: 24,
                    ),
                  ),

                  // Tick Option Button (Mark as Read Toggle)
                  IconButton(
                    tooltip: isRead ? 'Mark as Unread' : 'Mark as Read',
                    onPressed: () => _toggleRead(item.id),
                    icon: Icon(
                      isRead
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isRead
                          ? const Color(0xFF2E7D32)
                          : AppColors.outline,
                      size: 26,
                    ),
                  ),

                  // Expand / Collapse Icon Indicator
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isRead
                        ? const Color(0xFF2E7D32)
                        : isExpanded
                            ? AppColors.actionBlue
                            : AppColors.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Answer Section (Revealed when clicked)
          if (isExpanded) ...[
            Divider(
              color: isRead ? const Color(0xFFA5D6A7) : AppColors.outlineVariant,
              height: 1,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isRead
                    ? const Color(0xFFE8F5E9)
                    : AppColors.surfaceContainerLow,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 18, color: AppColors.success),
                          SizedBox(width: 8),
                          Text(
                            'MODEL ANSWER',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => _toggleRead(item.id),
                        child: Row(
                          children: [
                            Icon(
                              isRead
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 16,
                              color: isRead
                                  ? const Color(0xFF2E7D32)
                                  : AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isRead ? 'Completed' : 'Mark Completed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isRead
                                    ? const Color(0xFF2E7D32)
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SelectableText(
                    item.answer,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.onSurface,
                    ),
                  ),

                  // Optional Table Data if present
                  if (item.tableData != null && item.tableData!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Table(
                      border: TableBorder.all(
                        color: AppColors.outlineVariant,
                        width: 1,
                      ),
                      children: item.tableData!.map((row) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                row['code'] ?? row['term'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(row['meaning'] ?? row['definition'] ?? ''),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],

                  // Interview Tip Callout
                  if (item.interviewTip != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.primaryContainer
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: AppColors.actionBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Oral Tip: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextSpan(
                                    text: item.interviewTip,
                                    style: const TextStyle(
                                      color: AppColors.onSurface,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
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
        ],
      ),
    );
  }

  Widget _buildPracticeModeSelector() {
    final modes = [
      {
        'title': 'Personal Questions',
        'category': '14. Personal HR Questions',
        'icon': Icons.person,
        'color': Colors.purple,
      },
      {
        'title': 'Psychometric Questions',
        'category': '15. Psychometric Questions',
        'icon': Icons.psychology,
        'color': Colors.orange.shade800,
      },
      {
        'title': 'Seagull / CES Questions',
        'category': '16. Seagull / CES Questions',
        'icon': Icons.sailing,
        'color': Colors.teal.shade700,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Practice Mode / Category:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: modes.map((mode) {
                final catStr = mode['category'] as String;
                final isSelected = _selectedCategory == catStr;
                final titleStr = mode['title'] as String;
                final iconData = mode['icon'] as IconData;
                final iconColor = mode['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = catStr;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? iconColor
                            : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? iconColor : AppColors.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            iconData,
                            size: 18,
                            color: isSelected ? Colors.white : iconColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            titleStr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
