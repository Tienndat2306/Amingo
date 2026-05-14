import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class MenuItemData {
  final String title;
  final IconData icon;
  final Color color;

  MenuItemData({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class MenuSection extends StatelessWidget {
  final List<MenuItemData> menuItems;
  final VoidCallback onLogout;

  const MenuSection({
    super.key,
    required this.menuItems,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
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
                for (int i = 0; i < menuItems.length; i++) ...[
                  _buildMenuItem(menuItems[i]),
                  if (i < menuItems.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItemData item) {
    final isLogout = item.title == 'Logout';
    return ListTile(
      leading: Icon(item.icon, color: item.color),
      title: Text(
        item.title,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isLogout ? item.color : AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isLogout ? Colors.transparent : const Color(0xFFC1AC6C),
      ),
      onTap: () {
        if (isLogout) {
          onLogout();
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}