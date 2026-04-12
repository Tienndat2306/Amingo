import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _dailyReminderEnabled = true;

  final List<StatItem> _stats = [
    StatItem(title: 'Learning Streak', value: '12', unit: 'days', icon: Icons.local_fire_department, color: Color(0xFFFF5722)),
    StatItem(title: 'Total Points', value: '2,450', unit: 'pts', icon: Icons.stars, color: Color(0xFFFFC107)),
    StatItem(title: 'Courses Completed', value: '8', unit: 'courses', icon: Icons.auto_awesome, color: Color(0xFF4CAF50)),
    StatItem(title: 'Hours Learned', value: '124', unit: 'hours', icon: Icons.timer, color: Color(0xFF2196F3)),
  ];

  final List<Achievement> _achievements = [
    Achievement(title: '7 Day Streak', description: 'Keep it up!', icon: Icons.local_fire_department, isUnlocked: true, progress: 1.0),
    Achievement(title: 'Vocabulary Master', description: 'Learn 500 words', icon: Icons.menu_book, isUnlocked: true, progress: 1.0),
    Achievement(title: 'Grammar Guru', description: 'Complete 10 grammar lessons', icon: Icons.article, isUnlocked: false, progress: 0.6),
    Achievement(title: 'Perfect Week', description: 'Study 7 days in a row', icon: Icons.emoji_events, isUnlocked: false, progress: 0.8),
  ];

  final List<MenuItem> _menuItems = [
    MenuItem(title: 'My Courses', icon: Icons.school, color: Color(0xFF775600)),
    MenuItem(title: 'Saved Lessons', icon: Icons.bookmark, color: Color(0xFF775600)),
    MenuItem(title: 'Downloaded Content', icon: Icons.download, color: Color(0xFF775600)),
    MenuItem(title: 'Language Settings', icon: Icons.language, color: Color(0xFF775600)),
    MenuItem(title: 'Notification Preferences', icon: Icons.notifications, color: Color(0xFF775600)),
    MenuItem(title: 'Help & Support', icon: Icons.help, color: Color(0xFF775600)),
    MenuItem(title: 'Privacy Policy', icon: Icons.privacy_tip, color: Color(0xFF775600)),
    MenuItem(title: 'Logout', icon: Icons.logout, color: Color(0xFFB02500)),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E3),
      appBar: _buildAppBar(colorScheme),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildStatsSection(),
            _buildAchievementsSection(),
            _buildSettingsSection(),
            _buildMenuSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: const Color(0xFFFFF6E3),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF775600)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Profile',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF3A2D00),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFF775600)),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDBC13), Color(0xFF775600)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://picsum.photos/200/200?random=profile',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withValues(alpha: 0.3),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // User Info
          Text(
            'Nguyễn Tiến Đạt',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'dattrithuc123@gmail.com',
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          // Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Explorer Level 8',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Statistics',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2D00),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: _stats.length,
            itemBuilder: (context, index) {
              return _buildStatCard(_stats[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(StatItem stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(stat.icon, size: 32, color: stat.color),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2D00),
            ),
          ),
          Text(
            stat.title,
            style: GoogleFonts.beVietnamPro(
              fontSize: 11,
              color: const Color(0xFF6B5A23),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3A2D00),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF775600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                return _buildAchievementCard(_achievements[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? const Color(0xFFFDBC13).withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked
              ? const Color(0xFFFDBC13)
              : const Color(0xFFC1AC6C).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? const Color(0xFFFDBC13)
                      : const Color(0xFFC1AC6C).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.isUnlocked ? const Color(0xFF543C00) : const Color(0xFF6B5A23),
                  size: 28,
                ),
              ),
              if (!achievement.isUnlocked)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: GoogleFonts.beVietnamPro(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: achievement.isUnlocked ? const Color(0xFF543C00) : const Color(0xFF6B5A23),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            achievement.description,
            style: GoogleFonts.beVietnamPro(
              fontSize: 9,
              color: const Color(0xFF6B5A23),
            ),
            textAlign: TextAlign.center,
          ),
          if (!achievement.isUnlocked) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: achievement.progress,
                backgroundColor: const Color(0xFFC1AC6C).withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDBC13)),
                minHeight: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2D00),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Dark Mode',
                  icon: Icons.dark_mode,
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildSwitchTile(
                  title: 'Push Notifications',
                  icon: Icons.notifications_active,
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildSwitchTile(
                  title: 'Daily Learning Reminder',
                  icon: Icons.alarm,
                  value: _dailyReminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      _dailyReminderEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF775600)),
      title: Text(
        title,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF3A2D00),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF775600);
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFFDBC13);
          }
          return null;
        }),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2D00),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < _menuItems.length; i++) ...[
                  _buildMenuItem(_menuItems[i]),
                  if (i < _menuItems.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return ListTile(
      leading: Icon(item.icon, color: item.color),
      title: Text(
        item.title,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: item.title == 'Logout' ? item.color : const Color(0xFF3A2D00),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: item.title == 'Logout' ? Colors.transparent : const Color(0xFFC1AC6C),
      ),
      onTap: () {
        if (item.title == 'Logout') {
          _showLogoutDialog();
        } else {
          // Handle navigation for other menu items
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2D00),
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              color: const Color(0xFF6B5A23),
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
                  color: const Color(0xFF6B5A23),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB02500),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class StatItem {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  StatItem({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final double progress;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.progress,
  });
}

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}