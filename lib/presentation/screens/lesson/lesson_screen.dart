import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  late List<VocabularyWord> _words;
  late List<VocabularyWord> _reviewWords;

  int _correctAnswers = 0;
  int _incorrectAnswers = 0;

  @override
  void initState() {
    super.initState();
    _loadVocabularyData();
  }

  void _loadVocabularyData() {
    // Mock data for vocabulary words
    _words = [
      VocabularyWord(
        word: 'Apple',
        meaning: 'Quả táo',
        example: 'I eat an apple every morning.',
        pronunciation: '/ˈæpəl/',
        imageUrl: 'https://picsum.photos/400/300?random=apple',
        options: ['Quả táo', 'Quả cam', 'Quả chuối', 'Quả nho'],
        correctAnswer: 'Quả táo',
      ),
      VocabularyWord(
        word: 'Beautiful',
        meaning: 'Đẹp',
        example: 'The sunset is beautiful.',
        pronunciation: '/ˈbjuːtɪfəl/',
        imageUrl: 'https://picsum.photos/400/300?random=beautiful',
        options: ['Xấu', 'Đẹp', 'Cao', 'Thấp'],
        correctAnswer: 'Đẹp',
      ),
      VocabularyWord(
        word: 'Computer',
        meaning: 'Máy tính',
        example: 'I work on my computer all day.',
        pronunciation: '/kəmˈpjuːtər/',
        imageUrl: 'https://picsum.photos/400/300?random=computer',
        options: ['Máy in', 'Máy tính', 'Điện thoại', 'Tivi'],
        correctAnswer: 'Máy tính',
      ),
      VocabularyWord(
        word: 'Delicious',
        meaning: 'Ngon',
        example: 'This food is delicious!',
        pronunciation: '/dɪˈlɪʃəs/',
        imageUrl: 'https://picsum.photos/400/300?random=delicious',
        options: ['Dở', 'Ngon', 'Mặn', 'Ngọt'],
        correctAnswer: 'Ngon',
      ),
      VocabularyWord(
        word: 'Important',
        meaning: 'Quan trọng',
        example: 'Learning English is important.',
        pronunciation: '/ɪmˈpɔːrtnt/',
        imageUrl: 'https://picsum.photos/400/300?random=important',
        options: ['Không quan trọng', 'Cần thiết', 'Quan trọng', 'Bình thường'],
        correctAnswer: 'Quan trọng',
      ),
    ];

    _reviewWords = List.from(_words);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentWord = _reviewWords[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E3),
      appBar: _buildAppBar(colorScheme),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Flashcard
                  Expanded(
                    flex: 3,
                    child: _buildFlashcard(currentWord, colorScheme),
                  ),
                  const SizedBox(height: 20),
                  // Question section
                  if (!_isAnswered)
                    _buildQuestionSection(currentWord, colorScheme),
                  // Result section
                  if (_isAnswered)
                    _buildResultSection(currentWord, colorScheme),
                  const SizedBox(height: 20),
                  // Next button
                  if (_isAnswered)
                    _buildNextButton(colorScheme),
                ],
              ),
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
        icon: const Icon(Icons.close, color: Color(0xFF775600)),
        onPressed: () => _showExitDialog(),
      ),
      title: Column(
        children: [
          Text(
            widget.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2D00),
            ),
          ),
          Text(
            'Review Session',
            style: GoogleFonts.beVietnamPro(
              fontSize: 12,
              color: const Color(0xFF6B5A23),
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.volume_up, color: Color(0xFF775600)),
          onPressed: () {
            // Text to speech functionality
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentIndex + 1) / _reviewWords.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentIndex + 1} of ${_reviewWords.length}',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B5A23),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '$_correctAnswers',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.cancel, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    '$_incorrectAnswers',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF0D273),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF775600)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(VocabularyWord word, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlipped = !_isFlipped;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isFlipped
            ? _buildCardBack(word, colorScheme)
            : _buildCardFront(word, colorScheme),
      ),
    );
  }

  Widget _buildCardFront(VocabularyWord word, ColorScheme colorScheme) {
    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDBC13), Color(0xFF775600)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                word.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image,
                    size: 60,
                    color: Colors.white.withOpacity(0.7),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            word.word,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              word.pronunciation,
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Tap to flip',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(VocabularyWord word, ColorScheme colorScheme) {
    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 50,
            color: Color(0xFFFDBC13),
          ),
          const SizedBox(height: 20),
          Text(
            'Meaning',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B5A23),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.meaning,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2D00),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDBC13).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Example',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B5A23),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  word.example,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF3A2D00),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              setState(() {
                _isFlipped = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDBC13),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Got it!',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF543C00),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(VocabularyWord word, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'What is the meaning of "${word.word}"?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3A2D00),
            ),
          ),
          const SizedBox(height: 20),
          ...word.options.map((option) {
            return _buildOptionButton(option, word.correctAnswer, colorScheme);
          }),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option, String correctAnswer, ColorScheme colorScheme) {
    bool isSelected = _selectedAnswer == option;
    bool isCorrect = option == correctAnswer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          if (_selectedAnswer == null) {
            setState(() {
              _selectedAnswer = option;
              if (isCorrect) {
                _correctAnswers++;
              } else {
                _incorrectAnswers++;
              }
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isCorrect ? Colors.green : Colors.red)
                : const Color(0xFFF0D273).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isCorrect ? Colors.green : Colors.red)
                  : const Color(0xFFC1AC6C).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF3A2D00),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(VocabularyWord word, ColorScheme colorScheme) {
    bool isCorrect = _selectedAnswer == word.correctAnswer;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isCorrect ? Icons.thumb_up : Icons.thumb_down,
            size: 40,
            color: isCorrect ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 12),
          Text(
            isCorrect ? 'Correct!' : 'Incorrect!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Text(
              'The correct answer is: ${word.correctAnswer}',
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                color: const Color(0xFF3A2D00),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            word.example,
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF6B5A23),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(ColorScheme colorScheme) {
    bool isLastWord = _currentIndex == _reviewWords.length - 1;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
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
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF775600),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
          isLastWord ? 'Complete Session' : 'Next Word',
          style: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Exit Review',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2D00),
            ),
          ),
          content: Text(
            'Your progress will be lost. Are you sure you want to exit?',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              color: const Color(0xFF6B5A23),
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
                  color: const Color(0xFF6B5A23),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB02500),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Exit',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCompletionDialog() {
    final score = (_correctAnswers / _reviewWords.length * 100).toInt();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              const Icon(
                Icons.emoji_events,
                size: 60,
                color: Color(0xFFFDBC13),
              ),
              const SizedBox(height: 12),
              Text(
                'Session Complete!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3A2D00),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You scored $score%',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF775600),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$_correctAnswers',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Correct',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 12,
                          color: const Color(0xFF6B5A23),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$_incorrectAnswers',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'Incorrect',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 12,
                          color: const Color(0xFF6B5A23),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF775600),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Text('Finish'),
            ),
          ],
        );
      },
    );
  }
}

class VocabularyWord {
  final String word;
  final String meaning;
  final String example;
  final String pronunciation;
  final String imageUrl;
  final List<String> options;
  final String correctAnswer;

  VocabularyWord({
    required this.word,
    required this.meaning,
    required this.example,
    required this.pronunciation,
    required this.imageUrl,
    required this.options,
    required this.correctAnswer,
  });
}