import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class ResultSection extends StatelessWidget {
  final String selectedAnswer;
  final String correctAnswer;
  final String example;

  const ResultSection({
    super.key,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedAnswer == correctAnswer;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? AppColors.success : AppColors.error,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isCorrect ? Icons.thumb_up : Icons.thumb_down,
            size: 40,
            color: isCorrect ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            isCorrect ? 'Correct!' : 'Incorrect!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isCorrect ? AppColors.success : AppColors.error,
            ),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Text(
              'The correct answer is: $correctAnswer',
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            example,
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
