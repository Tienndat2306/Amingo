import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/vocabulary_word.dart';
import '../../../core/widgets/smart_image.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final VocabularyWord word;
  final Function(bool, int) onAnswer; // (isCorrect, secondsToAnswer)
  final VoidCallback onNext;

  const MultipleChoiceWidget({
    super.key,
    required this.word,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  int _startTime = 0;

  // Tạo các đáp án nhiễu (nếu chưa có)
  List<String> get _options {
    if (widget.word.options.isNotEmpty) {
      return widget.word.options;
    }
    // Tạo đáp án nhiễu mặc định
    return [
      widget.word.meaning,
      '${widget.word.meaning} (other)',
      'Other word 1',
      'Other word 2',
    ];
  }

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now().millisecondsSinceEpoch;
  }

  void _handleAnswer(String answer) {
    if (_isAnswered) return;

    final isCorrect = answer == widget.word.meaning;
    final secondsToAnswer =
        (DateTime.now().millisecondsSinceEpoch - _startTime) ~/ 1000;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, secondsToAnswer);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Câu hỏi
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
              if (widget.word.imageUrl.isNotEmpty)
                Container(
                  height: 100,
                  width: 100,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SmartImage(
                      imageUrl: widget.word.imageUrl,
                      height: 100,
                      width: 100,
                    ),
                  ),
                ),
                        Text(
                          'What does "${widget.word.word}" mean?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.word.pronunciation,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Các đáp án
        ..._options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOptionButton(option),
          ),
        ),
        // Nút tiếp theo
        if (_isAnswered)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
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
          ),
        // Kết quả
        if (_isAnswered)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isCorrect
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCorrect ? AppColors.success : AppColors.error,
              ),
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
                        ? 'Correct! +10 points'
                        : 'Incorrect! The correct answer is: ${widget.word.meaning}',
                    style: GoogleFonts.beVietnamPro(
                      color: _isCorrect ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOptionButton(String option) {
    final isSelected = _selectedAnswer == option;
    final isCorrectOption = option == widget.word.meaning;

    Color getBackgroundColor() {
      if (!_isAnswered) return const Color(0xFFF0D273).withValues(alpha: 0.3);
      if (isSelected && isCorrectOption) return AppColors.success;
      if (isSelected && !isCorrectOption) return AppColors.error;
      if (isCorrectOption) return AppColors.success.withValues(alpha: 0.3);
      return const Color(0xFFF0D273).withValues(alpha: 0.3);
    }

    return Container(
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isAnswered && isCorrectOption
              ? AppColors.success
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        onTap: () => _handleAnswer(option),
        title: Text(
          option,
          style: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: (_isAnswered && isSelected && !isCorrectOption)
                ? Colors.white
                : AppColors.textPrimary,
          ),
        ),
        trailing: _isAnswered && isSelected
            ? Icon(
                isCorrectOption ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
