import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/video_lesson.dart';
import '../../../data/repositories/video_repository.dart';
import 'admin_video_detail_screen.dart';
import 'admin_add_video_screen.dart';

class AdminVideoScreen extends StatefulWidget {
  const AdminVideoScreen({super.key});

  @override
  State<AdminVideoScreen> createState() => _AdminVideoScreenState();
}

class _AdminVideoScreenState extends State<AdminVideoScreen> {
  final VideoRepository _videoRepository = VideoRepository();

  String _selectedLevel = 'All';
  final List<String> _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addVideo() async {
    final isReload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AdminAddVideoScreen()),
    );

    if (isReload == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteVideo(String videoId, String videoTitle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Delete',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete the video lesson "$videoTitle"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _videoRepository.deleteVideoLesson(videoId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Video deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Delete failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 2 : 1;
    final cardWidth = crossAxisCount == 2
        ? (screenWidth - 64) / 2
        : screenWidth - 48;

    const Color primaryColor = Color(0xFF795548);
    const Color activeChipColor = Color(0xFFFFF8E1);
    const Color activeBorderColor = Color(0xFFFFB74D);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Video Lessons',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addVideo,
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  'Add Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: primaryColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search lesson titles...',
              hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.55)),
              prefixIcon: const Icon(
                Icons.search,
                color: primaryColor,
                size: 22,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: activeChipColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: activeBorderColor,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim();
              });
            },
          ),
        ),

        Expanded(
          child: StreamBuilder<List<VideoLesson>>(
            stream: _videoRepository.watchVideoLessons(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingWidget());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading data: ${snapshot.error}'),
                );
              }

              final videos = snapshot.data ?? [];

              int getLevelCount(String level) {
                if (level == 'All') return videos.length;
                return videos
                    .where((v) => v.level.toLowerCase() == level.toLowerCase())
                    .length;
              }

              final filteredVideos = videos.where((video) {
                final matchesLevel =
                    _selectedLevel == 'All' ||
                    video.level.toLowerCase() == _selectedLevel.toLowerCase();

                final matchesSearch =
                    _searchQuery.isEmpty ||
                    video.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );

                return matchesLevel && matchesSearch;
              }).toList();

              return Column(
                children: [
                  SizedBox(
                    height: 46,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      itemCount: _levels.length,
                      itemBuilder: (context, index) {
                        final level = _levels[index];
                        final isSelected = _selectedLevel == level;
                        final count = getLevelCount(level);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              '$level ($count)',
                              style: TextStyle(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() {
                                  _selectedLevel = level;
                                });
                              }
                            },
                            selectedColor: activeChipColor,
                            backgroundColor: Colors.white,
                            showCheckmark: false,
                            elevation: 0,
                            pressElevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? activeBorderColor
                                    : Colors.grey[200]!,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: videos.isEmpty
                        ? const Center(
                            child: Text(
                              'No video lessons available. Click Add Video to add one!',
                            ),
                          )
                        : filteredVideos.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'No results found for "$_searchQuery".'
                                  : 'No video lessons found at level "$_selectedLevel".',
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.only(
                              left: 24,
                              right: 24,
                              bottom: 24,
                            ),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.start,
                              children: filteredVideos.map((video) {
                                return SizedBox(
                                  width: cardWidth,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AdminVideoDetailScreen(
                                                video: video,
                                              ),
                                        ),
                                      );
                                    },
                                    child: _buildVideoCard(video),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(VideoLesson video) {
    final bool hasSubtitles = video.hasSubtitles;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      video.thumbnail.isNotEmpty
                          ? video.thumbnail
                          : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF795548).withValues(alpha: 0.1),
                      const Color(0xFF4E342E).withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF795548),
                      size: 28,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF795548),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    video.level,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E2723).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        video.duration,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  video.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  video.description,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                Divider(color: Colors.brown[50], height: 1),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${video.views.toString().isEmpty ? "0" : video.views} views',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: hasSubtitles
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: hasSubtitles
                                      ? const Color(0xFFC8E6C9)
                                      : const Color(0xFFFFCDD2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    hasSubtitles
                                        ? Icons.subtitles_rounded
                                        : Icons.subtitles_off_rounded,
                                    size: 12,
                                    color: hasSubtitles
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    hasSubtitles ? 'Has Sub' : 'No Sub',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 11,
                                      color: hasSubtitles
                                          ? Colors.green[800]
                                          : Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 6),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: video.isPublished
                                    ? const Color(0xFFE0F2F1)
                                    : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: video.isPublished
                                      ? const Color(0xB3B2DFDB)
                                      : const Color(0xB3FFE0B2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    video.isPublished
                                        ? Icons.public_rounded
                                        : Icons.lock_clock_rounded,
                                    size: 12,
                                    color: video.isPublished
                                        ? Colors.teal[700]
                                        : Colors.orange[800],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    video.isPublished ? 'Public' : 'Private',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 11,
                                      color: video.isPublished
                                          ? Colors.teal[800]
                                          : Colors.orange[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 6),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: video.isFeatured
                                    ? const Color(0xFFFFF8E1)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: video.isFeatured
                                      ? const Color(0xFFFFE082)
                                      : const Color(0xFFE0E0E0),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    video.isFeatured
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 12,
                                    color: video.isFeatured
                                        ? Colors.amber[900]
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    video.isFeatured ? 'Featured' : 'Normal',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 11,
                                      color: video.isFeatured
                                          ? Colors.amber[900]
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                      onPressed: () => _deleteVideo(video.id, video.title),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
