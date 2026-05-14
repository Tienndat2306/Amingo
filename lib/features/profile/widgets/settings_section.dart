import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class SettingsSection extends StatelessWidget {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final Function(bool) onDarkModeChanged;
  final Function(bool) onNotificationsChanged;
  final Function(bool) onDailyReminderChanged;

  const SettingsSection({
    super.key,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.dailyReminderEnabled,
    required this.onDarkModeChanged,
    required this.onNotificationsChanged,
    required this.onDailyReminderChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.textPrimary,
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
                  value: isDarkMode,
                  onChanged: onDarkModeChanged,
                ),
                const Divider(height: 1, indent: 56),
                _buildSwitchTile(
                  title: 'Push Notifications',
                  icon: Icons.notifications_active,
                  value: notificationsEnabled,
                  onChanged: onNotificationsChanged,
                ),
                const Divider(height: 1, indent: 56),
                _buildSwitchTile(
                  title: 'Daily Learning Reminder',
                  icon: Icons.alarm,
                  value: dailyReminderEnabled,
                  onChanged: onDailyReminderChanged,
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
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
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
}