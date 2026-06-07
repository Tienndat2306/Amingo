import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/vocabulary_word.dart';

class SpellingWidget extends StatefulWidget {
  final VocabularyWord word;
  final Function(bool, int) onAnswer;
  final VoidCallback onNext;

  const SpellingWidget({
    super.key,
    required this.word,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  State<SpellingWidget> createState() => _SpellingWidgetState();
}

class _SpellingWidgetState extends State<SpellingWidget> {
  final TextEditingController _answerController = TextEditingController();
  bool _isAnswered = false;
  bool _isCorrect = false;
  List<bool> _letterStatus = [];
  String _hint = '';

  @override
  void initState() {
    super.initState();
    _generateHint();
    _answerController.addListener(_onTextChanged);
  }

  void _generateHint() {
    final word = widget.word.word.toLowerCase();
    final length = word.length;
    final revealCount = (length / 3).ceil();

    List<String> hintChars = List.filled(length, '_');
    List<int> revealedIndices = [];

    while (revealedIndices.length < revealCount &&
        revealedIndices.length < length) {
      final randomIndex = DateTime.now().millisecondsSinceEpoch % length;
      if (!revealedIndices.contains(randomIndex)) {
        revealedIndices.add(randomIndex);
        hintChars[randomIndex] = word[randomIndex];
      }
    }

    _hint = hintChars.join(' ');
    _letterStatus = List.filled(length, false);
  }

  void _onTextChanged() {
    final userText = _answerController.text.toLowerCase().trim();
    final word = widget.word.word.toLowerCase();

    setState(() {
      for (int i = 0; i < word.length; i++) {
        _letterStatus[i] = i < userText.length && userText[i] == word[i];
      }
    });
  }

  void _checkAnswer() {
    if (_isAnswered) return;

    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer = widget.word.word.toLowerCase();
    final isCorrect = userAnswer == correctAnswer;

    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
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
              // Nghĩa tiếng Việt
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.word.meaning,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Gợi ý
              Text(
                _hint,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 8,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              // Ô nhập
              TextField(
                controller: _answerController,
                enabled: !_isAnswered,
                decoration: InputDecoration(
                  hintText: 'Enter the English word...',
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
              const SizedBox(height: 16),
              // Hiển thị chữ cái đúng/sai
              Wrap(
                spacing: 8,
                children: List.generate(_letterStatus.length, (index) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _letterStatus[index]
                          ? AppColors.success.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _letterStatus[index]
                            ? AppColors.success
                            : Colors.grey,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _answerController.text.length > index
                            ? _answerController.text[index].toUpperCase()
                            : '?',
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.bold,
                          color: _letterStatus[index]
                              ? AppColors.success
                              : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
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
            child: Row(
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.error,
                  color: _isCorrect ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isCorrect
                        ? 'Correct! You spelled it right!'
                        : 'The correct answer is: ${widget.word.word}',
                    style: GoogleFonts.beVietnamPro(
                      color: _isCorrect ? AppColors.success : AppColors.error,
                    ),
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
