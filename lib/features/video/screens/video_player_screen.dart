import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/video_lesson.dart';
import '../../../data/models/subtitle_item.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../data/services/video_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoLesson video;
  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  StreamSubscription<YoutubeVideoState>? _videoStateSubscription;
  final VideoRepository _videoRepository = VideoRepository();
  final VideoService _videoService = VideoService();
  final ScrollController _scrollController = ScrollController();

  List<SubtitleItem> _subtitles = [];
  bool _isLoading = true;
  String _errorMessage = "";
  int _currentHighlightIndex = -1;

  @override
  void initState() {
    super.initState();

    final ytId =
        YoutubePlayerController.convertUrlToId(widget.video.videoUrl) ?? '';

    _controller = YoutubePlayerController.fromVideoId(
      videoId: ytId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: true,
        enableCaption: false,
      ),
    );
    _videoStateSubscription = _controller.videoStateStream.listen(
      _onPlayerStateChange,
    );

    _loadData();
    _videoService.markAsWatched(widget.video.id).catchError((e) {
      debugPrint('Failed to save video watched status: $e');
    });
    _videoRepository.incrementVideoViews(widget.video.id);
  }

  Future<void> _loadData() async {
    try {
      final youtubeId =
          YoutubePlayerController.convertUrlToId(widget.video.videoUrl) ??
          widget.video.id;
      final data = await _videoRepository.fetchSubtitles(youtubeId);

      if (!mounted) return;

      setState(() {
        _subtitles = data;
        _isLoading = false;
        if (_subtitles.isEmpty) {
          _errorMessage = "No automatic subtitles available for this video.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "System error: Unable to load subtitles.";
      });
    }
  }

  void _onPlayerStateChange(YoutubeVideoState state) {
    if (_subtitles.isEmpty || !mounted) return;

    final currentTime = state.position.inMilliseconds / 1000.0;

    int foundIndex = _subtitles.indexWhere(
      (sub) => currentTime >= sub.start && currentTime <= sub.end,
    );

    if (foundIndex != -1 && foundIndex != _currentHighlightIndex) {
      setState(() {
        _currentHighlightIndex = foundIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.video.title,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown[800],
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Column(
        children: [
          YoutubePlayer(controller: _controller),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.translate, color: Colors.brown[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  "SMART TRANSCRIPT (CLICK TO SEEK):",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  )
                : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.brown[600],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      bottom: 40,
                      left: 12,
                      right: 12,
                    ),
                    itemCount: _subtitles.length,
                    itemBuilder: (context, index) {
                      final subItem = _subtitles[index];
                      final isHighlight = index == _currentHighlightIndex;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _controller.seekTo(
                            seconds: subItem.start,
                            allowSeekAhead: true,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: isHighlight
                                ? LinearGradient(
                                    colors: [
                                      Colors.amber.withValues(alpha: 0.25),
                                      Colors.orange.withValues(alpha: 0.15),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isHighlight
                                  ? Colors.brown.withValues(alpha: 0.3)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 3,
                                  right: 10,
                                ),
                                child: Text(
                                  _formatDuration(subItem.start),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isHighlight
                                        ? Colors.brown[900]
                                        : Colors.brown[400],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 5.0,
                                      runSpacing: 3.0,
                                      children: subItem.content.split(' ').map((
                                        word,
                                      ) {
                                        return Text(
                                          word,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: isHighlight
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isHighlight
                                                ? Colors.brown[900]
                                                : Colors.brown[700],
                                            height: 1.4,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    if (subItem.vi.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 2,
                                        ),
                                        child: Text(
                                          subItem.vi,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isHighlight
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isHighlight
                                                ? Colors.brown[600]
                                                : Colors.brown[400],
                                            height: 1.3,
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
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final int minutes = (seconds / 60).floor();
    final int remainingSeconds = (seconds % 60).floor();
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _videoStateSubscription?.cancel();
    unawaited(_controller.close());
    _scrollController.dispose();
    super.dispose();
  }
}
