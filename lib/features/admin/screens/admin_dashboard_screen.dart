import 'package:amingo/features/auth/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/user_provider.dart';
import '../widgets/admin_side_menu.dart';
import '../widgets/admin_stat_card.dart';
import 'admin_grammar_screen.dart';
import 'admin_listening_screen.dart';
import 'admin_news_screen.dart';
import 'admin_video_screen.dart';
import 'admin_vocabulary_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const _DashboardContent(),
    const AdminVocabularyScreen(),
    const AdminGrammarScreen(),
    const AdminListeningScreen(),
    const AdminVideoScreen(),
    const AdminNewsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Vocabulary Management',
    'Grammar Management',
    'Listening Management',
    'Video Management',
    'News Management',
  ];

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).clearUser();
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Admin Logout Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
          ),
        ],
      ),
      drawer: AdminSideMenu(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),
      body: _screens[_selectedIndex],
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  late Future<_DashboardMetrics> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = _loadMetrics();
  }

  Future<_DashboardMetrics> _loadMetrics() async {
    final firestore = FirebaseFirestore.instance;

    Future<int> countCollection(String path) async {
      final snapshot = await firestore.collection(path).get();
      return snapshot.size;
    }

    Future<int> countCollectionGroup(String collectionId) async {
      final snapshot = await firestore.collectionGroup(collectionId).get();
      return snapshot.size;
    }

    final results = await Future.wait<int>([
      countCollection('users'),
      countCollection('vocabulary_sets'),
      countCollection('vocabulary_words'),
      countCollection('grammar_topics'),
      countCollection('grammar_questions'),
      countCollection('listening_topics'),
      countCollectionGroup('sections'),
      countCollectionGroup('lessons'),
      countCollection('video_lessons'),
      countCollection('articles'),
      countCollection('saved_articles'),
      countCollection('saved_videos'),
      countCollection('saved_vocabulary'),
      countCollection('already_read'),
      countCollection('already_watched_videos'),
      countCollectionGroup('listening'),
    ]);

    final videoSnapshot = await firestore.collection('video_lessons').get();
    int publishedVideos = 0;
    int videosWithSubtitles = 0;
    final Map<String, int> videoLevels = {};

    for (final doc in videoSnapshot.docs) {
      final data = doc.data();
      if (data['isPublished'] == true) publishedVideos++;
      if (data['hasSubtitles'] == true) videosWithSubtitles++;

      final level = data['level']?.toString().trim();
      if (level != null && level.isNotEmpty) {
        videoLevels[level] = (videoLevels[level] ?? 0) + 1;
      }
    }

    final vocabularySnapshot = await firestore.collection('vocabulary_sets').get();
    final Map<String, int> vocabularyLevels = {};

    for (final doc in vocabularySnapshot.docs) {
      final data = doc.data();
      final level = data['level']?.toString().trim();
      if (level != null && level.isNotEmpty) {
        vocabularyLevels[level] = (vocabularyLevels[level] ?? 0) + 1;
      }
    }

    final totalContent =
        results[1] + results[3] + results[7] + results[8] + results[9];
    final totalSaves = results[10] + results[11] + results[12];
    final totalCompletions = results[13] + results[14] + results[15];
    final completionRate = totalContent == 0 || results[0] == 0
        ? 0
        : ((totalCompletions / (totalContent * results[0])) * 100)
              .round()
              .clamp(0, 100);

    return _DashboardMetrics(
      users: results[0],
      vocabularySets: results[1],
      vocabularyWords: results[2],
      grammarTopics: results[3],
      grammarQuestions: results[4],
      listeningTopics: results[5],
      listeningSections: results[6],
      listeningLessons: results[7],
      videoLessons: results[8],
      articles: results[9],
      savedArticles: results[10],
      savedVideos: results[11],
      savedVocabulary: results[12],
      readArticles: results[13],
      watchedVideos: results[14],
      completedListeningLessons: results[15],
      publishedVideos: publishedVideos,
      videosWithSubtitles: videosWithSubtitles,
      totalContent: totalContent,
      totalSaves: totalSaves,
      totalCompletions: totalCompletions,
      completionRate: completionRate,
      videoLevels: videoLevels,
      vocabularyLevels: vocabularyLevels,
    );
  }

  void _refresh() {
    setState(() {
      _metricsFuture = _loadMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 700;
    final cardWidth = (screenWidth - 72) / (isSmallScreen ? 1 : 2);

    return FutureBuilder<_DashboardMetrics>(
      future: _metricsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _DashboardError(
            error: snapshot.error.toString(),
            onRetry: _refresh,
          );
        }

        final metrics = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(metrics),
                const SizedBox(height: 24),
                _buildSectionTitle('Statistics'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: AdminStatCard(
                        title: 'Total Users',
                        value: _formatNumber(metrics.users),
                        icon: Icons.people,
                        color: const Color(0xFF3F51B5),
                        change: 'Firestore',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminStatCard(
                        title: 'Learning Content',
                        value: _formatNumber(metrics.totalContent),
                        icon: Icons.school,
                        color: const Color(0xFF4CAF50),
                        change: 'All modules',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminStatCard(
                        title: 'Saved Items',
                        value: _formatNumber(metrics.totalSaves),
                        icon: Icons.bookmark,
                        color: const Color(0xFFFF9800),
                        change: 'User library',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminStatCard(
                        title: 'Completion Rate',
                        value: '${metrics.completionRate}%',
                        icon: Icons.trending_up,
                        color: const Color(0xFF9C27B0),
                        change: '${_formatNumber(metrics.totalCompletions)} actions',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('Reports'),
                const SizedBox(height: 16),
                _buildReportGrid(
                  isSmallScreen: isSmallScreen,
                  children: [
                    _ReportCard(
                      title: 'Content Distribution',
                      child: _HorizontalBarChart(
                        items: [
                          _ChartItem(
                            'Vocabulary sets',
                            metrics.vocabularySets,
                            const Color(0xFF4CAF50),
                          ),
                          _ChartItem(
                            'Grammar topics',
                            metrics.grammarTopics,
                            const Color(0xFF2196F3),
                          ),
                          _ChartItem(
                            'Listening lessons',
                            metrics.listeningLessons,
                            const Color(0xFFFFB300),
                          ),
                          _ChartItem(
                            'Video lessons',
                            metrics.videoLessons,
                            const Color(0xFFE91E63),
                          ),
                          _ChartItem(
                            'News articles',
                            metrics.articles,
                            const Color(0xFF795548),
                          ),
                        ],
                      ),
                    ),
                    _ReportCard(
                      title: 'Engagement Activity',
                      child: _HorizontalBarChart(
                        items: [
                          _ChartItem(
                            'Read articles',
                            metrics.readArticles,
                            const Color(0xFF3F51B5),
                          ),
                          _ChartItem(
                            'Watched videos',
                            metrics.watchedVideos,
                            const Color(0xFFFF9800),
                          ),
                          _ChartItem(
                            'Listening completed',
                            metrics.completedListeningLessons,
                            const Color(0xFF2E7D32),
                          ),
                          _ChartItem(
                            'Saved articles',
                            metrics.savedArticles,
                            const Color(0xFF9C27B0),
                          ),
                          _ChartItem(
                            'Saved videos',
                            metrics.savedVideos,
                            const Color(0xFFE91E63),
                          ),
                          _ChartItem(
                            'Saved vocabulary',
                            metrics.savedVocabulary,
                            const Color(0xFF009688),
                          ),
                        ],
                      ),
                    ),
                    _ReportCard(
                      title: 'Video Status',
                      child: _StatusBars(
                        total: metrics.videoLessons,
                        items: [
                          _ChartItem(
                            'Published',
                            metrics.publishedVideos,
                            const Color(0xFF2E7D32),
                          ),
                          _ChartItem(
                            'Has subtitles',
                            metrics.videosWithSubtitles,
                            const Color(0xFF3F51B5),
                          ),
                        ],
                      ),
                    ),
                    _ReportCard(
                      title: 'Level Breakdown',
                      child: _LevelBreakdown(
                        videoLevels: metrics.videoLevels,
                        vocabularyLevels: metrics.vocabularyLevels,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('Collection Counts'),
                const SizedBox(height: 16),
                _ReportCard(
                  title: 'Data Inventory',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MetricChip('Vocabulary words', metrics.vocabularyWords),
                      _MetricChip('Grammar questions', metrics.grammarQuestions),
                      _MetricChip('Listening topics', metrics.listeningTopics),
                      _MetricChip('Listening sections', metrics.listeningSections),
                      _MetricChip('Listening lessons', metrics.listeningLessons),
                      _MetricChip('Video lessons', metrics.videoLessons),
                      _MetricChip('Articles', metrics.articles),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(_DashboardMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.adminGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Live Firestore report: ${_formatNumber(metrics.totalContent)} content items and ${_formatNumber(metrics.users)} users.',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.analytics, size: 32, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildReportGrid({
    required bool isSmallScreen,
    required List<Widget> children,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            isSmallScreen ? constraints.maxWidth : (constraints.maxWidth - 16) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }

  String _formatNumber(int value) {
    final chars = value.toString().split('').reversed.toList();
    final buffer = StringBuffer();

    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(',');
      buffer.write(chars[i]);
    }

    return buffer.toString().split('').reversed.join();
  }
}

class _DashboardMetrics {
  final int users;
  final int vocabularySets;
  final int vocabularyWords;
  final int grammarTopics;
  final int grammarQuestions;
  final int listeningTopics;
  final int listeningSections;
  final int listeningLessons;
  final int videoLessons;
  final int articles;
  final int savedArticles;
  final int savedVideos;
  final int savedVocabulary;
  final int readArticles;
  final int watchedVideos;
  final int completedListeningLessons;
  final int publishedVideos;
  final int videosWithSubtitles;
  final int totalContent;
  final int totalSaves;
  final int totalCompletions;
  final int completionRate;
  final Map<String, int> videoLevels;
  final Map<String, int> vocabularyLevels;

  const _DashboardMetrics({
    required this.users,
    required this.vocabularySets,
    required this.vocabularyWords,
    required this.grammarTopics,
    required this.grammarQuestions,
    required this.listeningTopics,
    required this.listeningSections,
    required this.listeningLessons,
    required this.videoLessons,
    required this.articles,
    required this.savedArticles,
    required this.savedVideos,
    required this.savedVocabulary,
    required this.readArticles,
    required this.watchedVideos,
    required this.completedListeningLessons,
    required this.publishedVideos,
    required this.videosWithSubtitles,
    required this.totalContent,
    required this.totalSaves,
    required this.totalCompletions,
    required this.completionRate,
    required this.videoLevels,
    required this.vocabularyLevels,
  });
}

class _ChartItem {
  final String label;
  final int value;
  final Color color;

  const _ChartItem(this.label, this.value, this.color);
}

class _DashboardError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _DashboardError({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Failed to load dashboard data',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ReportCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _HorizontalBarChart extends StatelessWidget {
  final List<_ChartItem> items;

  const _HorizontalBarChart({required this.items});

  @override
  Widget build(BuildContext context) {
    final maxValue = items.fold<int>(
      0,
      (max, item) => item.value > max ? item.value : max,
    );

    if (maxValue == 0) {
      return const _EmptyReportMessage(message: 'No data available yet.');
    }

    return Column(
      children: items.map((item) {
        final factor = item.value / maxValue;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    item.value.toString(),
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: factor.clamp(0.0, 1.0),
                  minHeight: 9,
                  backgroundColor: item.color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(item.color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatusBars extends StatelessWidget {
  final int total;
  final List<_ChartItem> items;

  const _StatusBars({
    required this.total,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return const _EmptyReportMessage(message: 'No videos available yet.');
    }

    return Column(
      children: items.map((item) {
        final percent = (item.value / total * 100).round();
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${item.value}/$total ($percent%)',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (item.value / total).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: item.color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(item.color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LevelBreakdown extends StatelessWidget {
  final Map<String, int> videoLevels;
  final Map<String, int> vocabularyLevels;

  const _LevelBreakdown({
    required this.videoLevels,
    required this.vocabularyLevels,
  });

  @override
  Widget build(BuildContext context) {
    final combined = <String, int>{};

    for (final entry in videoLevels.entries) {
      combined[entry.key] = (combined[entry.key] ?? 0) + entry.value;
    }
    for (final entry in vocabularyLevels.entries) {
      combined[entry.key] = (combined[entry.key] ?? 0) + entry.value;
    }

    final orderedEntries = combined.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (orderedEntries.isEmpty) {
      return const _EmptyReportMessage(message: 'No level data available yet.');
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: orderedEntries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.value.toString(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final int value;

  const _MetricChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toString(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReportMessage extends StatelessWidget {
  final String message;

  const _EmptyReportMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Text(
        message,
        style: GoogleFonts.beVietnamPro(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }
}
