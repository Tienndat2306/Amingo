import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/vocabulary_set.dart';
import '../../../data/models/vocabulary_word.dart';
import '../widgets/vocabulary_set_card.dart';
import '../../lesson/screens/lesson_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<VocabularySet> _vocabSets = [];
  final Map<String, Map<String, dynamic>> _topicProgress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VocabularySet> get _filteredVocabSets {
    final keyword = _searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) return _vocabSets;

    return _vocabSets
        .where((set) => set.title.toLowerCase().contains(keyword))
        .toList();
  }

  Future<int> _getWordCount(String setId) async {
    try {
      final snapshot = await _firestore
          .collection('vocabulary_words')
          .where('setId', isEqualTo: setId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final setsSnapshot = await _firestore.collection('vocabulary_sets').get();
      _vocabSets = setsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return VocabularySet.fromJson(data);
      }).toList();

      final Set<String> completedSetIds = {};

      if (userId != null) {
        final completedSnapshot = await _firestore
            .collection('user_progress')
            .doc(userId)
            .collection('completed_topics')
            .where('type', isEqualTo: 'vocabulary')
            .get();

        for (var doc in completedSnapshot.docs) {
          completedSetIds.add(doc.id);
        }
      }

      for (var set in _vocabSets) {
        final currentWordCount = await _getWordCount(set.id);

        if (completedSetIds.contains(set.id)) {
          _topicProgress[set.id] = {
            'percentage': 100,
            'masteredWords': currentWordCount,
            'totalWords': currentWordCount,
            'isPassed': true,
          };
        } else {
          int masteredCount = 0;
          if (userId != null) {
            final masteredSnapshot = await _firestore
                .collection('user_progress')
                .doc(userId)
                .collection('vocabulary')
                .where('setId', isEqualTo: set.id)
                .where('isMastered', isEqualTo: true)
                .get();
            masteredCount = masteredSnapshot.docs.length
                .clamp(0, currentWordCount)
                .toInt();
          }
          final percentage = currentWordCount > 0
              ? (masteredCount / currentWordCount * 100).round()
              : 0;
          _topicProgress[set.id] = {
            'percentage': percentage,
            'masteredWords': masteredCount,
            'totalWords': currentWordCount,
            'isPassed': false,
          };
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double _getProgress(String setId) {
    final progress = _topicProgress[setId];
    if (progress == null) return 0.0;
    final percentage = (progress['percentage'] ?? 0) / 100;
    return percentage.clamp(0.0, 1.0);
  }

  bool _isCompleted(String setId) {
    final progress = _topicProgress[setId];
    if (progress == null) return false;
    return (progress['percentage'] ?? 0) >= 100;
  }

  int _getMasteredWords(String setId) {
    return _topicProgress[setId]?['masteredWords'] ?? 0;
  }

  int _getTotalWords(String setId) {
    return _topicProgress[setId]?['totalWords'] ?? 0;
  }

  Future<void> _navigateToLesson(VocabularySet vocabSet) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final wordsSnapshot = await _firestore
        .collection('vocabulary_words')
        .where('setId', isEqualTo: vocabSet.id)
        .get();

    final words = wordsSnapshot.docs
        .map((doc) => VocabularyWord.fromJson(doc.data()))
        .toList();

    final Set<String> masteredIds = {};

    if (userId != null) {
      final completedDoc = await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('completed_topics')
          .doc(vocabSet.id)
          .get();

      if (completedDoc.exists) {
        for (var word in words) {
          masteredIds.add(word.id);
        }
      } else {
        final masteredSnapshot = await _firestore
            .collection('user_progress')
            .doc(userId)
            .collection('vocabulary')
            .where('setId', isEqualTo: vocabSet.id)
            .where('isMastered', isEqualTo: true)
            .get();

        masteredIds.addAll(masteredSnapshot.docs.map((doc) => doc.id));
      }
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LessonScreen(
            vocabularySet: vocabSet,
            words: words,
            masteredIds: masteredIds,
          ),
        ),
      ).then((_) => _loadData());
    }
  }

  Future<void> _resetSet(VocabularySet set) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress'),
        content: Text(
          'Are you sure you want to restart "${set.title}" from the beginning?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await _firestore
            .collection('user_progress')
            .doc(userId)
            .collection('completed_topics')
            .doc(set.id)
            .delete();

        final masteredWords = await _firestore
            .collection('user_progress')
            .doc(userId)
            .collection('vocabulary')
            .where('setId', isEqualTo: set.id)
            .get();
        for (final doc in masteredWords.docs) {
          await doc.reference.delete();
        }

        await _firestore.collection('vocabulary_sets').doc(set.id).update({
          'learnedCount': 0,
        });

        await _loadData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Progress has been reset!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
          setState(() => _isLoading = false);
        }
      }
    }
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
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _vocabSets.isEmpty
                  ? const Center(child: Text('No vocabulary sets yet.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search by title',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_filteredVocabSets.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 48),
                              child: Center(
                                child: Text('No vocabulary sets found.'),
                              ),
                            )
                          else
                            ..._filteredVocabSets.map((set) {
                              final progress = _getProgress(set.id);
                              final isCompleted = _isCompleted(set.id);
                              final masteredCount = _getMasteredWords(set.id);
                              final totalCount = _getTotalWords(set.id);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: VocabularySetCard(
                                  vocabSet: set,
                                  progress: progress,
                                  isCompleted: isCompleted,
                                  masteredCount: masteredCount,
                                  totalCount: totalCount,
                                  onTap: () => _navigateToLesson(set),
                                  onReset: () => _resetSet(set),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
            ),
    );
  }
}
