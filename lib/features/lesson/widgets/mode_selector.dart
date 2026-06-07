import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

enum StudyMode { flashcard, multipleChoice, listening, spelling, matching }

class ModeSelector extends StatelessWidget {
  final StudyMode currentMode;
  final Function(StudyMode) onModeSelected;
  final int wordsLearnedCount;

  const ModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
    required this.wordsLearnedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildModeButton(
            mode: StudyMode.flashcard,
            icon: Icons.style,
            label: 'Flashcard',
            isLocked: false,
          ),
          _buildModeButton(
            mode: StudyMode.multipleChoice,
            icon: Icons.quiz,
            label: 'Quiz',
            isLocked: wordsLearnedCount < 5,
          ),
          _buildModeButton(
            mode: StudyMode.listening,
            icon: Icons.headphones,
            label: 'Nghe',
            isLocked: wordsLearnedCount < 10,
          ),
          _buildModeButton(
            mode: StudyMode.spelling,
            icon: Icons.keyboard,
            label: 'Spelling',
            isLocked: wordsLearnedCount < 15,
          ),
          _buildModeButton(
            mode: StudyMode.matching,
            icon: Icons.games,
            label: 'Matching',
            isLocked: wordsLearnedCount < 20,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required StudyMode mode,
    required IconData icon,
    required String label,
    required bool isLocked,
  }) {
    final isSelected = currentMode == mode;

    return GestureDetector(
      onTap: isLocked ? null : () => onModeSelected(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              isLocked ? Icons.lock_outline : icon,
              color: isSelected
                  ? Colors.white
                  : (isLocked ? Colors.grey : AppColors.primary),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : (isLocked ? Colors.grey : AppColors.textSecondary),
              ),
            ),
            if (isLocked)
              Text(
                '${_getRequiredCount(mode)} words',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 8,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _getRequiredCount(StudyMode mode) {
    switch (mode) {
      case StudyMode.multipleChoice:
        return 5;
      case StudyMode.listening:
        return 10;
      case StudyMode.spelling:
        return 15;
      case StudyMode.matching:
        return 20;
      default:
        return 0;
    }
  }
}
