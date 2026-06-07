import 'package:flutter/material.dart';
import '../../../core/utils/youtube_thumbnail.dart';
import '../../../data/repositories/video_repository.dart';

class AdminAddVideoScreen extends StatefulWidget {
  const AdminAddVideoScreen({super.key});

  @override
  State<AdminAddVideoScreen> createState() => _AdminAddVideoScreenState();
}

class _AdminAddVideoScreenState extends State<AdminAddVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final VideoRepository _videoRepository = VideoRepository();
  bool _isLoading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(
    text: '00:00',
  );
  final TextEditingController _thumbnailController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();

  String _selectedLevel = 'Beginner';
  bool _isFeatured = false;
  bool _isPublished = false;

  static const List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  static const Color _primaryColor = Color(0xFF795548);

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _thumbnailController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final videoUrl = _videoUrlController.text.trim();
      final thumbnail = resolveVideoThumbnail(
        videoUrl: videoUrl,
        thumbnailUrl: _thumbnailController.text,
      );

      final success = await _videoRepository.createVideoLesson({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'duration': _durationController.text.trim(),
        'thumbnail': thumbnail,
        'videoUrl': videoUrl,
        'level': _selectedLevel,
        'isFeatured': _isFeatured,
        'isPublished': _isPublished,
        'hasSubtitles': false,
      });

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add video. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add New Video',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0.5,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _primaryColor,
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.cloud_upload_rounded, size: 20),
              label: const Text(
                'Create',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(foregroundColor: _primaryColor),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Video Title *'),
              _buildTextField(_titleController, 'Enter lesson title...'),
              const SizedBox(height: 16),

              _buildLabel('Video URL *'),
              _buildTextField(
                _videoUrlController,
                'YouTube or direct video link...',
              ),
              const SizedBox(height: 16),

              _buildLabel('Description *'),
              _buildTextField(
                _descController,
                'Enter lesson description...',
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Duration *'),
                        _buildTextField(_durationController, 'e.g. 03:00'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_buildLabel('Level'), _buildLevelDropdown()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Thumbnail URL'),
              _buildTextField(
                _thumbnailController,
                'Leave blank to use the YouTube thumbnail...',
                maxLines: 2,
                isRequired: false,
              ),
              const SizedBox(height: 24),

              const Divider(),
              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Publish Video',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _isPublished ? 'Visible to students' : 'Hidden (Draft)',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isPublished ? Colors.green[700] : Colors.red[400],
                  ),
                ),
                value: _isPublished,
                activeThumbColor: Colors.green,
                inactiveThumbColor: Colors.red[400],
                inactiveTrackColor: Colors.red[100],
                onChanged: (val) => setState(() => _isPublished = val),
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Mark as Featured',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Shown prominently on the home screen',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isFeatured ? Colors.green[700] : Colors.grey[500],
                  ),
                ),
                value: _isFeatured,
                activeThumbColor: Colors.green,
                inactiveThumbColor: Colors.red[400],
                inactiveTrackColor: Colors.red[100],
                onChanged: (val) => setState(() => _isFeatured = val),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedLevel,
          items: _levels
              .map(
                (level) => DropdownMenuItem(value: level, child: Text(level)),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedLevel = val);
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFF5D4037),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
      validator: isRequired
          ? (value) => (value == null || value.trim().isEmpty)
              ? 'This field is required'
              : null
          : null,
    );
  }
}
