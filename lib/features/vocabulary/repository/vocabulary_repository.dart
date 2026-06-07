import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/vocabulary_set.dart';
import '../../../data/models/vocabulary_word.dart';

class VocabularyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== USER SIDE ====================

  /// Lấy tất cả bộ từ vựng
  Future<List<VocabularySet>> getAllSets() async {
    try {
      final snapshot = await _firestore.collection('vocabulary_sets').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return VocabularySet.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Lỗi lấy danh sách bộ từ: $e');
      return [];
    }
  }

  /// Lấy từ vựng theo bộ
  Future<List<VocabularyWord>> getWordsBySet(String setId) async {
    try {
      final snapshot = await _firestore
          .collection('vocabulary_words')
          .where('setId', isEqualTo: setId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return VocabularyWord.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Lỗi lấy từ vựng theo bộ: $e');
      return [];
    }
  }

  /// Lấy tiến độ học của user
  Future<Map<String, dynamic>> getUserProgress() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    try {
      final snapshot = await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('vocabulary')
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

  /// Lưu kết quả học 1 từ
  Future<void> saveWordProgress(
    String wordId,
    bool isCorrect,
    int studyMode,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final progressRef = _firestore
        .collection('user_progress')
        .doc(userId)
        .collection('vocabulary')
        .doc(wordId);

    try {
      final doc = await progressRef.get();
      int correctCount = 0;
      int totalCount = 0;
      int masteryLevel = 0;
      List<int> studyModes = [];

      if (doc.exists) {
        final data = doc.data()!;
        correctCount = data['correctCount'] ?? 0;
        totalCount = data['totalCount'] ?? 0;
        masteryLevel = data['masteryLevel'] ?? 0;
        studyModes = List<int>.from(data['studyModes'] ?? []);
      }

      if (isCorrect) correctCount++;
      totalCount++;

      if (!studyModes.contains(studyMode)) {
        studyModes.add(studyMode);
      }

      masteryLevel = ((correctCount / totalCount) * 5).round().clamp(0, 5);

      await progressRef.set({
        'wordId': wordId,
        'correctCount': correctCount,
        'totalCount': totalCount,
        'masteryLevel': masteryLevel,
        'lastReviewed': FieldValue.serverTimestamp(),
        'nextReviewDate': _calculateNextReviewDate(masteryLevel),
        'studyModes': studyModes,
      });
    } catch (e) {
      debugPrint('Lỗi lưu tiến độ từ: $e');
    }
  }

  /// Tính ngày ôn tập tiếp theo
  DateTime _calculateNextReviewDate(int masteryLevel) {
    const intervals = [1, 3, 7, 14, 30, 60];
    int days = masteryLevel < intervals.length ? intervals[masteryLevel] : 90;
    return DateTime.now().add(Duration(days: days));
  }

  /// Lấy danh sách từ cần ôn tập hôm nay
  Future<List<String>> getWordsToReview() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('vocabulary')
          .where('nextReviewDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Lỗi lấy danh sách từ cần ôn tập: $e');
      return [];
    }
  }

  // ==================== ADMIN SIDE ====================

  /// Thêm bộ từ vựng mới
  Future<void> addVocabularySet(VocabularySet set) async {
    try {
      await _firestore
          .collection('vocabulary_sets')
          .doc(set.id)
          .set(set.toJson());
    } catch (e) {
      debugPrint('Lỗi thêm bộ từ: $e');
      rethrow;
    }
  }

  /// Cập nhật bộ từ vựng
  Future<void> updateVocabularySet(VocabularySet set) async {
    try {
      await _firestore
          .collection('vocabulary_sets')
          .doc(set.id)
          .update(set.toJson());
    } catch (e) {
      debugPrint('Lỗi cập nhật bộ từ: $e');
      rethrow;
    }
  }

  /// Xóa bộ từ vựng
  Future<void> deleteVocabularySet(String setId) async {
    try {
      final words = await _firestore
          .collection('vocabulary_words')
          .where('setId', isEqualTo: setId)
          .get();

      for (var doc in words.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('vocabulary_sets').doc(setId).delete();
    } catch (e) {
      debugPrint('Lỗi xóa bộ từ: $e');
      rethrow;
    }
  }

  /// Thêm từ vựng mới
  Future<void> addVocabularyWord(VocabularyWord word) async {
    try {
      await _firestore
          .collection('vocabulary_words')
          .doc(word.id)
          .set(word.toJson());

      final setRef = _firestore.collection('vocabulary_sets').doc(word.setId);
      final setDoc = await setRef.get();
      if (setDoc.exists) {
        int currentCount = setDoc.data()?['wordCount'] ?? 0;
        await setRef.update({'wordCount': currentCount + 1});
      }
    } catch (e) {
      debugPrint('Lỗi thêm từ vựng: $e');
      rethrow;
    }
  }

  /// Cập nhật từ vựng
  Future<void> updateVocabularyWord(VocabularyWord word) async {
    try {
      await _firestore
          .collection('vocabulary_words')
          .doc(word.id)
          .update(word.toJson());
    } catch (e) {
      debugPrint('Lỗi cập nhật từ vựng: $e');
      rethrow;
    }
  }

  /// Xóa từ vựng
  Future<void> deleteVocabularyWord(String wordId, String setId) async {
    try {
      await _firestore.collection('vocabulary_words').doc(wordId).delete();

      final setRef = _firestore.collection('vocabulary_sets').doc(setId);
      final setDoc = await setRef.get();
      if (setDoc.exists) {
        int currentCount = setDoc.data()?['wordCount'] ?? 0;
        await setRef.update({'wordCount': currentCount - 1});
      }
    } catch (e) {
      debugPrint('Lỗi xóa từ vựng: $e');
      rethrow;
    }
  }

  /// Lấy thống kê tổng quan (Admin)
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final setsSnapshot = await _firestore.collection('vocabulary_sets').get();
      final wordsSnapshot = await _firestore
          .collection('vocabulary_words')
          .get();
      final usersSnapshot = await _firestore.collection('users').get();

      return {
        'totalSets': setsSnapshot.size,
        'totalWords': wordsSnapshot.size,
        'totalUsers': usersSnapshot.size,
      };
    } catch (e) {
      debugPrint('Lỗi lấy thống kê admin: $e');
      return {};
    }
  }
}
