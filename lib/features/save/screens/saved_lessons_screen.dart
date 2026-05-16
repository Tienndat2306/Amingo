import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../widgets/saved_articles_tab.dart';
import '../widgets/saved_vocabulary_tab.dart';
import '../widgets/saved_videos_tab.dart';

class SavedLessonsScreen extends StatelessWidget {
  const SavedLessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    return DefaultTabController(
      length: 3, // 🌟 Tăng lên 3 Tab cho Articles, Vocabulary và Videos
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(
          title: 'Saved Lessons',
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            // Thanh TabBar bo tròn đồng bộ giao diện màu vàng hổ phách
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: const Color(0xFFD49A15), // Màu vàng hổ phách
                  borderRadius: BorderRadius.circular(100),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [
                  Tab(text: 'Articles'),
                  Tab(text: 'Vocabulary'),
                  Tab(text: 'Videos'), // 🌟 Thêm tab mới
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Gọi các file Widget tương ứng cho từng Tab
            Expanded(
              child: TabBarView(
                children: [
                  SavedArticlesTab(userId: currentUserId),
                  SavedVocabularyTab(userId: currentUserId),
                  SavedVideosTab(userId: currentUserId), // 🌟 Thêm tab mới
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}