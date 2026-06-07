import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/video_lesson.dart';
import '../models/subtitle_item.dart';

class VideoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<VideoLesson>> watchVideoLessons({bool onlyPublished = false}) {
    return _firestore
        .collection('video_lessons')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final List<VideoLesson> allVideos = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return VideoLesson.fromJson(data);
      }).toList();

      if (onlyPublished) {
        return allVideos.where((video) => video.isPublished == true).toList();
      }
      
      return allVideos;
    });
  }

  Future<VideoLesson?> getVideoById(String videoId) async {
    try {
      final doc = await _firestore.collection('video_lessons').doc(videoId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return VideoLesson.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("[REPO_ERROR] Error fetching video by ID: $e");
      return null;
    }
  }

  Future<List<VideoLesson>> searchVideoLessons(String query, {bool onlyPublished = false}) async {
    try {
      if (query.trim().isEmpty) return [];

      final snapshot = await _firestore.collection('video_lessons').get();
      final List<VideoLesson> results = [];
      final lowercaseQuery = query.toLowerCase().trim();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id; 
        
        final video = VideoLesson.fromJson(data);
        
        if (onlyPublished && video.isPublished == false) {
          continue;
        }

        if (video.title.toLowerCase().contains(lowercaseQuery)) {
          results.add(video);
        }
      }
      return results;
    } catch (e) {
      debugPrint("[SEARCH_ERROR] Error searching videos: $e");
      return [];
    }
  }

  Future<List<SubtitleItem>> fetchSubtitles(String targetIdOrUrl) async {
    try {
      final allVideosSnapshot = await _firestore.collection('video_lessons').get();
      String? actualDocId;

      for (var doc in allVideosSnapshot.docs) {
        String urlInFirebase = doc.data()['videoUrl'] ?? '';
        
        if (urlInFirebase.contains(targetIdOrUrl) || doc.id == targetIdOrUrl) {
          actualDocId = doc.id;
          break;
        }
      }

      if (actualDocId == null) {
        if (allVideosSnapshot.docs.isNotEmpty) {
          actualDocId = allVideosSnapshot.docs.first.id;
        } else {
          return [];
        }
      }

      final subtitleSnapshot = await _firestore
          .collection('video_lessons')
          .doc(actualDocId)
          .collection('subtitles')
          .orderBy('start')
          .get();

      return subtitleSnapshot.docs.map((doc) {
        return SubtitleItem.fromFirestore(doc.data());
      }).toList();

    } catch (e) {
      debugPrint("[REPO_ERROR] Error fetching subtitles: $e");
      return [];
    }
  }

  Stream<List<SubtitleItem>> watchSubtitles(String videoId) {
    return _firestore
        .collection('video_lessons')
        .doc(videoId)
        .collection('subtitles')
        .orderBy('start', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubtitleItem.fromFirestore(doc.data()))
            .toList());
  }

  Future<void> incrementVideoViews(String videoId) async {
    try {
      final docRef = _firestore.collection('video_lessons').doc(videoId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (snapshot.exists) {
          String currentViewsStr = snapshot.data()?['views']?.toString() ?? '0';
          int currentViewsInt = int.tryParse(currentViewsStr) ?? 0;
          int newViewsInt = currentViewsInt + 1;
          
          transaction.update(docRef, {
            'views': newViewsInt.toString(),
          });
        }
      });
    } catch (e) {
      debugPrint("[VIEWS_ERROR] Error incrementing video views: $e");
    }
  }

  Future<bool> createVideoLesson(Map<String, dynamic> videoData) async {
    try {
      final finalData = {
        ...videoData,
        'views': '0', 
        'duration': videoData['duration'] ?? '00:00', 
        'isPublished': videoData['isPublished'] ?? false, 
        'createdAt': FieldValue.serverTimestamp(), 
      };

      await _firestore.collection('video_lessons').add(finalData);
      return true;
    } catch (e) {
      debugPrint("[ADMIN_REPO_ERROR] Error creating video: $e");
      return false;
    }
  }

  Future<bool> updateVideoPublishStatus(String videoId, bool isPublished) async {
    try {
      await _firestore
          .collection('video_lessons')
          .doc(videoId)
          .update({'isPublished': isPublished});
      return true;
    } catch (e) {
      debugPrint("[ADMIN_REPO_ERROR] Error updating publish status: $e");
      return false;
    }
  }

  Future<void> updateVideoInfo(String videoId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('video_lessons').doc(videoId).update(data);
    } catch (e) {
      debugPrint("[ADMIN_REPO_ERROR] Error updating video details: $e");
      rethrow;
    }
  }

  Future<void> deleteVideoLesson(String videoId) async {
    try {
      await _firestore.collection('video_lessons').doc(videoId).delete();
    } catch (e) {
      debugPrint("[ADMIN_REPO_ERROR] Error deleting video: $e");
      rethrow;
    }
  }

  Future<void> updateSubtitleFull({
    required String videoId,
    required double oldStart,
    required double newStart,
    required double newEnd,
    required String newContent,
    required String newVi,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('video_lessons')
          .doc(videoId)
          .collection('subtitles')
          .where('start', isEqualTo: oldStart)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({
          'start': newStart,
          'end': newEnd,
          'content': newContent,
          'vi': newVi,
        });
      } else {
        throw Exception("Original subtitle data not found on the system.");
      }
    } catch (e) {
      debugPrint("[ADMIN_REPO_ERROR] Error updating subtitle: $e");
      rethrow;
    }
  }

  Future<void> addSubtitle({
    required String videoId,
    required double start,
    required double end,
    required String content,
    required String vi,
  }) async {
    try {
      await _firestore
          .collection('video_lessons')
          .doc(videoId)
          .collection('subtitles')
          .add({
        'start': start,
        'end': end,
        'content': content,
        'vi': vi,
      });
    } catch (e) {
      debugPrint("[ADMIN_REPO_ERROR] Error adding new subtitle: $e");
      rethrow;
    }
  }

  Future<void> deleteSubtitle({
    required String videoId,
    required double start,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('video_lessons')
          .doc(videoId)
          .collection('subtitles')
          .where('start', isEqualTo: start)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      }
    } catch (e) {
      debugPrint("[ADMIN_REPO_ERROR] Error deleting subtitle: $e");
      rethrow;
    }
  }

  Future<List<VideoLesson>> fetchVideoLessons() async => [];
  Stream<List<VideoLesson>> watchFeaturedVideos() => const Stream.empty();
}
