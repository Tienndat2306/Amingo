import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/video_lesson.dart';
import '../../video/screens/video_player_screen.dart';
import 'empty_state_widget.dart';

class SavedVideosTab extends StatelessWidget {
  final String userId;
  final String searchQuery;

  const SavedVideosTab({
    super.key,
    required this.userId,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Giả định collection lưu trữ video yêu thích trên Firestore là 'saved_videos'
      stream: FirebaseFirestore.instance
          .collection('saved_videos')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingWidget());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.video_library_outlined,
            message: 'No saved videos yet.',
          );
        }

        final query = searchQuery.toLowerCase().trim();
        final videoDocs = snapshot.data!.docs.where((doc) {
          if (query.isEmpty) return true;
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          return title.contains(query);
        }).toList();

        if (videoDocs.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.search_off,
            message: 'No saved videos match your search.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: videoDocs.length,
          itemBuilder: (context, index) {
            final doc = videoDocs[index];
            final data = doc.data() as Map<String, dynamic>;

            final String title = data['title'] ?? 'Untitled Video';
            final String duration = data['duration'] ?? '00:00';
            final String thumbnailUrl =
                data['thumbnailUrl'] ?? data['thumbnail'] ?? '';
            final video = VideoLesson.fromJson({
              ...data,
              'id': data['id'] ?? doc.id,
              'thumbnail': thumbnailUrl,
            });

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        thumbnailUrl,
                        width: 100,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 70,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.video_collection, color: AppColors.primary),
                        ),
                      ),
                      // Icon Play phủ mờ nhỏ giữa lòng Thumbnail tạo cảm giác nút bấm video
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                      )
                    ],
                  ),
                ),
                title: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.done_all, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('saved_videos').doc(doc.id).delete();
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(video: video),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
