import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
// import '../../../core/widgets/custom_app_bar.dart';
import '../widgets/daily_progress_card.dart';
import '../widgets/vocabulary_card.dart';
import '../widgets/grammar_card.dart';
import '../widgets/listening_card.dart';
import '../widgets/video_card.dart';
import '../widgets/news_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../vocabulary/screens/vocabulary_screen.dart';
import '../../grammar/screens/grammar_screen.dart';
import '../../listening/screens/listening_screen.dart';
import '../../video/screens/video_screen.dart';
import '../../news/screens/news_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DailyProgressCard(progress: 0.8),
                  const SizedBox(height: 40),
                  _buildLearningModules(),
                ],
              ),
            ),
          ),
          BottomNavBar(
            selectedIndex: _selectedNavIndex,
            onItemSelected: (index) {
              if (index == 4) {
                _navigateTo(const ProfileScreen());
              } else {
                setState(() => _selectedNavIndex = index);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(){
    return SafeArea(
      bottom: false,
      child: Consumer<UserProvider>(
       builder: (context, userProvider, child){
         final fullName = userProvider.userData?['name'] ?? 'User';

         // Họ
         final firstName = fullName.trim().split(' ').first;
         // Tên
         // final lastName = fullName.trim().split(' ').last;

         return Container(
           color: AppColors.background,
           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
           child: Row(
             children: [
               Container(
                 width: 48,
                 height: 48,
                 decoration: BoxDecoration(
                   color: const Color(0xFFFDE18B),
                   borderRadius: BorderRadius.circular(10),
                   boxShadow: [
                     BoxShadow(
                       color: AppColors.textPrimary.withValues(alpha: 0.1),
                       blurRadius: 10,
                       offset: const Offset(0, 4),
                     ),
                   ],
                 ),
                 child: Center(
                   child: Image.asset(
                     'assets/logo/amingo_logo_5-removebg-preview.png',
                     height: 32,
                     width: 32,
                     fit: BoxFit.contain,
                   ),
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: Text(
                   'Welcome $firstName',
                   style: GoogleFonts.plusJakartaSans(
                     fontSize: 22,
                     fontWeight: FontWeight.w800,
                     color: AppColors.textPrimary,
                   ),
                   overflow: TextOverflow.ellipsis,
                 ),
               ),
             ],
           ),
         );
       }
      ),
    );
  }

  Widget _buildLearningModules() {
    return Column(
      children: [
        VocabularyCard(onTap: () => _navigateTo(const VocabularyScreen())),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: NewsCard(onTap: () => _navigateTo(const NewsScreen()))),
              const SizedBox(width: 16),
              Expanded(child: ListeningCard(onTap: () => _navigateTo(const ListeningScreen()))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: VideoCard(onTap: () => _navigateTo(const VideoScreen()))),
              const SizedBox(width: 16),
              Expanded(child: GrammarCard(onTap: () => _navigateTo(const GrammarScreen()))),
            ],
          ),
        ),
      ],
    );
  }
}