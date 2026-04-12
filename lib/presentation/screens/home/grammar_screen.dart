import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  final List<GrammarTopic> _topics = [
    GrammarTopic(
      id: 1,
      title: 'Present Simple Tense',
      description: 'Learn how to use present simple for daily routines and facts.',
      level: 'Beginner',
      progress: 0.65,
      lessonCount: 12,
      icon: Icons.schedule,
    ),
    GrammarTopic(
      id: 2,
      title: 'Past Simple Tense',
      description: 'Master past actions and completed events.',
      level: 'Beginner',
      progress: 0.30,
      lessonCount: 10,
      icon: Icons.history,
    ),
    GrammarTopic(
      id: 3,
      title: 'Future Simple Tense',
      description: 'Express future plans, predictions, and promises.',
      level: 'Intermediate',
      progress: 0.0,
      lessonCount: 8,
      icon: Icons.timeline,
    ),
    GrammarTopic(
      id: 4,
      title: 'Present Continuous',
      description: 'Actions happening now or around now.',
      level: 'Beginner',
      progress: 0.80,
      lessonCount: 9,
      icon: Icons.play_circle,
    ),
    GrammarTopic(
      id: 5,
      title: 'Prepositions of Place',
      description: 'Master in, on, at, under, and more.',
      level: 'Beginner',
      progress: 0.45,
      lessonCount: 15,
      icon: Icons.place,
    ),
    GrammarTopic(
      id: 6,
      title: 'Modal Verbs',
      description: 'Learn can, could, may, might, must, should.',
      level: 'Intermediate',
      progress: 0.15,
      lessonCount: 14,
      icon: Icons.rule,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E3),
      appBar: _buildAppBar(colorScheme),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                return _buildGrammarCard(_topics[index], colorScheme);
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
        'Grammar',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF3A2D00),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF775600)),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDBC13), Color(0xFF775600)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grammar Mastery',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete 6 topics to reach level 10',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: 0.38,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrammarCard(GrammarTopic topic, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  topic.icon,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3A2D00),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        color: const Color(0xFF6B5A23),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLevelColor(topic.level).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  topic.level,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _getLevelColor(topic.level),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Icon(Icons.menu_book, size: 14, color: const Color(0xFF6B5A23)),
                  const SizedBox(width: 4),
                  Text(
                    '${topic.lessonCount} lessons',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 11,
                      color: const Color(0xFF6B5A23),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (topic.progress > 0)
                Text(
                  '${(topic.progress * 100).toInt()}%',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
            ],
          ),
          if (topic.progress > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: topic.progress,
                backgroundColor: const Color(0xFFF0D273),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 4,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: topic.progress > 0
                    ? const Color(0xFFFDBC13)
                    : colorScheme.primary,
                foregroundColor: topic.progress > 0
                    ? const Color(0xFF543C00)
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                topic.progress > 0 ? 'Continue Learning' : 'Start Learning',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return const Color(0xFF775600);
    }
  }
}

class GrammarTopic {
  final int id;
  final String title;
  final String description;
  final String level;
  final double progress;
  final int lessonCount;
  final IconData icon;

  GrammarTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.progress,
    required this.lessonCount,
    required this.icon,
  });
}