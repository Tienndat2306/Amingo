import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/video_lesson.dart';

class VideoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  Future<void> markAsWatched(String videoId) async {
    final docId = '${_currentUserId}_$videoId';

    await _firestore.collection('already_watched_videos').doc(docId).set({
      'videoId': videoId,
      'userId': _currentUserId,
      'watchedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<String>> getAlreadyWatchedVideos() {
    return _firestore
        .collection('already_watched_videos')
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => doc['videoId'].toString()).toList(),
        );
  }

  Stream<bool> isVideoSaved(String videoId) {
    return _firestore
        .collection('saved_videos')
        .doc('${_currentUserId}_$videoId')
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Future<void> toggleSaveVideo(VideoLesson video) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final docRef = _firestore.collection('saved_videos').doc('${userId}_${video.id}');
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.delete();
      return;
    }

    await docRef.set({
      'userId': userId,
      'id': video.id,
      'title': video.title,
      'description': video.description,
      'duration': video.duration,
      'views': video.views,
      'thumbnail': video.thumbnail,
      'thumbnailUrl': video.thumbnail,
      'videoUrl': video.videoUrl,
      'level': video.level,
      'isFeatured': video.isFeatured,
      'hasSubtitles': video.hasSubtitles,
      'isPublished': video.isPublished,
      'createdAt': Timestamp.fromDate(video.createdAt),
      'savedAt': FieldValue.serverTimestamp(),
    });
  }
}
