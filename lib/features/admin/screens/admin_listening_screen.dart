import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/audio_lesson.dart';
import '../../../data/mock/mock_audio.dart';

class AdminListeningScreen extends StatefulWidget {
  const AdminListeningScreen({super.key});

  @override
  State<AdminListeningScreen> createState() => _AdminListeningScreenState();
}

class _AdminListeningScreenState extends State<AdminListeningScreen> {
  List<AudioLesson> _lessons = [];
  bool _isLoading = true;

  final List<Color> _cardColors = [
    const Color(0xFF7C4DFF),  // Tím - Daily Conversations
    const Color(0xFF448AFF),  // Xanh dương - Business Meeting
    const Color(0xFF69F0AE),  // Xanh lá - Travel Podcast
    const Color(0xFFFF5252),  // Đỏ - News Report
    const Color(0xFFFFAB40),  // Cam - Story Time
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _lessons = MockAudioData.getMockAudioLessons();
    setState(() => _isLoading = false);
  }

  void _addLesson() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add audio lesson feature coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 2 : 1;
    final cardWidth = (screenWidth - 72) / crossAxisCount;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Audio Lessons',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addLesson,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Lesson'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.start,
              children: _lessons.asMap().entries.map((entry) {
                final index = entry.key;
                final lesson = entry.value;
                final cardColor = _cardColors[index % _cardColors.length];
                return SizedBox(
                  width: cardWidth,
                  child: _buildAudioCard(lesson, cardColor),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioCard(AudioLesson lesson, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cardColor, cardColor.withValues(alpha: 0.7)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(lesson.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lesson.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.duration,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lesson.subtitle,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (lesson.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(fontSize: 9, color: Colors.white),
                        ),
                      ),
                    if (lesson.isPopular) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.trending_up, size: 14, color: cardColor),
                      const SizedBox(width: 4),
                      Text(
                        'Popular',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          color: cardColor,
                        ),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
    );
  }
}