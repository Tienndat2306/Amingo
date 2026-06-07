import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/listening_lesson.dart';
import '../models/listening_section.dart';
import '../models/listening_topic.dart';
import '../models/dictation_line.dart';

class ListeningRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------------------------------------------------------------
  // REALTIME STREAMS
  // ---------------------------------------------------------------------------

  Stream<List<ListeningTopic>> watchTopics() {
    return _firestore
        .collection('listening_topics')
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => ListeningTopic.fromJson(d.data(), d.id)).toList());
  }

  Stream<List<ListeningSection>> watchSections({required String topicId}) {
    return _firestore
        .collection('listening_topics')
        .doc(topicId)
        .collection('sections')
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => ListeningSection.fromJson(d.data(), d.id)).toList());
  }

  Stream<List<ListeningLesson>> watchLessons({
    required String topicId,
    required String sectionId,
  }) {
    return _firestore
        .collection('listening_topics')
        .doc(topicId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => ListeningLesson.fromFirestore(d.data(), d.id)).toList());
  }

  Stream<List<DictationLine>> watchDictationLines({
    required String topicId,
    required String sectionId,
    required String lessonId,
  }) {
    return _firestore
        .collection('listening_topics')
        .doc(topicId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc(lessonId)
        .collection('dictation_lines')
        .orderBy('index')
        .snapshots()
        .map((s) => s.docs.map((d) => DictationLine.fromJson(d.data(), d.id)).toList());
  }

  String _progressDocId({
    required String topicId,
    required String sectionId,
    required String lessonId,
  }) {
    return '${topicId}_${sectionId}_$lessonId';
  }

  CollectionReference<Map<String, dynamic>>? _listeningProgressRef() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    return _firestore
        .collection('user_progress')
        .doc(userId)
        .collection('listening');
  }

  Stream<Set<String>> watchCompletedLessonIds({
    required String topicId,
    required String sectionId,
  }) {
    final progressRef = _listeningProgressRef();
    if (progressRef == null) return Stream.value(<String>{});

    return progressRef.snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        return data['topicId'] == topicId && data['sectionId'] == sectionId;
      }).map((doc) {
        return doc.data()['lessonId']?.toString() ?? '';
      }).where((lessonId) => lessonId.isNotEmpty).toSet();
    });
  }

  Future<void> markLessonCompleted({
    required String topicId,
    required String sectionId,
    required ListeningLesson lesson,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final progressRef = _listeningProgressRef();
    if (progressRef == null) return;

    final score = totalQuestions > 0
        ? (correctAnswers / totalQuestions * 100).round()
        : 0;

    await progressRef
        .doc(
          _progressDocId(
            topicId: topicId,
            sectionId: sectionId,
            lessonId: lesson.id,
          ),
        )
        .set({
      'topicId': topicId,
      'sectionId': sectionId,
      'lessonId': lesson.id,
      'lessonTitle': lesson.title,
      'vocabLevel': lesson.vocabLevel,
      'totalParts': lesson.totalParts,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'score': score,
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ---------------------------------------------------------------------------
  // TOPICS
  // ---------------------------------------------------------------------------

  Future<List<ListeningTopic>> fetchTopics() async {
    final snapshot = await _firestore
        .collection('listening_topics')
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((d) => ListeningTopic.fromJson(d.data(), d.id))
        .toList();
  }

  Future<void> addTopic(ListeningTopic topic) =>
      _firestore.collection('listening_topics').add(topic.toJson());

  Future<void> updateTopic(ListeningTopic topic) => _firestore
      .collection('listening_topics')
      .doc(topic.id)
      .update(topic.toJson());

  Future<void> deleteTopic(String topicId) =>
      _firestore.collection('listening_topics').doc(topicId).delete();

  // ---------------------------------------------------------------------------
  // SECTIONS
  // ---------------------------------------------------------------------------

  Future<void> addSection({required String topicId, required ListeningSection section}) =>
      _firestore
          .collection('listening_topics')
          .doc(topicId)
          .collection('sections')
          .add(section.toJson());

  Future<void> updateSection({required String topicId, required ListeningSection section}) =>
      _firestore
          .collection('listening_topics')
          .doc(topicId)
          .collection('sections')
          .doc(section.id)
          .update(section.toJson());

  Future<void> deleteSection({required String topicId, required String sectionId}) =>
      _firestore
          .collection('listening_topics')
          .doc(topicId)
          .collection('sections')
          .doc(sectionId)
          .delete();

  // ---------------------------------------------------------------------------
  // LESSONS
  // ---------------------------------------------------------------------------

  Future<void> addLessonWithLines({
    required String topicId,
    required String sectionId,
    required ListeningLesson lesson,
    required List<DictationLine> lines,
  }) async {
    final batch = _firestore.batch();
    final lessonRef = _firestore
        .collection('listening_topics')
        .doc(topicId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc();

    batch.set(lessonRef, lesson.toFirestore());
    for (final line in lines) {
      batch.set(lessonRef.collection('dictation_lines').doc(), line.toJson());
    }
    await batch.commit();
  }

  Future<void> updateLessonWithLines({
    required String topicId,
    required String sectionId,
    required ListeningLesson lesson,
    required List<DictationLine> lines,
  }) async {
    final batch = _firestore.batch();
    final lessonRef = _firestore
        .collection('listening_topics')
        .doc(topicId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc(lesson.id);

    batch.update(lessonRef, lesson.toFirestore());

    final oldLines = await lessonRef.collection('dictation_lines').get();
    for (final doc in oldLines.docs) {
      batch.delete(doc.reference);
    }
    for (final line in lines) {
      batch.set(lessonRef.collection('dictation_lines').doc(), line.toJson());
    }
    await batch.commit();
  }

  Future<void> deleteLesson({
    required String topicId,
    required String sectionId,
    required String lessonId,
  }) =>
      _firestore
          .collection('listening_topics')
          .doc(topicId)
          .collection('sections')
          .doc(sectionId)
          .collection('lessons')
          .doc(lessonId)
          .delete();
}
