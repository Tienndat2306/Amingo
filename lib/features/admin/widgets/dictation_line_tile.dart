import 'package:flutter/material.dart';
import '../../../data/models/dictation_line.dart';

class DictationLineTile extends StatelessWidget {
  final DictationLine line;
  final bool isPlaying;
  final VoidCallback onPlayToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const Color _primaryBrown = Color(0xFF5D4037);
  static const Color _textSecondary = Color(0xFF8D6E63);
  static const Color _accentGold = Color(0xFFFFB300);
  static const Color _deleteRed = Color(0xFFC62828);

  const DictationLineTile({
    super.key,
    required this.line,
    required this.isPlaying,
    required this.onPlayToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying ? _accentGold : const Color(0xFFEFEBE9),
          width: isPlaying ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Index badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isPlaying
                    ? _accentGold.withValues(alpha: 0.15)
                    : const Color(0xFFF5EBE6),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${line.index}',
                  style: TextStyle(
                    color: isPlaying ? _accentGold : _primaryBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.correctText.isEmpty ? '(No text)' : line.correctText,
                    style: const TextStyle(
                      color: _primaryBrown,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.audiotrack_rounded, size: 12, color: _textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          line.audioUrl.isEmpty ? 'No audio path' : line.audioUrl,
                          style: TextStyle(
                            color: _textSecondary.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionIconButton(
                  icon: isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                  color: isPlaying ? _accentGold : _textSecondary,
                  size: 28,
                  onTap: onPlayToggle,
                ),
                _ActionIconButton(
                  icon: Icons.edit_outlined,
                  color: _primaryBrown,
                  onTap: onEdit,
                ),
                _ActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: _deleteRed,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
      onPressed: onTap,
    );
  }
}