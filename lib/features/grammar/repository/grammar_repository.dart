import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/grammar_topic.dart';

class GrammarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== USER SIDE ====================

  /// Lấy tất cả chủ đề ngữ pháp
  Future<List<GrammarTopic>> getAllTopics() async {
    try {
      final snapshot = await _firestore.collection('grammar_topics').get();
      return snapshot.docs
          .map((doc) => GrammarTopic.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Lỗi lấy danh sách chủ đề ngữ pháp: $e');
      return [];
    }
  }

  /// Lấy chi tiết 1 chủ đề
  Future<GrammarTopic?> getTopicById(String id) async {
    try {
      final doc = await _firestore.collection('grammar_topics').doc(id).get();
      if (doc.exists) {
        return GrammarTopic.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi lấy chi tiết chủ đề: $e');
      return null;
    }
  }

  /// Lấy tiến độ học của user
  Future<Map<String, dynamic>> getUserGrammarProgress() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    try {
      final snapshot = await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('grammar')
          .get();

      final Map<String, dynamic> progress = {};
      for (var doc in snapshot.docs) {
        progress[doc.id] = doc.data();
      }
      return progress;
    } catch (e) {
      debugPrint('Lỗi lấy tiến độ người dùng: $e');
      return {};
    }
  }

  /// Lưu kết quả làm bài
  Future<void> saveQuizResult(
    String topicId,
    int score,
    int totalQuestions,
    int xpEarned,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final progressRef = _firestore
        .collection('user_progress')
        .doc(userId)
        .collection('grammar')
        .doc(topicId);

    try {
      final doc = await progressRef.get();
      int bestScore = score;
      int attempts = 1;

      if (doc.exists) {
        final data = doc.data()!;
        final oldBestScore = data['bestScore'] ?? 0;
        bestScore = oldBestScore > score ? oldBestScore : score;
        attempts = (data['attempts'] ?? 0) + 1;
      }

      await progressRef.set({
        'topicId': topicId,
        'bestScore': bestScore,
        'lastScore': score,
        'totalQuestions': totalQuestions,
        'percentage': totalQuestions > 0
            ? (score / totalQuestions * 100).round()
            : 0,
        'attempts': attempts,
        'xpEarned': xpEarned,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Cập nhật tổng XP của user
      await _updateUserTotalXP(xpEarned);
    } catch (e) {
      debugPrint('Lỗi lưu kết quả bài kiểm tra: $e');
    }
  }

  /// Cập nhật tổng XP của user
  Future<void> _updateUserTotalXP(int xpEarned) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userRef = _firestore.collection('users').doc(userId);

    try {
      await userRef.update({'totalXp': FieldValue.increment(xpEarned)});
    } catch (e) {
      // Nếu chưa có field, tạo mới
      await userRef.set({'totalXp': xpEarned}, SetOptions(merge: true));
    }
  }

  // ==================== ADMIN SIDE ====================

  /// Thêm chủ đề ngữ pháp mới
  Future<void> addGrammarTopic(GrammarTopic topic) async {
    try {
      await _firestore
          .collection('grammar_topics')
          .doc(topic.id)
          .set(topic.toJson());
    } catch (e) {
      debugPrint('Lỗi thêm chủ đề ngữ pháp: $e');
      rethrow;
    }
  }

  /// Cập nhật chủ đề ngữ pháp
  Future<void> updateGrammarTopic(GrammarTopic topic) async {
    try {
      await _firestore
          .collection('grammar_topics')
          .doc(topic.id)
          .update(topic.toJson());
    } catch (e) {
      debugPrint('Lỗi cập nhật chủ đề ngữ pháp: $e');
      rethrow;
    }
  }

  /// Xóa chủ đề ngữ pháp
  Future<void> deleteGrammarTopic(String topicId) async {
    try {
      // Xóa câu hỏi liên quan
      final questions = await _firestore
          .collection('grammar_questions')
          .where('topicId', isEqualTo: topicId)
          .get();

      for (var doc in questions.docs) {
        await doc.reference.delete();
      }

      // Xóa chủ đề
      await _firestore.collection('grammar_topics').doc(topicId).delete();
    } catch (e) {
      debugPrint('Lỗi xóa chủ đề ngữ pháp: $e');
      rethrow;
    }
  }

  /// Thêm câu hỏi cho bài tập
  Future<void> addGrammarQuestion(Map<String, dynamic> question) async {
    try {
      await _firestore.collection('grammar_questions').add(question);
    } catch (e) {
      debugPrint('Lỗi thêm câu hỏi: $e');
      rethrow;
    }
  }

  /// Lấy câu hỏi theo chủ đề
  Future<List<Map<String, dynamic>>> getQuestionsByTopic(String topicId) async {
    try {
      final snapshot = await _firestore
          .collection('grammar_questions')
          .where('topicId', isEqualTo: topicId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Lỗi lấy câu hỏi: $e');
      return [];
    }
  }

  /// Xóa câu hỏi
  Future<void> deleteGrammarQuestion(String questionId) async {
    try {
      await _firestore.collection('grammar_questions').doc(questionId).delete();
    } catch (e) {
      debugPrint('Lỗi xóa câu hỏi: $e');
      rethrow;
    }
  }

  /// Lấy thống kê tổng quan (Admin)
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final topicsSnapshot = await _firestore
          .collection('grammar_topics')
          .get();
      final questionsSnapshot = await _firestore
          .collection('grammar_questions')
          .get();

      // Thống kê user đã học grammar
      final usersProgress = await _firestore.collectionGroup('grammar').get();
      final completedUsers = usersProgress.docs.length;

      return {
        'totalTopics': topicsSnapshot.size,
        'totalQuestions': questionsSnapshot.size,
        'completedUsers': completedUsers,
        'avgCompletionRate': _calculateAvgCompletionRate(usersProgress.docs),
      };
    } catch (e) {
      debugPrint('Lỗi lấy thống kê admin: $e');
      return {};
    }
  }

  double _calculateAvgCompletionRate(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return 0.0;

    double total = 0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final percentage = data['percentage'] ?? 0;
      total += percentage;
    }
    return total / docs.length;
  }
}
