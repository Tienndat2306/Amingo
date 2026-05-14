import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/vocabulary_set.dart';

class VocabularySetCard extends StatelessWidget {
  final VocabularySet vocabSet;
  final VoidCallback onTap;

  const VocabularySetCard({
    super.key,
    required this.vocabSet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = vocabSet.progress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(vocabSet.color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(vocabSet.icon, color: Color(vocabSet.color), size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            vocabSet.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildLevelBadge(),
              const Spacer(),
              Text(
                '${vocabSet.learnedCount}/${vocabSet.wordCount}',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF0D273),
              valueColor: AlwaysStoppedAnimation<Color>(Color(vocabSet.color)),
              minHeight: 4,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(vocabSet.color)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: Text(
                progress > 0 ? 'Review' : 'Learn',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(vocabSet.color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    Color levelColor;
    switch (vocabSet.level) {
      case 'Beginner':
        levelColor = Colors.green;
        break;
      case 'Intermediate':
        levelColor = Colors.orange;
        break;
      case 'Advanced':
        levelColor = Colors.red;
        break;
      default:
        levelColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: levelColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        vocabSet.level,
        style: GoogleFonts.beVietnamPro(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: levelColor,
        ),
      ),
    );
  }
}