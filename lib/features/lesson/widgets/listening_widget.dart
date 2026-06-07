import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/vocabulary_word.dart';

class ListeningWidget extends StatefulWidget {
  final VocabularyWord word;
  final Function(bool, int) onAnswer;
  final VoidCallback onNext;

  const ListeningWidget({
    super.key,
    required this.word,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  State<ListeningWidget> createState() => _ListeningWidgetState();
}

class _ListeningWidgetState extends State<ListeningWidget> {
  final TextEditingController _answerController = TextEditingController();
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _isPlaying = false;
  final int _attempts = 0;

  void _checkAnswer() {
    if (_isAnswered) return;

    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer = widget.word.word.toLowerCase();
    final isCorrect = userAnswer == correctAnswer;

    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, _attempts);
  }

  void _playAudio() {
    setState(() => _isPlaying = true);
    // Giả lập phát âm thanh (sau này thay bằng audioplayers)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Phần nghe
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              // Nút nghe
              GestureDetector(
                onTap: _playAudio,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying
                        ? Icons.play_arrow
                        : Icons.headphones, // ← SỬA: Ioshua → Icons
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Listen and enter the word you hear',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Ô nhập câu trả lời
              TextField(
                controller: _answerController,
                enabled: !_isAnswered,
                decoration: InputDecoration(
                  hintText: 'Enter your answer...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check_circle),
                    onPressed: _isAnswered ? null : _checkAnswer,
                  ),
                ),
                style: GoogleFonts.beVietnamPro(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Kết quả
        if (_isAnswered) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.error,
                      color: _isCorrect ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isCorrect
                            ? 'Correct!'
                            : 'The correct answer is: ${widget.word.word}',
                        style: GoogleFonts.beVietnamPro(
                          color: _isCorrect
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Meaning: ${widget.word.meaning}',
                  style: GoogleFonts.beVietnamPro(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Next', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
