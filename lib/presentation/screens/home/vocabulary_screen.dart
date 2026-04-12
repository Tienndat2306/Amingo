import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lesson/lesson_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final List<VocabularySet> _vocabSets = [
    VocabularySet(
      id: 1,
      title: 'Daily Routines',
      wordCount: 45,
      learnedCount: 30,
      level: 'Beginner',
      icon: Icons.wb_sunny,
      color: 0xFFFFA726,
    ),
    VocabularySet(
      id: 2,
      title: 'Business English',
      wordCount: 60,
      learnedCount: 15,
      level: 'Intermediate',
      icon: Icons.business,
      color: 0xFF42A5F5,
    ),
    VocabularySet(
      id: 3,
      title: 'Travel & Tourism',
      wordCount: 50,
      learnedCount: 50,
      level: 'Beginner',
      icon: Icons.flight_takeoff,
      color: 0xFF66BB6A,
    ),
    VocabularySet(
      id: 4,
      title: 'Technology',
      wordCount: 80,
      learnedCount: 25,
      level: 'Advanced',
      icon: Icons.computer,
      color: 0xFFAB47BC,
    ),
    VocabularySet(
      id: 5,
      title: 'Food & Cooking',
      wordCount: 55,
      learnedCount: 20,
      level: 'Beginner',
      icon: Icons.restaurant,
      color: 0xFFEF5350,
    ),
  ];

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E3),
      appBar: _buildAppBar(colorScheme),
      body: Column(
        children: [
          _buildStatsHeader(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _vocabSets.length,
              itemBuilder: (context, index) {
                return _buildVocabularyCard(_vocabSets[index], colorScheme);
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
        'Vocabulary',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF3A2D00),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.flash_on, color: Color(0xFF775600)),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('290', 'Total Words', Icons.menu_book),
          _buildStatItem('140', 'Learned', Icons.check_circle, const Color(0xFF4CAF50)),
          _buildStatItem('48%', 'Progress', Icons.trending_up, const Color(0xFFFF9800)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color ?? const Color(0xFF775600)),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3A2D00),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontSize: 11,
            color: const Color(0xFF6B5A23),
          ),
        ),
      ],
    );
  }

  Widget _buildVocabularyCard(VocabularySet vocabSet, ColorScheme colorScheme) {
    final progress = vocabSet.learnedCount / vocabSet.wordCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(vocabSet.color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              vocabSet.icon,
              color: Color(vocabSet.color),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            vocabSet.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2D00),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getLevelColor(vocabSet.level).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  vocabSet.level,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _getLevelColor(vocabSet.level),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${vocabSet.learnedCount}/${vocabSet.wordCount}',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B5A23),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF0D273),
              valueColor: AlwaysStoppedAnimation<Color>(Color(vocabSet.color)),
              minHeight: 4,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _navigateTo(
                  LessonScreen(
                    title: vocabSet.title,
                    category: vocabSet.level,
                    totalWords: vocabSet.wordCount,
                    learnedCount: vocabSet.learnedCount,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(vocabSet.color)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                progress > 0 ? 'Review' : 'Learn',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(vocabSet.color),
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

class VocabularySet {
  final int id;
  final String title;
  final int wordCount;
  final int learnedCount;
  final String level;
  final IconData icon;
  final int color;

  VocabularySet({
    required this.id,
    required this.title,
    required this.wordCount,
    required this.learnedCount,
    required this.level,
    required this.icon,
    required this.color,
  });
}