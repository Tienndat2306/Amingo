import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/news_article.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArticleService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =========================
  // GET ALL ARTICLES
  // =========================

  Stream<List<NewsArticle>> getArticles() {
    return _firestore
        .collection('articles')
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return NewsArticle.fromFirestore(doc);

      }).toList();
    });
  }

  // =========================
  // GET ARTICLE BY ID
  // =========================

  Future<NewsArticle?> getArticleById(
      String articleId,
      ) async {

    final doc = await _firestore
        .collection('articles')
        .doc(articleId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return NewsArticle.fromFirestore(doc);
  }

  // =========================
  // GET ARTICLES BY CATEGORY
  // =========================

  Future<List<NewsArticle>>
  getArticlesByCategory(
      String category,
      ) async {

    final snapshot = await _firestore
        .collection('articles')
        .where(
      'category',
      isEqualTo: category,
    )
        .get();

    return snapshot.docs.map((doc) {

      return NewsArticle.fromFirestore(doc);

    }).toList();
  }

  // =========================
  // GET ARTICLES BY LEVEL
  // =========================

  Future<List<NewsArticle>>
  getArticlesByDifficulty(
      String difficulty,
      ) async {

    final snapshot = await _firestore
        .collection('articles')
        .where(
      'difficulty',
      isEqualTo: difficulty,
    )
        .get();

    return snapshot.docs.map((doc) {

      return NewsArticle.fromFirestore(doc);

    }).toList();
  }

  // ==========================================
  // MARK ARTICLE AS READ
  // ==========================================

  Future<void> markAsRead(String articleId) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    final String currentUserId = userId ?? 'anonymous';

    // Tạo một Document ID duy nhất kết hợp giữa userId và articleId
    final String docId = "${currentUserId}_$articleId";

    try {
      await _firestore.collection('already_read').doc(docId).set({
        'articleId': articleId,
        'userId': currentUserId,
        'readAt': FieldValue.serverTimestamp(),
      });

      print("Firebase: Marked article $articleId as read for user $currentUserId");
    } catch (e) {
      print("Error in ArticleService.markAsRead: $e");
      rethrow;
    }
  }

  Stream<List<String>> getAlreadyReadArticles() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    final String currentUserId = userId ?? 'anonymous';

    return _firestore
        .collection('already_read')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      // Gom tất cả các articleId thành một danh sách List<String>
      return snapshot.docs.map((doc) => doc['articleId'].toString()).toList();
    });
  }
}