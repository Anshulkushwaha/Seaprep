import 'package:flutter/material.dart';
import 'ai_chat_widget.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onNavigationIndexChanged;
  final VoidCallback onLogout;
  final String title;

  const AppScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onNavigationIndexChanged,
    required this.onLogout,
    this.title = 'SeaPrep',
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final currentUser = AuthService.instance.currentUser;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // App Title & Logo
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.asset(
                            'assets/logos/seaprep_logo.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // User display chip
                  if (currentUser != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_pin, size: 16, color: AppColors.actionBlue),
                          const SizedBox(width: 6),
                          Text(
                            currentUser.email,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // User Profile Popup Menu / Log Out
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') {
                        onLogout();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'user',
                        enabled: false,
                        child: Row(
                          children: [
                            const Icon(Icons.account_circle, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              currentUser?.email ?? 'Cadet User',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: AppColors.error, size: 20),
                            SizedBox(width: 8),
                            Text('Log Out', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              // Desktop Sidebar Navigation
              if (isDesktop)
                Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      right: BorderSide(color: AppColors.outlineVariant, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // User Info Card in Sidebar
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.secondaryContainer,
                              radius: 18,
                              child: Text(
                                currentUser?.email.isNotEmpty == true
                                    ? currentUser!.email[0].toUpperCase()
                                    : 'C',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentUser?.displayName ?? 'Cadet User',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    currentUser?.email ?? 'Deck / Engine',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Log Out Button in sidebar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OutlinedButton.icon(
                          onPressed: onLogout,
                          icon: const Icon(Icons.logout, size: 16, color: AppColors.error),
                          label: const Text('Log Out', style: TextStyle(color: AppColors.error, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            minimumSize: const Size(double.infinity, 38),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Navigation Links
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            _buildNavItem(0, Icons.dashboard, 'Home'),
                            _buildNavItem(1, Icons.business_center, 'Companies'),
                            _buildNavItem(2, Icons.menu_book, 'Practice'),
                            _buildNavItem(3, Icons.quiz, 'MCQ Test'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Main Body Content
              Expanded(child: body),
            ],
          ),
          const AiChatFloatingWidget(),
        ],
      ),
      // Mobile Bottom Navigation Bar
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.outlineVariant, width: 1),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: onNavigationIndexChanged,
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.surface,
                selectedItemColor: AppColors.actionBlue,
                unselectedItemColor: AppColors.onSurfaceVariant,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.business_center),
                    label: 'Companies',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book),
                    label: 'Practice',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.quiz),
                    label: 'MCQ Test',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onNavigationIndexChanged(index),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.actionBlue : AppColors.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.actionBlue : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
