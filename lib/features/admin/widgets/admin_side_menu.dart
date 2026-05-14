import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../screens/admin_login_screen.dart';
import '/features/auth/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';

class AdminSideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<MenuItem> _menuItems = const [
    MenuItem(icon: Icons.dashboard, label: 'Dashboard', index: 0),
    MenuItem(icon: Icons.menu_book, label: 'Vocabulary', index: 1),
    MenuItem(icon: Icons.article, label: 'Grammar', index: 2),
    MenuItem(icon: Icons.headphones, label: 'Listening', index: 3),
    MenuItem(icon: Icons.video_library, label: 'Video', index: 4),
    MenuItem(icon: Icons.newspaper, label: 'News', index: 5),
  ];

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to sign out of Admin Panel?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  // 1. Đăng xuất khỏi Firebase Auth
                  await FirebaseAuth.instance.signOut();

                  // 2. Xóa dữ liệu trong UserProvider (nếu có dùng Provider)
                  // Chú ý: listen: false là bắt buộc khi gọi trong hàm xử lý sự kiện
                  if (context.mounted) {
                    Provider.of<UserProvider>(context, listen: false).clearUser();
                  }

                  // 3. Điều hướng và xóa toàn bộ lịch sử stack các màn hình cũ
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                    );
                  }
                } catch (e) {
                  debugPrint("Logout Error: $e");
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.adminSidebar,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.adminPrimary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Amingo Admin',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final isSelected = selectedIndex == item.index;
                  return _buildMenuItem(
                    icon: item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    onTap: () => onItemSelected(item.index),
                  );
                },
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            _buildMenuItem(
              icon: Icons.logout,
              label: 'Logout',
              isSelected: false,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.surface : Colors.white70, size: 22),
      title: Text(
        label,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.surface : Colors.white70,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.white.withValues(alpha: 0.1),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String label;
  final int index;

  const MenuItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}