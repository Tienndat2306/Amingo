import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/achievement_card.dart';
import '../widgets/settings_section.dart';
import '../widgets/menu_item.dart';
import '../../auth/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// ============ MAIN SCREEN ============

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<AchievementData> _achievements = [
    AchievementData(title: '7 Day Streak', description: 'Keep it up!', icon: Icons.local_fire_department, isUnlocked: true, progress: 1.0),
    AchievementData(title: 'Vocabulary Master', description: 'Learn 500 words', icon: Icons.menu_book, isUnlocked: true, progress: 1.0),
    AchievementData(title: 'Grammar Guru', description: 'Complete 10 grammar lessons', icon: Icons.article, isUnlocked: false, progress: 0.6),
    AchievementData(title: 'Perfect Week', description: 'Study 7 days in a row', icon: Icons.emoji_events, isUnlocked: false, progress: 0.8),
  ];

  final List<MenuItemData> _menuItems = [
    MenuItemData(title: 'My Courses', icon: Icons.school, color: AppColors.primary),
    MenuItemData(title: 'Saved Lessons', icon: Icons.bookmark, color: AppColors.primary),
    MenuItemData(title: 'Downloaded Content', icon: Icons.download, color: AppColors.primary),
    MenuItemData(title: 'Language Settings', icon: Icons.language, color: AppColors.primary),
    MenuItemData(title: 'Notification Preferences', icon: Icons.notifications, color: AppColors.primary),
    MenuItemData(title: 'Help & Support', icon: Icons.help, color: AppColors.primary),
    MenuItemData(title: 'Privacy Policy', icon: Icons.privacy_tip, color: AppColors.primary),
    MenuItemData(title: 'Logout', icon: Icons.logout, color: AppColors.error),
  ];

  Future<void> _updateSetting(String fieldName, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({fieldName: value});

        if (mounted) {
          await Provider.of<UserProvider>(context, listen: false).fetchUserData();
        }
      } catch (e) {
        debugPrint("Lỗi cập nhật cài đặt: $e");
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.beVietnamPro(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Đăng xuất khỏi Firebase
              await FirebaseAuth.instance.signOut();
              // 2. Xóa dữ liệu trong Provider
              if (mounted) {
                Provider.of<UserProvider>(context, listen: false).clearUser();
              }
              // 3. Quay về trang Login và xóa lịch sử chuyển trang
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Lấy dữ liệu từ Provider
          final userData = userProvider.userData;
          final fullName = userData?['name'] ?? 'User';
          final email = userData?['email'] ?? 'No email';

          bool isDarkMode = userData?['isDarkMode'] ?? false;
          bool notificationsEnabled = userData?['notifications'] ?? false;
          bool dailyReminderEnabled = userData?['dailyreminder'] ?? false;

          final List<StatItem> stats = [
            StatItem(
                title: 'Learning Streak',
                value: '${userData?['streak'] ?? 0}',
                unit: 'days',
                icon: Icons.local_fire_department,
                color: const Color(0xFFFF5722)
            ),
            StatItem(
                title: 'Total Points',
                value: '${userData?['totalPoint'] ?? 0}',
                unit: 'pts',
                icon: Icons.stars,
                color: const Color(0xFFFFC107)
            ),
            StatItem(
                title: 'Courses Completed',
                value: '${userData?['coursesCompleted'] ?? 0}',
                unit: 'courses',
                icon: Icons.auto_awesome,
                color: const Color(0xFF4CAF50)
            ),
            StatItem(
                title: 'Hours Learned',
                value: '${userData?['totalHoursOfWeeks'] ?? 0}',
                unit: 'hours',
                icon: Icons.timer,
                color: const Color(0xFF2196F3)
            ),
          ];

          return SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(
                  name: fullName,
                  email: email,
                  avatarUrl: 'https://ui-avatars.com/api/?name=${fullName.replaceAll(' ', '+')}&background=random',
                ),
                StatsSection(stats: stats),
                AchievementsSection(achievements: _achievements),
                SettingsSection(
                  isDarkMode: isDarkMode,
                  notificationsEnabled: notificationsEnabled,
                  dailyReminderEnabled: dailyReminderEnabled,

                  onDarkModeChanged: (value) => _updateSetting('isDarkMode', value),
                  onNotificationsChanged: (value) => _updateSetting('notifications', value),
                  onDailyReminderChanged: (value) => _updateSetting('dailyreminder', value),
                ),
                MenuSection(
                  menuItems: _menuItems,
                  onLogout: _handleLogout,
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}