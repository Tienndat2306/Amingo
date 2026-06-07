import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/listening_lesson.dart';
import '../../../data/repositories/listening_repository.dart';
import 'listening_detail_screen.dart';
import '../widgets/audio_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar.dart';

class ListeningScreen extends StatefulWidget {
  final String topicId;
  final String sectionId;
  final String sectionTitle;

  const ListeningScreen({
    super.key,
    required this.topicId,
    required this.sectionId,
    required this.sectionTitle,
  });

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  final ListeningRepository _listeningRepository = ListeningRepository();

  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = ['All', 'A1', 'A2', 'B1', 'B2'];

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: CustomAppBar(
        title: widget.sectionTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play, color: Color(0xFF5D4037)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(onSearchChanged: _onSearchChanged),
          CategoryChipRow(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
          Expanded(
            child: StreamBuilder<List<ListeningLesson>>(
              stream: _listeningRepository.watchLessons(
                topicId: widget.topicId,
                sectionId: widget.sectionId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No lessons available in this section.',
                      style: TextStyle(color: Color(0xFF8D6E63)),
                    ),
                  );
                }

                final allLessons = snapshot.data!;

                return StreamBuilder<Set<String>>(
                  stream: _listeningRepository.watchCompletedLessonIds(
                    topicId: widget.topicId,
                    sectionId: widget.sectionId,
                  ),
                  builder: (context, progressSnapshot) {
                    final completedLessonIds = progressSnapshot.data ?? {};
                    final completedCount = allLessons
                        .where((lesson) => completedLessonIds.contains(lesson.id))
                        .length;
                    final progress = allLessons.isEmpty
                        ? 0.0
                        : completedCount / allLessons.length;

                    final filteredLessons = allLessons.where((lesson) {
                      final matchesCategory = _selectedCategory == 'All' ||
                          lesson.vocabLevel.toLowerCase() ==
                              _selectedCategory.toLowerCase();

                      final matchesSearch = _searchQuery.isEmpty ||
                          lesson.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());

                      return matchesCategory && matchesSearch;
                    }).toList();

                    if (filteredLessons.isEmpty) {
                      return const Center(
                        child: Text(
                          'No lessons match the selected filters.',
                          style: TextStyle(color: Color(0xFF8D6E63)),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: filteredLessons.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildProgressSummary(
                            completedCount: completedCount,
                            totalCount: allLessons.length,
                            progress: progress,
                          );
                        }

                        final lesson = filteredLessons[index - 1];
                        return AudioCard(
                          lesson: lesson,
                          isCompleted: completedLessonIds.contains(lesson.id),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListeningDetailScreen(
                                  topicId: widget.topicId,
                                  sectionId: widget.sectionId,
                                  lesson: lesson,
                                ),
                              ),
                            );
                          },
                        );
                      },
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

  Widget _buildProgressSummary({
    required int completedCount,
    required int totalCount,
    required double progress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5EBE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Section progress',
                style: TextStyle(
                  color: Color(0xFF5D4037),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$completedCount/$totalCount',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFF5EBE6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
