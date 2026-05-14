import 'package:amingo/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/admin_side_menu.dart';
import '../widgets/admin_stat_card.dart';
import 'admin_vocabulary_screen.dart';
import 'admin_grammar_screen.dart';
import 'admin_listening_screen.dart';
import 'admin_video_screen.dart';
import 'admin_news_screen.dart';
import 'admin_login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const _DashboardContent(),
    const AdminVocabularyScreen(),
    const AdminGrammarScreen(),
    const AdminListeningScreen(),
    const AdminVideoScreen(),
    const AdminNewsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Vocabulary Management',
    'Grammar Management',
    'Listening Management',
    'Video Management',
    'News Management',
  ];

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).clearUser();
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Admin Logout Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              } else if (value == 'profile') {
              }
            },
          ),
        ],
      ),
      drawer: AdminSideMenu(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),
      body: _screens[_selectedIndex],
    );
  }
}

// Phần _DashboardContent giữ nguyên như cũ
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final cardWidth = (screenWidth - 72) / (isSmallScreen ? 1 : 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppGradients.adminGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, Admin!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Here\'s what\'s happening with your platform today.',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics, size: 32, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Statistics',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: cardWidth,
                child: const AdminStatCard(
                  title: 'Total Users',
                  value: '1,234',
                  icon: Icons.people,
                  color: Color(0xFF3F51B5),
                  change: '+12%',
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: const AdminStatCard(
                  title: 'Total Lessons',
                  value: '156',
                  icon: Icons.school,
                  color: Color(0xFF4CAF50),
                  change: '+8%',
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: const AdminStatCard(
                  title: 'Active Users',
                  value: '892',
                  icon: Icons.person,
                  color: Color(0xFFFF9800),
                  change: '+5%',
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: const AdminStatCard(
                  title: 'Completion Rate',
                  value: '68%',
                  icon: Icons.trending_up,
                  color: Color(0xFF9C27B0),
                  change: '+3%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Quick Actions',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickAction(icon: Icons.add, label: 'Add Lesson', color: const Color(0xFF4CAF50)),
              _buildQuickAction(icon: Icons.edit, label: 'Edit Content', color: const Color(0xFF2196F3)),
              _buildQuickAction(icon: Icons.people, label: 'Manage Users', color: const Color(0xFFFF9800)),
              _buildQuickAction(icon: Icons.analytics, label: 'View Reports', color: const Color(0xFF9C27B0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}