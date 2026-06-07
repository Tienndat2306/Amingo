import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class QuizQuestionWidget extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function(bool, Map<String, dynamic>) onAnswer;

  const QuizQuestionWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<QuizQuestionWidget> createState() => _QuizQuestionWidgetState();
}

class _QuizQuestionWidgetState extends State<QuizQuestionWidget> {
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    // RESET STATE KHI CÂU HỎI MỚI
    _selectedAnswer = null;
    _isAnswered = false;
    _isCorrect = false;
  }

  @override
  void didUpdateWidget(covariant QuizQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // RESET STATE KHI CÂU HỎI THAY ĐỔI
    if (oldWidget.question['id'] != widget.question['id']) {
      setState(() {
        _selectedAnswer = null;
        _isAnswered = false;
        _isCorrect = false;
      });
    }
  }

  void _handleAnswer(String answer) {
    if (_isAnswered) return;

    final isCorrect = answer == widget.question['correctAnswer'];
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      _isCorrect = isCorrect;
    });

    final answeredQuestion = Map<String, dynamic>.from(widget.question);
    answeredQuestion['userAnswer'] = answer;

    // CHUYỂN SANG CÂU TIẾP THEO SAU 1.5 GIÂY
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onAnswer(isCorrect, answeredQuestion);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionType = widget.question['questionType'] ?? 'multiple_choice';

    return Container(
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
          // Câu hỏi
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              widget.question['question'],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Đáp án
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (questionType == 'multiple_choice')
                    ..._buildMultipleChoiceOptions(),
                  if (questionType == 'fill_blank') _buildFillBlank(),
                  if (questionType == 'true_false') _buildTrueFalse(),
                ],
              ),
            ),
          ),

          // Kết quả (chỉ hiện sau khi đã trả lời)
          if (_isAnswered)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.error,
                        color: _isCorrect ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isCorrect
                              ? 'Correct!'
                              : 'Correct answer: ${widget.question['correctAnswer']}',
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w600,
                            color: _isCorrect
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.question['explanation'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.question['explanation'],
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMultipleChoiceOptions() {
    final options = List<String>.from(widget.question['options'] ?? []);

    return options.map((option) {
      final isSelected = _selectedAnswer == option;
      final isCorrectOption = option == widget.question['correctAnswer'];

      Color getBackgroundColor() {
        if (!_isAnswered) return const Color(0xFFF0D273).withValues(alpha: 0.3);
        if (isSelected && isCorrectOption) return AppColors.success;
        if (isSelected && !isCorrectOption) return AppColors.error;
        if (isCorrectOption) return AppColors.success.withValues(alpha: 0.3);
        return const Color(0xFFF0D273).withValues(alpha: 0.3);
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          onTap: _isAnswered ? null : () => _handleAnswer(option),
          title: Text(
            option,
            style: GoogleFonts.beVietnamPro(
              fontSize: 16,
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
    }).toList();
  }

  Widget _buildFillBlank() {
    final controller = TextEditingController();

    return Column(
      children: [
        TextField(
          controller: controller,
          enabled: !_isAnswered,
          decoration: InputDecoration(
            hintText: 'Enter your answer...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textAlign: TextAlign.center,
          style: GoogleFonts.beVietnamPro(fontSize: 16),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isAnswered
              ? null
              : () => _handleAnswer(controller.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Check'),
        ),
      ],
    );
  }

  Widget _buildTrueFalse() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isAnswered ? null : () => _handleAnswer('True'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAnswered && _selectedAnswer == 'True'
                      ? (_isCorrect ? AppColors.success : AppColors.error)
                      : Colors.grey.shade200,
                  foregroundColor: _isAnswered && _selectedAnswer == 'True'
                      ? Colors.white
                      : AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('True', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isAnswered ? null : () => _handleAnswer('False'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAnswered && _selectedAnswer == 'False'
                      ? (_isCorrect ? AppColors.success : AppColors.error)
                      : Colors.grey.shade200,
                  foregroundColor: _isAnswered && _selectedAnswer == 'False'
                      ? Colors.white
                      : AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('False', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
