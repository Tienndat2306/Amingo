import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/video_lesson.dart';
import '../../../data/services/video_service.dart';

class VideoCard extends StatefulWidget {
  final VideoLesson video;
  final VoidCallback onTap;
  final bool isWatched;

  const VideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.isWatched = false,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  final VideoService _videoService = VideoService();
  bool _isMarkingAsWatched = false;

  @override
  Widget build(BuildContext context) {
    final Color watchedBgColor = widget.isWatched
        ? const Color(0xFFD49A15)
        : AppColors.primary.withValues(alpha: 0.1);
    final Color watchedIconColor = widget.isWatched
        ? Colors.white
        : AppColors.primary;

    return GestureDetector(
      onTap: widget.onTap,
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
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    widget.video.thumbnail,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(Icons.video_library, size: 50, color: AppColors.primary),
                      );
                    },
                  ),
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
                          child: const Icon(Icons.play_arrow, color: Color(0xFF543C00), size: 30),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            widget.video.duration,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildLevelBadge(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.video.description,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.visibility, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        widget.video.views,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        widget.video.duration,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: watchedBgColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: _isMarkingAsWatched
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: Padding(
                                  padding: EdgeInsets.all(11),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.done_all, size: 20),
                                color: watchedIconColor,
                                onPressed: widget.isWatched
                                    ? null
                                    : () async {
                                        setState(
                                          () => _isMarkingAsWatched = true,
                                        );
                                        try {
                                          await _videoService.markAsWatched(
                                            widget.video.id,
                                          );
                                        } catch (e) {
                                          debugPrint(
                                            'Failed to save video watched status: $e',
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(
                                              () =>
                                                  _isMarkingAsWatched = false,
                                            );
                                          }
                                        }
                                      },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      StreamBuilder<bool>(
                        stream: _videoService.isVideoSaved(widget.video.id),
                        builder: (context, snapshot) {
                          final isSaved = snapshot.data ?? false;

                          return Container(
                            decoration: BoxDecoration(
                              color: isSaved
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: IconButton(
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 20,
                              ),
                              color: isSaved ? Colors.orange : AppColors.primary,
                              onPressed: () async {
                                try {
                                  await _videoService.toggleSaveVideo(
                                    widget.video,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isSaved
                                              ? 'Removed from saved videos'
                                              : 'Added to saved videos',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          );
                        },
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

  Widget _buildLevelBadge() {
    Color levelColor;
    switch (widget.video.level.toLowerCase()) {
      case 'beginner':
        levelColor = Colors.green;
        break;
      case 'intermediate':
        levelColor = Colors.orange;
        break;
      case 'advanced':
        levelColor = Colors.red;
        break;
      default:
        levelColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: levelColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        widget.video.level,
        style: GoogleFonts.beVietnamPro(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
