import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/vocabulary_word.dart';
import '../../../data/mock/mock_vocabulary.dart';
import '../widgets/flashcard.dart';
import '../widgets/question_section.dart';
import '../widgets/result_section.dart';
import '../widgets/lesson_progress_indicator.dart';
import '../widgets/completion_dialog.dart';

class LessonScreen extends StatefulWidget {
  final String title;
  final String category;
  final int totalWords;
  final int learnedCount;

  const LessonScreen({
    super.key,
    required this.title,
    required this.category,
    required this.totalWords,
    required this.learnedCount,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isAnswered = false;
  String? _selectedAnswer;

  List<VocabularyWord> _words = [];
  int _correctAnswers = 0;
  int _incorrectAnswers = 0;

  @override
  void initState() {
    super.initState();
    _loadVocabularyData();
  }

  void _loadVocabularyData() {
    _words = MockVocabularyData.getMockVocabularyWords();
  }

  void _handleAnswer(String answer, String correctAnswer) {
    if (_selectedAnswer != null) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      if (answer == correctAnswer) {
        _correctAnswers++;
      } else {
        _incorrectAnswers++;
      }
    });
  }

  void _nextWord() {
    final isLastWord = _currentIndex == _words.length - 1;

    if (isLastWord) {
      _showCompletionDialog();
    } else {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _isAnswered = false;
        _selectedAnswer = null;
      });
    }
  }

  void _showCompletionDialog() {
    final score = (_correctAnswers / _words.length * 100).toInt();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompletionDialog(
        score: score,
        correctAnswers: _correctAnswers,
        incorrectAnswers: _incorrectAnswers,
        onFinish: () => Navigator.pop(context),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Exit Review',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Your progress will be lost. Are you sure you want to exit?',
          style: GoogleFonts.beVietnamPro(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentWord = _words[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: _showExitDialog,
        ),
        title: Column(
          children: [
            Text(
              widget.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Review Session',
              style: GoogleFonts.beVietnamPro(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          LessonProgressIndicator(
            currentIndex: _currentIndex,
            totalWords: _words.length,
            correctAnswers: _correctAnswers,
            incorrectAnswers: _incorrectAnswers,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Flashcard(
                      word: currentWord,
                      isFlipped: _isFlipped,
                      onFlip: () => setState(() => _isFlipped = !_isFlipped),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_isAnswered)
                    QuestionSection(
                      word: currentWord,
                      selectedAnswer: _selectedAnswer,
                      onAnswer: (answer) => _handleAnswer(answer, currentWord.correctAnswer),
                    ),
                  if (_isAnswered)
                    ResultSection(
                      selectedAnswer: _selectedAnswer!,
                      correctAnswer: currentWord.correctAnswer,
                      example: currentWord.example,
                    ),
                  const SizedBox(height: 20),
                  if (_isAnswered)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextWord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                        child: Text(
                          _currentIndex == _words.length - 1 ? 'Complete Session' : 'Next Word',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}