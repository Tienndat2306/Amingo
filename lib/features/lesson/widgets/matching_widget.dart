import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/vocabulary_word.dart';

class MatchingWidget extends StatefulWidget {
  final List<VocabularyWord> words;
  final Function(int, int) onComplete; // (score, totalTime)
  final VoidCallback onNext;

  const MatchingWidget({
    super.key,
    required this.words,
    required this.onComplete,
    required this.onNext,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  late List<MatchingItem> _leftItems;
  late List<MatchingItem> _rightItems;

  MatchingItem? _selectedLeft;
  int _score = 0;
  int _matchedCount = 0;
  int _startTime = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _initGame();
  }

  void _initGame() {
    final wordsToUse = widget.words.take(6).toList();

    _leftItems = wordsToUse.asMap().entries.map((entry) {
      return MatchingItem(
        id: entry.key,
        text: entry.value.word,
        type: 'word',
        pairId: entry.key,
      );
    }).toList();

    _rightItems = wordsToUse.asMap().entries.map((entry) {
      return MatchingItem(
        id: entry.key,
        text: entry.value.meaning,
        type: 'meaning',
        pairId: entry.key,
      );
    }).toList();

    // Xáo trộn bên phải
    _rightItems.shuffle(Random());
  }

  void _onLeftTap(MatchingItem item) {
    if (_isCompleted) return;

    setState(() {
      if (_selectedLeft == null) {
        // Chọn item bên trái
        _selectedLeft = item;
      } else {
        // Đã có item được chọn, kiểm tra ghép cặp
        final isMatch = _selectedLeft!.pairId == item.pairId;

        if (isMatch && !_selectedLeft!.isMatched && !item.isMatched) {
          // Ghép đúng
          _selectedLeft!.isMatched = true;
          item.isMatched = true;
          _score += 10;
          _matchedCount++;
        }

        _selectedLeft = null;

        // Kiểm tra hoàn thành
        if (_matchedCount == _leftItems.length) {
          _isCompleted = true;
          final totalTime =
              (DateTime.now().millisecondsSinceEpoch - _startTime) ~/ 1000;
          widget.onComplete(_score, totalTime);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header điểm
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🎯 Score: $_score',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '✅ Matched: $_matchedCount/${_leftItems.length}',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Bảng ghép cặp
        Expanded(
          child: Row(
            children: [
              // Cột trái (Từ)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Vocabulary',
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _leftItems.length,
                        itemBuilder: (context, index) {
                          return _buildItemCard(_leftItems[index], true);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Cột phải (Nghĩa)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Meaning',
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _rightItems.length,
                        itemBuilder: (context, index) {
                          return _buildItemCard(_rightItems[index], false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isCompleted)
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
      ],
    );
  }

  Widget _buildItemCard(MatchingItem item, bool isLeft) {
    final isSelected = _selectedLeft == item;
    final isDisabled = item.isMatched;

    Color getColor() {
      if (isDisabled) return AppColors.success.withValues(alpha: 0.2);
      if (isSelected) return AppColors.primary;
      return Colors.white;
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => _onLeftTap(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: getColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (isDisabled)
              const Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.success,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.text,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  fontWeight: isDisabled ? FontWeight.w600 : FontWeight.normal,
                  color: isDisabled ? AppColors.success : AppColors.textPrimary,
                  decoration: isDisabled ? TextDecoration.lineThrough : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchingItem {
  final int id;
  final String text;
  final String type;
  final int pairId;
  bool isMatched;

  MatchingItem({
    required this.id,
    required this.text,
    required this.type,
    required this.pairId,
    this.isMatched = false,
  });
}
