import 'package:flutter/material.dart';

class SpacedRepetitionService {
  // Lịch ôn tập theo cấp độ (ngày)
  static const List<int> reviewIntervals = [0, 1, 3, 7, 14, 30, 60, 90];

  // Cấp độ thành thạo (0-5)
  static const List<int> masteryLevels = [0, 1, 2, 3, 4, 5];

  // Tính ngày ôn tập tiếp theo dựa trên cấp độ thành thạo
  static DateTime getNextReviewDate(int masteryLevel) {
    if (masteryLevel >= reviewIntervals.length - 1) {
      return DateTime.now().add(Duration(days: reviewIntervals.last));
    }
    return DateTime.now().add(Duration(days: reviewIntervals[masteryLevel]));
  }

  // Tính cấp độ thành thạo mới
  static int calculateNewMasteryLevel(
    int currentLevel,
    bool isCorrect,
    int consecutiveCorrect,
  ) {
    if (isCorrect) {
      // Đúng: tăng level, thưởng thêm nếu học liên tiếp
      int bonus = consecutiveCorrect >= 3 ? 1 : 0;
      return (currentLevel + 1 + bonus).clamp(0, 5);
    } else {
      // Sai: giảm level nhưng không dưới 0
      return (currentLevel - 1).clamp(0, 5);
    }
  }

  // Tính điểm thưởng dựa trên thời gian trả lời
  static int calculateBonusPoints(int secondsToAnswer) {
    if (secondsToAnswer <= 3) return 10; // Siêu nhanh
    if (secondsToAnswer <= 5) return 5; // Nhanh
    if (secondsToAnswer <= 10) return 2; // Bình thường
    return 0; // Chậm
  }

  // Lấy text mô tả cấp độ
  static String getMasteryLabel(int masteryLevel) {
    switch (masteryLevel) {
      case 0:
        return 'Not learned';
      case 1:
        return 'Newly learned';
      case 2:
        return 'Remembering';
      case 3:
        return 'Fairly remembered';
      case 4:
        return 'Well remembered';
      case 5:
        return 'Mastered';
      default:
        return 'Unknown';
    }
  }

  // Lấy màu cho cấp độ
  static Color getMasteryColor(int masteryLevel) {
    switch (masteryLevel) {
      case 0:
        return const Color(0xFF9E9E9E);
      case 1:
        return const Color(0xFFF44336);
      case 2:
        return const Color(0xFFFF9800);
      case 3:
        return const Color(0xFFFFC107);
      case 4:
        return const Color(0xFF8BC34A);
      case 5:
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
