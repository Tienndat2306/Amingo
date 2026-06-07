import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/vocabulary_word.dart';
import '../../../data/models/vocabulary_set.dart';
import '../widgets/flashcard.dart';

class LessonScreen extends StatefulWidget {
  final VocabularySet vocabularySet;
  final List<VocabularyWord> words;
  final Set<String> masteredIds;

  const LessonScreen({
    super.key,
    required this.vocabularySet,
    required this.words,
    required this.masteredIds,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<VocabularyWord> _currentSessionWords = [];
  int _currentIndex = 0;
  int _learnedCount = 0;
  bool _isLoading = true;
  bool _isCompleted = false;
  String? _error;
  final Set<String> _learnedInSession = {};
  bool _isReviewMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final completedDoc = await _firestore
            .collection('user_progress')
            .doc(userId)
            .collection('completed_topics')
            .doc(widget.vocabularySet.id)
            .get();

        if (completedDoc.exists) {
          _isReviewMode = true;
          _currentSessionWords = List.from(widget.words);
          _learnedCount = widget.words.length;
          setState(() => _isLoading = false);
          return;
        }
      }

      _currentSessionWords = widget.words
          .where((word) => !widget.masteredIds.contains(word.id))
          .toList();

      _learnedCount = widget.words.length - _currentSessionWords.length;

      if (_currentSessionWords.isEmpty &&
          widget.words.isNotEmpty &&
          !_isReviewMode) {
        _isCompleted = true;
        if (userId != null) {
          await _markTopicCompleted(userId);
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markTopicCompleted(String userId) async {
    await _firestore
        .collection('user_progress')
        .doc(userId)
        .collection('completed_topics')
        .doc(widget.vocabularySet.id)
        .set({
          'topicId': widget.vocabularySet.id,
          'title': widget.vocabularySet.title,
          'type': 'vocabulary',
          'completedAt': FieldValue.serverTimestamp(),
          'percentage': 100,
          'totalWords': widget.words.length,
        });

    await _firestore
        .collection('vocabulary_sets')
        .doc(widget.vocabularySet.id)
        .update({'learnedCount': widget.words.length});
  }

  Future<void> _saveWordMastery(String userId, VocabularyWord word) async {
    await _firestore
        .collection('user_progress')
        .doc(userId)
        .collection('vocabulary')
        .doc(word.id)
        .set({
          'wordId': word.id,
          'setId': widget.vocabularySet.id,
          'topicId': widget.vocabularySet.id,
          'isMastered': true,
          'masteredAt': FieldValue.serverTimestamp(),
          'lastReviewed': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  void _handleKnow() {
    if (_currentSessionWords.isEmpty) return;

    if (_isReviewMode) {
      setState(() {
        _currentSessionWords.removeAt(_currentIndex);
        if (_currentIndex >= _currentSessionWords.length &&
            _currentSessionWords.isNotEmpty) {
          _currentIndex = 0;
        }
      });
      return;
    }

    final word = _currentSessionWords[_currentIndex];
    final userId = FirebaseAuth.instance.currentUser?.uid;

    _learnedInSession.add(word.id);
    if (userId != null) {
      unawaited(_saveWordMastery(userId, word));
    }

    setState(() {
      _currentSessionWords.removeAt(_currentIndex);
      _learnedCount++;

      if (_currentSessionWords.isEmpty) {
        _isCompleted = true;
        if (userId != null) {
          _markTopicCompleted(userId);
        }
      } else if (_currentIndex >= _currentSessionWords.length &&
          _currentSessionWords.isNotEmpty) {
        _currentIndex = 0;
      }
    });
  }

  void _handleDontKnow() {
    if (_currentSessionWords.isEmpty) return;

    setState(() {
      final wordToRelearn = _currentSessionWords.removeAt(_currentIndex);
      _currentSessionWords.add(wordToRelearn);

      if (_currentSessionWords.isNotEmpty &&
          _currentIndex >= _currentSessionWords.length) {
        _currentIndex = 0;
      }
    });
  }

  Future<void> _resetProgress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress'),
        content: Text('Are you sure you want to restart from the beginning?'),
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
            .doc(widget.vocabularySet.id)
            .delete();

        final masteredWords = await _firestore
            .collection('user_progress')
            .doc(userId)
            .collection('vocabulary')
            .where('setId', isEqualTo: widget.vocabularySet.id)
            .get();
        for (final doc in masteredWords.docs) {
          await doc.reference.delete();
        }

        await _firestore
            .collection('vocabulary_sets')
            .doc(widget.vocabularySet.id)
            .update({'learnedCount': 0});

        _learnedInSession.clear();
        _isReviewMode = false;
        _isCompleted = false;

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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: $_error')),
      );
    }

    if (_isCompleted && !_isReviewMode) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 60,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Congratulations!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You have completed this topic',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"${widget.vocabularySet.title}"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Progress: 100% (${widget.words.length}/${widget.words.length} words)',
                    style: GoogleFonts.beVietnamPro(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _resetProgress,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Restart from beginning'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_currentSessionWords.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'No vocabulary words in this topic yet',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    final currentWord = _currentSessionWords[_currentIndex];
    final progress = _isReviewMode
        ? 100
        : (_learnedCount / widget.words.length * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.vocabularySet.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _isReviewMode
                  ? 'Review mode'
                  : 'Learned: $_learnedCount/${widget.words.length} words',
              style: GoogleFonts.beVietnamPro(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Flashcard(
          word: currentWord,
          onKnow: _handleKnow,
          onDontKnow: _handleDontKnow,
        ),
      ),
    );
  }
}
