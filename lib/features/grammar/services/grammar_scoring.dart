class GrammarScoringService {
  // Tính điểm cho mỗi câu hỏi
  static const Map<String, int> questionPoint = {
    'easy': 10,
    'medium': 20,
    'hard': 30,
  };

  // Tính XP dựa trên kết quả
  static int calculateXP(int score, int totalQuestions, int timeSpentSeconds) {
    final percentage = totalQuestions > 0 ? score / totalQuestions : 0;

    // Điểm cơ bản
    int baseXP = 0;
    if (percentage >= 0.9) {
      baseXP = 100; // 90-100%
    } else if (percentage >= 0.7) {
      baseXP = 70; // 70-89%
    } else if (percentage >= 0.5) {
      baseXP = 50; // 50-69%
    } else {
      baseXP = 20; // <50%
    }

    // Bonus thời gian
    int timeBonus = 0;
    if (timeSpentSeconds <= 60) {
      timeBonus = 30; // <1 phút
    } else if (timeSpentSeconds <= 120) {
      timeBonus = 20; // 1-2 phút
    } else if (timeSpentSeconds <= 180) {
      timeBonus = 10; // 2-3 phút
    }

    // Bonus hoàn hảo
    final perfectBonus = (percentage == 1.0) ? 50 : 0;

    return baseXP + timeBonus + perfectBonus;
  }

  // Tính level dựa trên tổng XP
  static int getLevelFromXP(int totalXP) {
    if (totalXP < 100) return 1;
    if (totalXP < 300) return 2;
    if (totalXP < 600) return 3;
    if (totalXP < 1000) return 4;
    if (totalXP < 1500) return 5;
    if (totalXP < 2100) return 6;
    if (totalXP < 2800) return 7;
    if (totalXP < 3600) return 8;
    if (totalXP < 4500) return 9;
    return 10;
  }

  // Lấy title của level
  static String getLevelTitle(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Learner';
      case 3:
        return 'Knowledgeable';
      case 4:
        return 'Basic Mastery';
      case 5:
        return 'Intermediate';
      case 6:
        return 'Good';
      case 7:
        return 'Advanced';
      case 8:
        return 'Excellent';
      case 9:
        return 'Expert';
      case 10:
        return 'Master';
      default:
        return 'Learner';
    }
  }

  // Nhận xét dựa trên kết quả
  static String getFeedback(int score, int totalQuestions, bool isNewRecord) {
    final percentage = totalQuestions > 0 ? score / totalQuestions : 0;

    if (percentage == 1.0) {
      return '🎉 Perfect! You did an excellent job!';
    } else if (percentage >= 0.9) {
      return '🌟 Great! You were almost perfect!';
    } else if (percentage >= 0.7) {
      return '👍 Very good! Keep pushing a little further!';
    } else if (percentage >= 0.5) {
      return '📚 Good effort! Review a few more points.';
    } else {
      return '💪 Keep going! Review the lesson and try again.';
    }
  }

  // Gợi ý những phần cần ôn tập
  static List<String> getReviewSuggestions(
    List<Map<String, dynamic>> wrongAnswers,
  ) {
    final Map<String, int> topicErrors = {};

    for (var answer in wrongAnswers) {
      final topic = answer['topic'] ?? 'general';
      topicErrors[topic] = (topicErrors[topic] ?? 0) + 1;
    }

    final suggestions = <String>[];
    topicErrors.forEach((topic, count) {
      suggestions.add('• $topic: $count wrong attempts');
    });

    return suggestions;
  }
}
