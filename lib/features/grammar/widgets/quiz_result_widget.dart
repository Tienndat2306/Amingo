import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../services/grammar_scoring.dart';

class QuizResultWidget extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> wrongAnswers;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const QuizResultWidget({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.wrongAnswers,
    required this.onRetry,
    required this.onBack,
  });

  double get percentage => totalQuestions > 0 ? score / totalQuestions : 0;
  int get percentageInt => (percentage * 100).round();

  String get feedback =>
      GrammarScoringService.getFeedback(score, totalQuestions, false);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Result Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: percentage >= 0.7
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              percentage >= 0.7
                  ? Icons.emoji_events
                  : Icons.sentiment_satisfied,
              size: 50,
              color: percentage >= 0.7 ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(height: 24),

          // Score
          Text(
            '$score / $totalQuestions',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentageInt%',
            style: GoogleFonts.beVietnamPro(
              fontSize: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Feedback
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              feedback,
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Incorrect answers
          if (wrongAnswers.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              '📝 Incorrect answers',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...wrongAnswers.map((wrong) => _buildWrongAnswerCard(wrong)),
          ],

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Exit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Try again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWrongAnswerCard(Map<String, dynamic> wrong) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wrong['question'],
            style: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '❌ Your answer: ',
                style: TextStyle(color: AppColors.error),
              ),
              Expanded(
                child: Text(
                  wrong['userAnswer'] ?? 'Not answered',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                '✅ Answer: ',
                style: TextStyle(color: AppColors.success),
              ),
              Expanded(
                child: Text(
                  wrong['correctAnswer'],
                  style: const TextStyle(color: AppColors.success),
                ),
              ),
            ],
          ),
          if (wrong['explanation'] != null) ...[
            const SizedBox(height: 8),
            Text(
              wrong['explanation'],
              style: GoogleFonts.beVietnamPro(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
