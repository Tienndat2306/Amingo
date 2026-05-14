import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/audio_lesson.dart';
import '../../../data/mock/mock_audio.dart';
import '../widgets/audio_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  List<AudioLesson> _lessons = [];
  List<AudioLesson> _filteredLessons = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Podcasts', 'Conversations', 'News', 'Stories'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _lessons = MockAudioData.getMockAudioLessons();
    _filterLessons();
    setState(() => _isLoading = false);
  }

  void _filterLessons() {
    _filteredLessons = _lessons.where((lesson) {
      final matchesCategory = _selectedCategory == 'All' ||
          lesson.subtitle.contains(_selectedCategory) ||
          (_selectedCategory == 'Podcasts' && lesson.title.contains('Podcast')) ||
          (_selectedCategory == 'Conversations' && lesson.title.contains('Conversations')) ||
          (_selectedCategory == 'News' && lesson.title.contains('News')) ||
          (_selectedCategory == 'Stories' && lesson.title.contains('Story'));

      final matchesSearch = _searchQuery.isEmpty ||
          lesson.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lesson.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
    setState(() {});
  }

  void _onCategorySelected(String category) {
    _selectedCategory = category;
    _filterLessons();
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _filterLessons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Listening',
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play, color: AppColors.primary),
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
            child: _isLoading
                ? const LoadingWidget()
                : RefreshIndicator(
              onRefresh: _loadData,
              child: _filteredLessons.isEmpty
                  ? const Center(
                child: Text('No audio lessons found'),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredLessons.length,
                itemBuilder: (context, index) {
                  return AudioCard(
                    lesson: _filteredLessons[index],
                    onTap: () {},
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}