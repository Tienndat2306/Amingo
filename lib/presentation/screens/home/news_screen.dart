import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final List<NewsArticle> _articles = [
    NewsArticle(
      id: 1,
      title: 'Global Climate Summit Reaches Historic Agreement',
      description: 'World leaders commit to reducing carbon emissions by 50% before 2030 in landmark deal.',
      category: 'World News',
      readTime: '5 min read',
      date: '2 hours ago',
      imageUrl: 'https://picsum.photos/400/250?random=1',
      isBreaking: true,
      views: '15.2K',
    ),
    NewsArticle(
      id: 2,
      title: 'Tech Giants Announce AI Collaboration',
      description: 'Major technology companies join forces to develop ethical AI guidelines.',
      category: 'Technology',
      readTime: '4 min read',
      date: '5 hours ago',
      imageUrl: 'https://picsum.photos/400/250?random=2',
      isBreaking: false,
      views: '8.7K',
    ),
    NewsArticle(
      id: 3,
      title: 'New Language Learning Method Shows Promise',
      description: 'Revolutionary approach to language acquisition yields impressive results in recent study.',
      category: 'Education',
      readTime: '6 min read',
      date: 'Yesterday',
      imageUrl: 'https://picsum.photos/400/250?random=3',
      isBreaking: true,
      views: '12.3K',
    ),
    NewsArticle(
      id: 4,
      title: 'Cultural Exchange Program Expands Globally',
      description: 'International student exchange initiatives reach record participation numbers.',
      category: 'Culture',
      readTime: '3 min read',
      date: 'Yesterday',
      imageUrl: 'https://picsum.photos/400/250?random=4',
      isBreaking: false,
      views: '5.1K',
    ),
    NewsArticle(
      id: 5,
      title: 'Economic Outlook for 2024 Shows Positive Trends',
      description: 'Global economy shows signs of recovery with emerging markets leading growth.',
      category: 'Business',
      readTime: '7 min read',
      date: '2 days ago',
      imageUrl: 'https://picsum.photos/400/250?random=5',
      isBreaking: false,
      views: '9.8K',
    ),
    NewsArticle(
      id: 6,
      title: 'Breakthrough in Renewable Energy Storage',
      description: 'Scientists develop new battery technology that could revolutionize green energy.',
      category: 'Science',
      readTime: '5 min read',
      date: '2 days ago',
      imageUrl: 'https://picsum.photos/400/250?random=6',
      isBreaking: false,
      views: '6.4K',
    ),
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'World News', 'Technology', 'Education', 'Culture', 'Business', 'Science'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final filteredArticles = _selectedCategory == 'All'
        ? _articles
        : _articles.where((article) => article.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E3),
      appBar: _buildAppBar(colorScheme),
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryTabs(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                return _buildNewsCard(filteredArticles[index], colorScheme);
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
        'News',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF3A2D00),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_outline, color: Color(0xFF775600)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Color(0xFF775600)),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Informed',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Read news in English and improve your language skills',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha:0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.newspaper,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFDBC13) : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFC1AC6C).withValues(alpha:0.3),
                  ),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF543C00)
                        : const Color(0xFF6B5A23),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  article.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: colorScheme.primary.withValues(alpha:0.1),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Color(0xFF775600),
                      ),
                    );
                  },
                ),
              ),
              if (article.isBreaking)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'BREAKING',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
                    color: Colors.black.withValues(alpha:0.6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        article.views,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and Date
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        article.category,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 12, color: const Color(0xFF6B5A23)),
                    const SizedBox(width: 4),
                    Text(
                      article.readTime,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        color: const Color(0xFF6B5A23),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      article.date,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        color: const Color(0xFF6B5A23),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  article.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3A2D00),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  article.description,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    color: const Color(0xFF6B5A23),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_lesson, size: 18),
                        label: Text(
                          'Read Article',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary.withValues(alpha:0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.bookmark_border, size: 20),
                        color: colorScheme.primary,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.share, size: 20),
                        color: colorScheme.primary,
                        onPressed: () {},
                      ),
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

class NewsArticle {
  final int id;
  final String title;
  final String description;
  final String category;
  final String readTime;
  final String date;
  final String imageUrl;
  final bool isBreaking;
  final String views;

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.readTime,
    required this.date,
    required this.imageUrl,
    required this.isBreaking,
    required this.views,
  });
}