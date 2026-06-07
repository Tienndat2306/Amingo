import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/video_lesson.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../data/services/video_service.dart';
import 'video_player_screen.dart';

class VideoSearchDelegate extends SearchDelegate {
  final VideoRepository _videoRepository = VideoRepository();
  final VideoService _videoService = VideoService();

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
        border: InputBorder.none,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Search video lessons...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Text(
            "Enter video title to search...",
            style: TextStyle(
              color: AppColors.primary, 
              fontSize: 16, 
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return Container(
      color: AppColors.background,
      child: FutureBuilder<List<VideoLesson>>(
        future: _videoRepository.searchVideoLessons(query, onlyPublished: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No matching videos found.",
                style: TextStyle(color: AppColors.primary, fontSize: 16),
              ),
            );
          }

          final results = snapshot.data!;

          return ListView.builder(
            itemCount: results.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final video = results[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      video.thumbnail,
                      width: 80,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(Icons.video_library),
                      ),
                    ),
                  ),
                  title: Text(
                    video.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.black87, 
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "Views: ${video.views} • Level: ${video.level}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.play_circle_fill, 
                    color: AppColors.primary, 
                    size: 28,
                  ),
                  onTap: () {
                    _videoService.markAsWatched(video.id).catchError((e) {
                      debugPrint('Failed to save video watched status: $e');
                    });
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
      ),
    );
  }
}
