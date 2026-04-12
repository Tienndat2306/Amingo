import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Beginner', 'Intermediate', 'Advanced', 'Grammar'];

  final List<VideoLesson> _videos = [
    VideoLesson(
      id: 1,
      title: 'Introduction to English',
      description: 'Learn the basics of English language',
      duration: '15:30',
      views: '12.5K',
      thumbnail: 'https://picsum.photos/400/200?random=1',
      level: 'Beginner',
    ),
    VideoLesson(
      id: 2,
      title: 'Common Phrases for Travel',
      description: 'Essential phrases for your next trip',
      duration: '22:15',
      views: '8.2K',
      thumbnail: 'https://picsum.photos/400/200?random=2',
      level: 'Beginner',
    ),
    VideoLesson(
      id: 3,
      title: 'Business English Conversation',
      description: 'Master professional communication',
      duration: '28:45',
      views: '5.1K',
      thumbnail: 'https://picsum.photos/400/200?random=3',
      level: 'Intermediate',
    ),
    VideoLesson(
      id: 4,
      title: 'Advanced Grammar Tips',
      description: 'Take your English to the next level',
      duration: '35:20',
      views: '3.8K',
      thumbnail: 'https://picsum.photos/400/200?random=4',
      level: 'Advanced',
    ),
  ];

  List<VideoLesson> get _filteredVideos {
    if (_selectedCategory == 'All') {
      return _videos;
    }
    return _videos.where((video) => video.level == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E3),
      appBar: _buildAppBar(colorScheme),
      body: Column(
        children: [
          _buildFeaturedVideo(),
          _buildCategoryTabs(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _filteredVideos.length,
              itemBuilder: (context, index) {
                return _buildVideoCard(_filteredVideos[index], colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: const Color(0xFFFFF6E3),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF775600)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Video Lessons',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF3A2D00),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: Color(0xFF775600)),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFeaturedVideo() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.all(20),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDBC13), Color(0xFF775600)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://picsum.photos/800/400?random=featured',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: const Color(0xFFFDBC13));
                  },
                ),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              left: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FEATURED VIDEO',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: const Color(0xFFFDBC13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete English\nCourse 2024',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Watch Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDBC13),
                      foregroundColor: const Color(0xFF543C00),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFDBC13) : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFC1AC6C).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF543C00)
                        : const Color(0xFF6B5A23),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(VideoLesson video, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  // Thumbnail image
                  Image.network(
                    video.thumbnail,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.video_library,
                          size: 50,
                          color: Color(0xFF775600),
                        ),
                      );
                    },
                  ),
                  // Play button overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDBC13),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Color(0xFF543C00),
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            video.duration,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Level badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getLevelColor(video.level),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        video.level,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    video.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3A2D00),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    video.description,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      color: const Color(0xFF6B5A23),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Stats row
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 14, color: const Color(0xFF6B5A23)),
                      const SizedBox(width: 4),
                      Text(
                        video.views,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          color: const Color(0xFF6B5A23),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 14, color: const Color(0xFF6B5A23)),
                      const SizedBox(width: 4),
                      Text(
                        video.duration,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          color: const Color(0xFF6B5A23),
                        ),
                      ),
                      const Spacer(),
                      // Watch later button
                      IconButton(
                        icon: const Icon(Icons.watch_later_outlined, size: 20),
                        color: const Color(0xFF775600),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      // Share button
                      IconButton(
                        icon: const Icon(Icons.share, size: 20),
                        color: const Color(0xFF775600),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return const Color(0xFF775600);
    }
  }
}

class VideoLesson {
  final int id;
  final String title;
  final String description;
  final String duration;
  final String views;
  final String thumbnail;
  final String level;

  VideoLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.views,
    required this.thumbnail,
    required this.level,
  });
}