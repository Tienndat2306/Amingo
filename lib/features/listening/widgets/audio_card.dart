import 'package:flutter/material.dart';
import '../../../data/models/listening_lesson.dart';

class AudioCard extends StatelessWidget {
  final ListeningLesson lesson;
  final VoidCallback onTap;
  final bool isCompleted;

  const AudioCard({
    super.key,
    required this.lesson,
    required this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    const textBrown = Color(0xFF4E342E);
    const subTextBrown = Color(0xFF8D6E63);
    const learnedGreen = Color(0xFF2E7D32);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFF5EBE6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : Icons.headphones_rounded,
            color: isCompleted ? learnedGreen : textBrown,
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            color: textBrown,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Level: ${lesson.vocabLevel} - ${lesson.totalParts} parts',
                  style: const TextStyle(color: subTextBrown, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCompleted) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Learned',
                    style: TextStyle(
                      color: learnedGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFF9C4),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.play_arrow_rounded,
            color: isCompleted ? learnedGreen : const Color(0xFFFFB300),
            size: 24,
          ),
        ),
      ),
    );
  }
}
