import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/video_lesson.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../data/services/video_service.dart';
import 'video_player_screen.dart';
import 'video_search_delegate.dart';

import '../widgets/video_card.dart';
import '../widgets/featured_video.dart';
import '../widgets/video_category_tabs.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final VideoRepository _videoRepository = VideoRepository();
  final VideoService _videoService = VideoService();
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Beginner', 'Intermediate', 'Advanced', 'Grammar'];

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _openVideo(VideoLesson video) {
    _videoService.markAsWatched(video.id).catchError((e) {
      debugPrint('Failed to save video watched status: $e');
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Video Lessons',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {
              showSearch(
                context: context,
                delegate: VideoSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<String>>(
        stream: _videoService.getAlreadyWatchedVideos(),
        builder: (context, watchedSnapshot) {
          final watchedVideoIds = watchedSnapshot.data ?? [];

          return StreamBuilder<List<VideoLesson>>(
            stream: _videoRepository.watchVideoLessons(onlyPublished: true),
            builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingWidget());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Connection error: ${snapshot.error}'));
          }

          final rawVideos = snapshot.data ?? [];
          final allVideos = rawVideos.where((v) => v.isPublished).toList();

          if (allVideos.isEmpty) {
            return const Center(child: Text('No public videos available'));
          }

          // Calculate counts for each category dynamically
          final Map<String, int> categoryCounts = {
            'All': allVideos.length,
            'Beginner': allVideos.where((v) => v.level.toLowerCase() == 'beginner').length,
            'Intermediate': allVideos.where((v) => v.level.toLowerCase() == 'intermediate').length,
            'Advanced': allVideos.where((v) => v.level.toLowerCase() == 'advanced').length,
            'Grammar': allVideos.where((v) => v.level.toLowerCase() == 'grammar').length,
          };

          final List<String> categoriesWithCounts = _categories.map((cat) {
            return "$cat (${categoryCounts[cat] ?? 0})";
          }).toList();

          final currentDisplayCategory = "$_selectedCategory (${categoryCounts[_selectedCategory] ?? 0})";

          // Filter videos based on selection
          final filteredVideos = _selectedCategory == 'All'
              ? allVideos
              : allVideos.where((v) => v.level.toLowerCase() == _selectedCategory.toLowerCase()).toList();

          // Handle featured videos list
          final featuredVideos = allVideos.where((v) => v.isFeatured).toList();
          if (featuredVideos.isEmpty && allVideos.isNotEmpty) {
            featuredVideos.add(allVideos.first);
          }

          return Column(
            children: [
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.93),
                  itemCount: featuredVideos.length,
                  itemBuilder: (context, index) {
                    final currentFeatured = featuredVideos[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FeaturedVideo(
                        video: currentFeatured,
                        onTap: () {
                          _openVideo(currentFeatured);
                        },
                      ),
                    );
                  },
                ),
              ),
              VideoCategoryTabs(
                categories: categoriesWithCounts,
                selectedCategory: currentDisplayCategory,
                onCategorySelected: (categoryWithCount) {
                  final rawCategory = categoryWithCount.split(' (').first;
                  _onCategorySelected(rawCategory);
                },
              ),
              Expanded(
                child: filteredVideos.isEmpty
                    ? const Center(child: Text('No matching videos found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: filteredVideos.length,
                        itemBuilder: (context, index) {
                          final video = filteredVideos[index];
                          return VideoCard(
                            video: video,
                            isWatched: watchedVideoIds.contains(video.id),
                            onTap: () {
                              _openVideo(video);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
            },
          );
        },
      ),
    );
  }
}
