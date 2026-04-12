import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  final List<AudioLesson> _lessons = [
    AudioLesson(
      id: 1,
      title: 'Daily Conversations',
      subtitle: 'Beginner Level • 5 min',
      duration: '5:23',
      isNew: true,
      isPopular: true,
      icon: Icons.headphones,
    ),
    AudioLesson(
      id: 2,
      title: 'Business Meeting',
      subtitle: 'Intermediate Level • 8 min',
      duration: '8:45',
      isNew: false,
      isPopular: true,
      icon: Icons.business_center,
    ),
    AudioLesson(
      id: 3,
      title: 'Travel Podcast',
      subtitle: 'Beginner Level • 6 min',
      duration: '6:12',
      isNew: true,
      isPopular: false,
      icon: Icons.flight,
    ),
    AudioLesson(
      id: 4,
      title: 'News Report',
      subtitle: 'Advanced Level • 10 min',
      duration: '10:30',
      isNew: false,
      isPopular: false,
      icon: Icons.newspaper,
    ),
    AudioLesson(
      id: 5,
      title: 'Story Time',
      subtitle: 'Intermediate Level • 7 min',
      duration: '7:15',
      isNew: false,
      isPopular: true,
      icon: Icons.auto_stories,
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
          _buildSearchBar(),
          _buildCategories(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _lessons.length,
              itemBuilder: (context, index) {
                return _buildAudioCard(_lessons[index], colorScheme);
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
        'Listening',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF3A2D00),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.playlist_play, color: Color(0xFF775600)),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search lessons...',
            hintStyle: GoogleFonts.beVietnamPro(
              color: const Color(0xFF6B5A23).withValues(alpha: 0.5),
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF775600)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['All', 'Podcasts', 'Conversations', 'News', 'Stories'];
    int selectedIndex = 0;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (selected) {},
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFFDBC13),
              labelStyle: GoogleFonts.beVietnamPro(
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF543C00) : const Color(0xFF6B5A23),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudioCard(AudioLesson lesson, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  const Color(0xFFFDBC13),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              lesson.icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3A2D00),
                        ),
                      ),
                    ),
                    if (lesson.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'NEW',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.subtitle,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    color: const Color(0xFF6B5A23),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: const Color(0xFF6B5A23)),
                    const SizedBox(width: 4),
                    Text(
                      lesson.duration,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        color: const Color(0xFF6B5A23),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (lesson.isPopular)
                      Row(
                        children: [
                          Icon(Icons.trending_up, size: 14, color: colorScheme.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            'Popular',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 11,
                              color: colorScheme.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle, size: 40),
            color: colorScheme.primary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class AudioLesson {
  final int id;
  final String title;
  final String subtitle;
  final String duration;
  final bool isNew;
  final bool isPopular;
  final IconData icon;

  AudioLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.isNew,
    required this.isPopular,
    required this.icon,
  });
}