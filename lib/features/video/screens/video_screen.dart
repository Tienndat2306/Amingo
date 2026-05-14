import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/video_lesson.dart';
import '../../../data/mock/mock_video.dart';
import '../widgets/video_card.dart';
import '../widgets/featured_video.dart';
import '../widgets/video_category_tabs.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  List<VideoLesson> _videos = [];
  List<VideoLesson> _filteredVideos = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Beginner', 'Intermediate', 'Advanced', 'Grammar'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _videos = MockVideoData.getMockVideoLessons();
    _filterVideos();
    setState(() => _isLoading = false);
  }

  void _filterVideos() {
    if (_selectedCategory == 'All') {
      _filteredVideos = _videos;
    } else {
      _filteredVideos = _videos.where((video) => video.level == _selectedCategory).toList();
    }
    setState(() {});
  }

  void _onCategorySelected(String category) {
    _selectedCategory = category;
    _filterVideos();
  }

  VideoLesson? get featuredVideo => _videos.firstWhere((v) => v.isFeatured, orElse: () => _videos.first);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Video Lessons',
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (!_isLoading && _videos.isNotEmpty)
            FeaturedVideo(video: featuredVideo!, onTap: () {}),
          VideoCategoryTabs(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : RefreshIndicator(
              onRefresh: _loadData,
              child: _filteredVideos.isEmpty
                  ? const Center(child: Text('No videos found'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _filteredVideos.length,
                itemBuilder: (context, index) {
                  return VideoCard(
                    video: _filteredVideos[index],
                    onTap: () {},
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}