import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/grammar_screen.dart';
import '../home/listening_screen.dart';
import '../home/news_screen.dart';
import '../home/vocabulary_screen.dart';
import '../home/video_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

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
      body: Column(
        children: [
          _buildTopAppBar(colorScheme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDailyProgressSection(colorScheme),
                  const SizedBox(height: 40),
                  _buildLearningModules(colorScheme),
                ],
              ),
            ),
          ),
          _buildBottomNavigationBar(colorScheme),
        ],
      ),
    );
  }

  // ─── Top App Bar ───────────────────────────────────────────────────────────

  Widget _buildTopAppBar(ColorScheme colorScheme) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: const Color(0xFFFFF6E3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE18B),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3A2D00).withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/logo/amingo_logo_5-removebg-preview.png',
                  height: 32,
                  width: 32,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Welcome',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3A2D00),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.settings,
                  color: Color(0xFF775600),
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Daily Progress ────────────────────────────────────────────────────────

  Widget _buildDailyProgressSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0C9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A2D00).withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Goal",
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3A2D00),
                ),
              ),
              Text(
                '80%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: 0.8,
              backgroundColor: const Color(0xFFF8DB80),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Learning Modules ──────────────────────────────────────────────────────

  Widget _buildLearningModules(ColorScheme colorScheme) {
    return Column(
      children: [
        // Row 1: Vocabulary — full width
        _buildVocabularyCard(colorScheme),
        const SizedBox(height: 16),
        // Row 2: News + Listening — equal width
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildNewsCard(colorScheme)),
              const SizedBox(width: 16),
              Expanded(child: _buildListeningCard(colorScheme)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Row 3: Video + Grammar — equal width
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildVideoCard(colorScheme)),
              const SizedBox(width: 16),
              Expanded(child: _buildGrammarCard(colorScheme)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Card: Vocabulary ──────────────────────────────────────────────────────

  Widget _buildVocabularyCard(ColorScheme colorScheme) {
    return GestureDetector(onTap: () => _navigateTo(const VocabularyScreen()),
      child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8DB80),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school, color: Color(0xFF775600)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Vocabulary',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3A2D00),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enhance your vocabulary with over 50 new words about technology and daily life.',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    color: const Color(0xFF6B5A23),
                  ),
                ),
                const SizedBox(height: 24),

              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right: stats column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatBadge('1000+', 'new words', colorScheme),
              const SizedBox(height: 12),
              _buildStatBadge('12', 'learners', colorScheme),
              const SizedBox(height: 12),
              _buildStatBadge('8 min', 'avg. lesson', colorScheme),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStatBadge(String value, String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2D00),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 10,
              color: const Color(0xFF6B5A23),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({
    required double left,
    required String url,
    required Color fallbackColor,
  }) {
    return Positioned(
      left: left,
      child: ClipOval(
        child: Image.network(
          url,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 32,
            height: 32,
            color: fallbackColor,
          ),
        ),
      ),
    );
  }

  // ─── Card: News ────────────────────────────────────────────────────────────

  Widget _buildNewsCard(ColorScheme colorScheme) {
    return
      GestureDetector(
          onTap: () => _navigateTo(const NewsScreen()),
          child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFC1AC6C).withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.newspaper, color: colorScheme.tertiary),
              ),
              const SizedBox(height: 16),
              Text(
                'News',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3A2D00),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Read international news in the language you are learning.',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  color: const Color(0xFF6B5A23),
                ),
              ),
              const Spacer(),
              Divider(color: const Color(0xFFC1AC6C).withValues(alpha: 0.15)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '3 new articles',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: const Color(0xFF6B5A23), size: 20),
                ],
              ),
            ],
          ),
          ),
    );
  }

  // ─── Card: Listening ───────────────────────────────────────────────────────

  Widget _buildListeningCard(ColorScheme colorScheme) {
    return GestureDetector(
        onTap: () => _navigateTo(const ListeningScreen()),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E2E1).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF525151).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headphones, color: Color(0xFF525151), size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                'Listening',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3A2D00),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Short podcasts and real conversations.',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  color: const Color(0xFF6B5A23),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '45% complete',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5C5B5B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: 0.45,
                  backgroundColor: Colors.white.withValues(alpha: 0.6),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5C5B5B)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
    );
  }

  // ─── Card: Video ───────────────────────────────────────────────────────────

  Widget _buildVideoCard(ColorScheme colorScheme) {
    return GestureDetector(
        onTap: () => _navigateTo(const VideoScreen()),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, const Color(0xFF684B00)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.play_circle, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                'Video',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Learn through movies and trailers.',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'View Library',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  // ─── Card: Grammar ─────────────────────────────────────────────────────────

  Widget _buildGrammarCard(ColorScheme colorScheme) {
    return GestureDetector(
        onTap: () => _navigateTo(const GrammarScreen()),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0C9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.article, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                'Grammar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3A2D00),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sentence structures and advanced grammar rules.',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  color: const Color(0xFF6B5A23),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildChip('Present', colorScheme),
                  _buildChip('Prepositions', colorScheme),
                ],
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildChip(String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.beVietnamPro(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF6B5A23),
        ),
      ),
    );
  }

  // ─── Bottom Navigation Bar ─────────────────────────────────────────────────

  Widget _buildBottomNavigationBar(ColorScheme colorScheme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6E3).withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.school,
                  label: 'Learn',
                  index: 0,
                  colorScheme: colorScheme,
                ),
                _buildNavItem(
                  icon: Icons.history_edu,
                  label: 'Review',
                  index: 1,
                  colorScheme: colorScheme,
                ),
                _buildNavItem(
                  icon: Icons.local_fire_department,
                  label: 'Streaks',
                  index: 2,
                  colorScheme: colorScheme,
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  index: 3,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required ColorScheme colorScheme,
  }) {
    final isActive = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 3) {
          _navigateTo(const ProfileScreen());
        } else {
          setState(() => _selectedNavIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDBC13), Color(0xFF775600)],
          )
              : null,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: const Color(0xFF775600).withValues(alpha: 0.3),
              blurRadius: 8,
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF5C5B5B),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isActive ? Colors.white : const Color(0xFF5C5B5B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}