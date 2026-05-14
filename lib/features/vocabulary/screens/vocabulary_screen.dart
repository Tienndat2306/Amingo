import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/vocabulary_set.dart';
import '../../../data/mock/mock_vocabulary.dart';
import '../widgets/vocabulary_set_card.dart';
import '../widgets/stats_header.dart';
import '../../lesson/screens/lesson_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  List<VocabularySet> _vocabSets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _vocabSets = MockVocabularyData.getMockVocabularySets();
    setState(() => _isLoading = false);
  }

  void _navigateToLesson(VocabularySet vocabSet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          title: vocabSet.title,
          category: vocabSet.level,
          totalWords: vocabSet.wordCount,
          learnedCount: vocabSet.learnedCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Vocabulary',
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const StatsHeader(
            totalWords: 290,
            learnedWords: 140,
            progress: 0.48,
          ),
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : RefreshIndicator(
              onRefresh: _loadData,
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
                  return VocabularySetCard(
                    vocabSet: _vocabSets[index],
                    onTap: () => _navigateToLesson(_vocabSets[index]),
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