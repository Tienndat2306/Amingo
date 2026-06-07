import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../data/models/video_lesson.dart';
import '../../../data/models/subtitle_item.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../core/widgets/loading_widget.dart';
import 'admin_edit_video_screen.dart';

class AdminVideoDetailScreen extends StatefulWidget {
  final VideoLesson video;
  const AdminVideoDetailScreen({super.key, required this.video});

  @override
  State<AdminVideoDetailScreen> createState() => _AdminVideoDetailScreenState();
}

class _AdminVideoDetailScreenState extends State<AdminVideoDetailScreen> {
  late YoutubePlayerController _youtubeController;
  StreamSubscription<YoutubeVideoState>? _videoStateSubscription;
  final VideoRepository _videoRepository = VideoRepository();

  late VideoLesson _currentVideo;
  List<SubtitleItem> _subtitlesList = [];
  List<SubtitleItem> _activeSubtitles = [];
  bool _isPlayerInitialized = false;

  static const Color _primaryColor = Color(0xFF795548);
  static const Color _labelColor = Color(0xFF5D4037);
  static const Color _textColor = Color(0xFF212121);

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _initPlayer();
  }

  void _initPlayer() {
    final videoId =
        YoutubePlayerController.convertUrlToId(_currentVideo.videoUrl) ?? '';
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: true,
        enableCaption: false,
      ),
    );
    _videoStateSubscription = _youtubeController.videoStateStream.listen(
      _onVideoProgress,
    );

    setState(() => _isPlayerInitialized = true);
  }

  Future<void> _refreshVideoData() async {
    try {
      final latest = await _videoRepository.getVideoById(_currentVideo.id);
      if (latest != null && mounted) {
        setState(() => _currentVideo = latest);
      }
    } catch (_) {}
  }

  void _onVideoProgress(YoutubeVideoState state) {
    if (!mounted || _subtitlesList.isEmpty) return;

    final currentSeconds = state.position.inMilliseconds / 1000.0;
    final active = _subtitlesList
        .where((s) => currentSeconds >= s.start && currentSeconds <= s.end)
        .toList();

    final changed =
        active.length != _activeSubtitles.length ||
        active.asMap().entries.any(
          (e) =>
              _activeSubtitles[e.key].start != e.value.start ||
              _activeSubtitles[e.key].content != e.value.content,
        );

    if (changed) setState(() => _activeSubtitles = active);
  }

  void _seekTo(double startSeconds) {
    if (!_isPlayerInitialized) return;
    _youtubeController.seekTo(seconds: startSeconds, allowSeekAhead: true);
    _youtubeController.playVideo();
  }

  String _formatDuration(double seconds) {
    final d = Duration(milliseconds: (seconds * 1000).toInt());
    String pad(int n) => n.toString().padLeft(2, '0');
    return "${pad(d.inMinutes.remainder(60))}:${pad(d.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    _videoStateSubscription?.cancel();
    unawaited(_youtubeController.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Subtitle Review',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminEditVideoScreen(video: _currentVideo),
                  ),
                );
                if (result == true) {
                  await _refreshVideoData();
                } else if (result is VideoLesson) {
                  setState(() => _currentVideo = result);
                }
              },
              icon: const Icon(Icons.edit_document, size: 16),
              label: const Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubtitleDialog,
        backgroundColor: _primaryColor,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text(
          'Add Subtitle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: const Color(0xFF3E2723),
              child: _isPlayerInitialized
                  ? ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 0.94,
                        child: YoutubePlayer(controller: _youtubeController),
                      ),
                    )
                  : const Center(child: LoadingWidget()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SubtitleItem>>(
              stream: _videoRepository.watchSubtitles(_currentVideo.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _subtitlesList.isEmpty) {
                  return const Center(child: LoadingWidget());
                }

                if (snapshot.hasData) _subtitlesList = snapshot.data!;

                if (_subtitlesList.isEmpty) {
                  return const Center(
                    child: Text('No subtitles available for this video.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: _subtitlesList.length,
                  itemBuilder: (context, index) {
                    final item = _subtitlesList[index];
                    final isCurrent = _activeSubtitles.any(
                      (a) =>
                          a.start == item.start &&
                          a.end == item.end &&
                          a.content == item.content,
                    );

                    return Card(
                      color: isCurrent ? const Color(0xFFFFF8E1) : Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isCurrent
                              ? const Color(0xFFFFB74D)
                              : Colors.grey[200]!,
                          width: isCurrent ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => _seekTo(item.start),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${_formatDuration(item.start)} - ${_formatDuration(item.end)}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                        title: Text(
                          item.content,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.vi,
                            style: TextStyle(
                              color: Colors.blueGrey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.edit_note_rounded,
                            color: _primaryColor,
                          ),
                          onPressed: () => _showEditSubtitleDialog(item),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSubtitleDialog() {
    final contentCtrl = TextEditingController();
    final viCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: _primaryColor, size: 26),
            SizedBox(width: 8),
            Text(
              'Add Subtitle',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _labelColor,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogTextField(
                        controller: startCtrl,
                        label: 'Start (sec)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDialogTextField(
                        controller: endCtrl,
                        label: 'End (sec)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: contentCtrl,
                  label: 'English subtitle',
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: viCtrl,
                  label: 'Vietnamese translation',
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final start = double.tryParse(startCtrl.text.trim());
              final end = double.tryParse(endCtrl.text.trim());

              if (start == null ||
                  end == null ||
                  contentCtrl.text.trim().isEmpty) {
                _showSnack(
                  context,
                  'Please fill in all fields with valid values.',
                  Colors.orange,
                );
                return;
              }
              if (start >= end) {
                _showSnack(
                  context,
                  'Start time must be less than end time.',
                  Colors.orange,
                );
                return;
              }

              try {
                await _videoRepository.addSubtitle(
                  videoId: _currentVideo.id,
                  start: start,
                  end: end,
                  content: contentCtrl.text.trim(),
                  vi: viCtrl.text.trim(),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                _showSnack(
                  context,
                  'Subtitle added successfully!',
                  Colors.green,
                );
              } catch (e) {
                if (!context.mounted) return;
                _showSnack(context, 'Error: $e', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Add',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSubtitleDialog(SubtitleItem item) {
    final contentCtrl = TextEditingController(text: item.content);
    final viCtrl = TextEditingController(text: item.vi);
    final startCtrl = TextEditingController(text: item.start.toString());
    final endCtrl = TextEditingController(text: item.end.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: _primaryColor, size: 26),
            SizedBox(width: 8),
            Text(
              'Edit Subtitle',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _labelColor,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogTextField(
                        controller: startCtrl,
                        label: 'Start (sec)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDialogTextField(
                        controller: endCtrl,
                        label: 'End (sec)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: contentCtrl,
                  label: 'English subtitle',
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: viCtrl,
                  label: 'Vietnamese translation',
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 8),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 26,
            ),
            tooltip: 'Delete subtitle',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Subtitle?'),
                  content: const Text(
                    'This subtitle line will be permanently deleted.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await _videoRepository.deleteSubtitle(
                    videoId: _currentVideo.id,
                    start: item.start,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _showSnack(context, 'Subtitle deleted.', Colors.redAccent);
                } catch (e) {
                  if (!context.mounted) return;
                  _showSnack(context, 'Error: $e', Colors.red);
                }
              }
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final start = double.tryParse(startCtrl.text.trim());
                  final end = double.tryParse(endCtrl.text.trim());

                  if (start == null || end == null) {
                    _showSnack(
                      context,
                      'Time values must be valid numbers (e.g. 14.5)',
                      Colors.orange,
                    );
                    return;
                  }
                  if (start >= end) {
                    _showSnack(
                      context,
                      'Start time must be less than end time.',
                      Colors.orange,
                    );
                    return;
                  }

                  try {
                    await _videoRepository.updateSubtitleFull(
                      videoId: _currentVideo.id,
                      oldStart: item.start,
                      newStart: start,
                      newEnd: end,
                      newContent: contentCtrl.text.trim(),
                      newVi: viCtrl.text.trim(),
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _showSnack(
                      context,
                      'Subtitle updated successfully!',
                      Colors.green,
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    _showSnack(context, 'Error: $e', Colors.red);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 3,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        color: _textColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _primaryColor.withValues(alpha: 0.7),
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: _primaryColor,
          fontWeight: FontWeight.bold,
        ),
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.all(14),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
