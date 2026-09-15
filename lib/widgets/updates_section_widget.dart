import 'package:flutter/material.dart';
import '../models/app_update.dart';
import '../services/updates_repository.dart';
import '../theme/app_theme.dart';

class UpdatesSectionWidget extends StatefulWidget {
  final Function(String? companyId)? onOpenCompanyDetail;
  final VoidCallback? onOpenPractice;

  const UpdatesSectionWidget({
    super.key,
    this.onOpenCompanyDetail,
    this.onOpenPractice,
  });

  @override
  State<UpdatesSectionWidget> createState() => _UpdatesSectionWidgetState();
}

class _UpdatesSectionWidgetState extends State<UpdatesSectionWidget> {
  AppUpdateCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UpdatesRepository.instance,
      builder: (context, _) {
        final repo = UpdatesRepository.instance;
        final updates = repo.getUpdatesByCategory(_selectedCategory);
        final unreadCount = repo.unreadCount;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.actionBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            color: AppColors.actionBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'App Team Updates',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (unreadCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$unreadCount NEW',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Company hiring news & course updates from app team',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (unreadCount > 0)
                    TextButton.icon(
                      onPressed: () => repo.markAllAsRead(),
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Mark all read', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Filter Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(null, 'All Updates'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        AppUpdateCategory.companyNews, '🏢 Company News'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        AppUpdateCategory.courseUpdate, '📚 Course Updates'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        AppUpdateCategory.appNews, '🚀 App News'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Updates List
              if (updates.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Text(
                    'No updates available in this category.',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: updates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final update = updates[index];
                    return _buildUpdateCard(context, update);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(AppUpdateCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.primary,
      ),
      backgroundColor: AppColors.surfaceContainerLow,
      selectedColor: AppColors.actionBlue,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.actionBlue : AppColors.outlineVariant,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  Widget _buildUpdateCard(BuildContext context, AppUpdate update) {
    final isRead = UpdatesRepository.instance.isRead(update.id);
    final isBookmarked = UpdatesRepository.instance.isBookmarked(update.id);

    Color categoryColor;
    IconData categoryIcon;
    switch (update.category) {
      case AppUpdateCategory.companyNews:
        categoryColor = const Color(0xFF0277BD); // Ocean Blue
        categoryIcon = Icons.business_center_rounded;
        break;
      case AppUpdateCategory.courseUpdate:
        categoryColor = const Color(0xFF2E7D32); // Emerald Green
        categoryIcon = Icons.menu_book_rounded;
        break;
      case AppUpdateCategory.appNews:
        categoryColor = const Color(0xFF6A1B9A); // Purple
        categoryIcon = Icons.rocket_launch_rounded;
        break;
    }

    return InkWell(
      onTap: () {
        UpdatesRepository.instance.markAsRead(update.id);
        _showUpdateDetailsModal(context, update);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? AppColors.surfaceContainerLow.withValues(alpha: 0.5)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: update.isUrgent
                ? AppColors.error.withValues(alpha: 0.5)
                : (isRead ? AppColors.outlineVariant : AppColors.actionBlue.withValues(alpha: 0.3)),
            width: isRead ? 1 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Badge + Urgent Pill + Date & Bookmark
            Row(
              children: [
                // Category Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: categoryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(categoryIcon, size: 14, color: categoryColor),
                      const SizedBox(width: 6),
                      Text(
                        update.badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (update.isUrgent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.priority_high,
                            size: 12, color: AppColors.error),
                        SizedBox(width: 2),
                        Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  update.formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: isBookmarked ? AppColors.actionBlue : AppColors.outline,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    UpdatesRepository.instance.toggleBookmark(update.id);
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Title & Read Status Indicator
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isRead) ...[
                  Container(
                    margin: const EdgeInsets.only(top: 4, right: 8),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.actionBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    update.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15.5,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Summary
            Text(
              update.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 12),

            // Bottom Info Bar: Author, Read Time, & Read Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      update.author,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      update.readTime,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Read Announcement →',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDetailsModal(BuildContext context, AppUpdate update) {
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
              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.actionBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      update.category.displayName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.actionBlue,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      ListenableBuilder(
                        listenable: UpdatesRepository.instance,
                        builder: (context, _) {
                          final isBM = UpdatesRepository.instance
                              .isBookmarked(update.id);
                          return IconButton(
                            icon: Icon(
                              isBM ? Icons.bookmark : Icons.bookmark_border,
                              color: isBM ? AppColors.actionBlue : AppColors.outline,
                            ),
                            onPressed: () {
                              UpdatesRepository.instance
                                  .toggleBookmark(update.id);
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                update.title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),

              // Date & Author Info
              Row(
                children: [
                  const Icon(Icons.account_circle_outlined,
                      size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    update.author,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time,
                      size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    'Posted ${update.formattedDate} • ${update.readTime}',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const Divider(height: 28),

              // Main Body Content
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      update.content,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons Footer
              Row(
                children: [
                  if (update.actionButtonText != null) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (update.companyId != null &&
                              widget.onOpenCompanyDetail != null) {
                            widget.onOpenCompanyDetail!(update.companyId);
                          } else if (widget.onOpenPractice != null) {
                            widget.onOpenPractice!();
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(update.actionButtonText!),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
