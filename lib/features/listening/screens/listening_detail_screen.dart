import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/listening_lesson.dart';
import '../../../data/models/dictation_line.dart';
import '../../../data/repositories/listening_repository.dart';

class UserAnswer {
  final DictationLine line;
  final String userText;
  final bool isCorrect;

  UserAnswer({
    required this.line,
    required this.userText,
    required this.isCorrect,
  });
}

class ListeningDetailScreen extends StatefulWidget {
  final String topicId;
  final String sectionId;
  final ListeningLesson lesson;

  const ListeningDetailScreen({
    super.key,
    required this.topicId,
    required this.sectionId,
    required this.lesson,
  });

  @override
  State<ListeningDetailScreen> createState() => _ListeningDetailScreenState();
}

class _ListeningDetailScreenState extends State<ListeningDetailScreen> {
  final TextEditingController _inputController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ListeningRepository _repository = ListeningRepository();

  List<DictationLine> _dictationLines = [];
  bool _isLoadingFirebase = true;

  bool _isPlaying = false;
  int _currentIndex = 0;
  String _currentStatus = 'initial';
  bool _isFinished = false;

  final List<UserAnswer> _userAnswersHistory = [];
  bool _hasSavedCompletion = false;

  static const Color primaryBrown = Color(0xFF5D4037);
  static const Color textSecondary = Color(0xFF8D6E63);
  static const Color backgroundLight = Color(0xFFFDFBF7);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color correctGreen = Color(0xFFE8F5E9);
  static const Color correctText = Color(0xFF2E7D32);
  static const Color wrongRed = Color(0xFFFFEBEE);
  static const Color wrongText = Color(0xFFC62828);

  String _normalizeAudioSource(String audioPath) {
    final trimmedPath = audioPath.trim();
    if (trimmedPath.startsWith('http://') ||
        trimmedPath.startsWith('https://')) {
      return trimmedPath;
    }

    final slashNormalizedPath = trimmedPath.replaceAll('\\', '/');
    final assetsIndex = slashNormalizedPath.indexOf('assets/audio/');
    if (assetsIndex != -1) {
      return slashNormalizedPath.substring(assetsIndex);
    }

    return trimmedPath;
  }

  @override
  void initState() {
    super.initState();
    _fetchLinesFromFirebase();

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  Future<void> _fetchLinesFromFirebase() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('listening_topics')
          .doc(widget.topicId)
          .collection('sections')
          .doc(widget.sectionId)
          .collection('lessons')
          .doc(widget.lesson.id)
          .collection('dictation_lines')
          .orderBy('index', descending: false)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _dictationLines = querySnapshot.docs.map((doc) {
          return DictationLine.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Firestore Connection Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFirebase = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    final audioSource = _normalizeAudioSource(url);

    if (audioSource.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Audio link is empty or missing!")),
      );
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (audioSource.startsWith('assets/')) {
          final assetPath = audioSource.replaceFirst('assets/', '');
          await _audioPlayer.play(AssetSource(assetPath));
        } else if (audioSource.startsWith('http://') ||
            audioSource.startsWith('https://')) {
          await _audioPlayer.play(UrlSource(audioSource));
        } else {
          await _audioPlayer.play(DeviceFileSource(audioSource));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to play audio: $e")));
    }
  }

  void _handleMainAction() {
    if (_dictationLines.isEmpty) return;

    final currentLine = _dictationLines[_currentIndex];
    final originalUserText = _inputController.text;
    final userTextClean = originalUserText.trim().toLowerCase();
    final correctTextClean = currentLine.correctText.trim().toLowerCase();

    final cleanUser = userTextClean.replaceAll(
      RegExp(r'[.,\/#!$%\^&\*;:{}=\-_`~()]'),
      '',
    );
    final cleanCorrect = correctTextClean.replaceAll(
      RegExp(r'[.,\/#!$%\^&\*;:{}=\-_`~()]'),
      '',
    );

    if (_currentStatus == 'initial') {
      final isCorrect = cleanUser == cleanCorrect;

      setState(() {
        _currentStatus = isCorrect ? 'checked_correct' : 'checked_wrong';
        _userAnswersHistory.add(
          UserAnswer(
            line: currentLine,
            userText: originalUserText,
            isCorrect: isCorrect,
          ),
        );
      });
      _audioPlayer.stop();
    } else {
      if (_currentIndex < _dictationLines.length - 1) {
        setState(() {
          _currentIndex++;
          _currentStatus = 'initial';
          _inputController.clear();
        });
      } else {
        setState(() {
          _isFinished = true;
        });
        _saveLessonCompletion();
      }
    }
  }

  void _saveLessonCompletion() {
    if (_hasSavedCompletion) return;
    _hasSavedCompletion = true;

    final correctAnswers = _userAnswersHistory
        .where((answer) => answer.isCorrect)
        .length;

    unawaited(
      _repository.markLessonCompleted(
        topicId: widget.topicId,
        sectionId: widget.sectionId,
        lesson: widget.lesson,
        correctAnswers: correctAnswers,
        totalQuestions: _dictationLines.length,
      ),
    );
  }

  double _calculateCorrectPercentage() {
    if (_userAnswersHistory.isEmpty || _dictationLines.isEmpty) return 0.0;
    int correctCount = _userAnswersHistory
        .where((answer) => answer.isCorrect)
        .length;
    return (correctCount / _dictationLines.length) * 100;
  }

  void _resetLessonState() {
    setState(() {
      _currentIndex = 0;
      _currentStatus = 'initial';
      _isFinished = false;
      _hasSavedCompletion = false;
      _userAnswersHistory.clear();
      _inputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text(
          _isFinished ? "Evaluation Results" : widget.lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: primaryBrown,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryBrown,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(child: _buildMainBody()),
    );
  }

  Widget _buildMainBody() {
    if (_isLoadingFirebase) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(accentGold),
        ),
      );
    }

    if (_dictationLines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                "No Data Found!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryBrown,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Could not find any dictation exercises for this lesson on Firestore.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _isFinished
        ? _buildEvaluationResultView()
        : _buildLessonExerciseView();
  }

  Widget _buildLessonExerciseView() {
    final currentLine = _dictationLines[_currentIndex];

    Color currentBorderColor = const Color(0xFFF5EBE6);
    if (_currentStatus == 'checked_correct') {
      currentBorderColor = correctText.withValues(alpha: 0.4);
    } else if (_currentStatus == 'checked_wrong') {
      currentBorderColor = wrongText.withValues(alpha: 0.4);
    }

    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: currentBorderColor, width: 1.5),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: accentGold, width: 1.5),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EBE6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "QUESTION ${_currentIndex + 1} / ${_dictationLines.length}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryBrown,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 30),

          GestureDetector(
            onTap: () => _playAudio(currentLine.audioUrl),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryBrown.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: _isPlaying ? accentGold : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.volume_up_rounded,
                color: accentGold,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isPlaying
                ? "Playing audio... Tap to pause"
                : "Tap to listen to the audio snippet",
            style: const TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),

          TextField(
            controller: _inputController,
            enabled: _currentStatus == 'initial',
            maxLines: 4,
            style: const TextStyle(
              color: primaryBrown,
              fontSize: 15,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Type exactly what you hear...',
              hintStyle: TextStyle(
                color: textSecondary.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              enabledBorder: baseBorder,
              focusedBorder: focusedBorder,
              disabledBorder: baseBorder,
            ),
          ),
          const SizedBox(height: 16),

          if (_currentStatus == 'checked_correct')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: correctGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: correctText.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: correctText,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Excellent! Your answer is perfectly correct.",
                      style: TextStyle(
                        color: correctText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_currentStatus == 'checked_wrong')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: wrongRed,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: wrongText.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cancel_rounded, color: wrongText, size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Not quite right!",
                        style: TextStyle(
                          color: wrongText,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      "Correct Answer:\n\"${_dictationLines[_currentIndex].correctText}\"",
                      style: const TextStyle(
                        color: wrongText,
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),

          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFCA28), Color(0xFFFFB300)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: accentGold.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _handleMainAction,
              child: Text(
                _currentStatus == 'initial' ? "CHECK ANSWER" : "NEXT QUESTION",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationResultView() {
    final percentage = _calculateCorrectPercentage();
    final wrongAnswers = _userAnswersHistory
        .where((answer) => !answer.isCorrect)
        .toList();
    final totalCorrect = _userAnswersHistory
        .where((answer) => answer.isCorrect)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryBrown.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "${percentage.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: accentGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Your Accuracy Level",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Correctly answered $totalCorrect out of ${_dictationLines.length} phrases.",
                    style: const TextStyle(fontSize: 13, color: textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Review Details",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: primaryBrown,
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: wrongAnswers.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: correctGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars_rounded, color: correctText),
                          SizedBox(width: 8),
                          Text(
                            "Flawless! You got everything right.",
                            style: TextStyle(
                              color: correctText,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: wrongAnswers.length,
                    itemBuilder: (context, index) {
                      final wrongItem = wrongAnswers[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFF5EBE6),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 11,
                                  backgroundColor: wrongRed,
                                  child: Text(
                                    "${wrongItem.line.index}",
                                    style: const TextStyle(
                                      color: wrongText,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Incorrect Content",
                                  style: TextStyle(
                                    color: wrongText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "You typed: \"${wrongItem.userText.isEmpty ? 'Left empty' : wrongItem.userText}\"",
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Correct: \"${wrongItem.line.correctText}\"",
                              style: const TextStyle(
                                color: correctText,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFCA28), Color(0xFFFFB300)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accentGold.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _resetLessonState();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Restarting the lesson..."),
                    duration: Duration(milliseconds: 700),
                  ),
                );
              },
              child: const Text(
                "Retry This Lesson",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: textSecondary, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Back to List",
                style: TextStyle(
                  color: primaryBrown,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
