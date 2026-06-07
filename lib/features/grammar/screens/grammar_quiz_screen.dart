import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/grammar_topic.dart';
import '../widgets/quiz_question_widget.dart';
import '../widgets/quiz_result_widget.dart';

class GrammarQuizScreen extends StatefulWidget {
  final GrammarTopic topic;

  const GrammarQuizScreen({super.key, required this.topic});

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _wrongAnswers = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isFinished = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore
          .collection('grammar_questions')
          .where('topicId', isEqualTo: widget.topic.id)
          .get();

      _questions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleAnswer(bool isCorrect, Map<String, dynamic> question) {
    if (isCorrect) {
      setState(() => _score++);
    } else {
      setState(() {
        _wrongAnswers.add({
          'question': question['question'],
          'userAnswer': question['userAnswer'],
          'correctAnswer': question['correctAnswer'],
          'explanation': question['explanation'],
        });
      });
    }

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        _goToNextQuestion();
      }
    });
  }

  void _goToNextQuestion() {
    final nextIndex = _currentIndex + 1;

    if (nextIndex < _questions.length) {
      setState(() {
        _currentIndex = nextIndex;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final percentage = _questions.isNotEmpty
        ? (_score / _questions.length * 100).round()
        : 0;
    final isPassed = percentage >= widget.topic.passingScore;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('grammar')
          .doc(widget.topic.id)
          .set({
            'score': _score,
            'totalQuestions': _questions.length,
            'percentage': percentage,
            'isPassed': isPassed,
            'completedAt': isPassed ? FieldValue.serverTimestamp() : null,
          }, SetOptions(merge: true));

      if (isPassed) {
        await _firestore
            .collection('user_progress')
            .doc(userId)
            .collection('completed_topics')
            .doc(widget.topic.id)
            .set({
              'topicId': widget.topic.id,
              'title': widget.topic.title,
              'type': 'grammar',
              'completedAt': FieldValue.serverTimestamp(),
              'percentage': percentage,
              'totalQuestions': _questions.length,
            }, SetOptions(merge: true));
      } else {
        await _firestore
            .collection('user_progress')
            .doc(userId)
            .collection('completed_topics')
            .doc(widget.topic.id)
            .delete();
      }
    }

    setState(() => _isFinished = true);
  }

  void _retryQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _wrongAnswers = [];
      _isFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.topic.title),
          backgroundColor: AppColors.background,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.topic.title),
          backgroundColor: AppColors.background,
        ),
        body: Center(child: Text('Error: $_error')),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.topic.title),
          backgroundColor: AppColors.background,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No questions available for this topic'),
              Text('Go to Admin to add questions'),
            ],
          ),
        ),
      );
    }

    if (_isFinished) {
      final percentage = _questions.isNotEmpty
          ? (_score / _questions.length * 100).round()
          : 0;
      final isPassed = percentage >= widget.topic.passingScore;

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.topic.title),
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
        ),
        body: QuizResultWidget(
          score: _score,
          totalQuestions: _questions.length,
          wrongAnswers: _wrongAnswers,
          onRetry: _retryQuiz,
          onBack: () => Navigator.pop(context),
        ),
        bottomNavigationBar: isPassed
            ? Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.success.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      'Congratulations! You have completed this topic!',
                      style: GoogleFonts.beVietnamPro(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : null,
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final progress = ((_currentIndex + 1) / _questions.length * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.topic.title),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        'Score: $_score',
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Question ${_currentIndex + 1}/${_questions.length}',
                    style: GoogleFonts.beVietnamPro(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$progress%',
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: QuizQuestionWidget(
                question: currentQuestion,
                onAnswer: (isCorrect, answeredQuestion) {
                  _handleAnswer(isCorrect, answeredQuestion);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
