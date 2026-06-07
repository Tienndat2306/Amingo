import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/youtube_thumbnail.dart';

class VideoLesson {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String views;
  final String thumbnail;
  final String videoUrl;
  final String level;
  final bool isFeatured;
  final bool hasSubtitles;
  final bool isPublished;
  final DateTime createdAt;

  const VideoLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.views,
    required this.thumbnail,
    this.videoUrl = '',
    required this.level,
    this.isFeatured = false,
    this.hasSubtitles = false,
    this.isPublished = false,
    required this.createdAt,
  });

  VideoLesson copyWith({
    String? id,
    String? title,
    String? description,
    String? duration,
    String? views,
    String? thumbnail,
    String? videoUrl,
    String? level,
    bool? isFeatured,
    bool? hasSubtitles,
    bool? isPublished,
    DateTime? createdAt,
  }) {
    return VideoLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      views: views ?? this.views,
      thumbnail: thumbnail ?? this.thumbnail,
      videoUrl: videoUrl ?? this.videoUrl,
      level: level ?? this.level,
      isFeatured: isFeatured ?? this.isFeatured,
      hasSubtitles: hasSubtitles ?? this.hasSubtitles,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory VideoLesson.fromJson(Map<String, dynamic> json) {
    final videoUrl = json['videoUrl']?.toString() ?? '';

    return VideoLesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '0:00',
      views: json['views']?.toString() ?? '0',
      thumbnail: resolveVideoThumbnail(
        videoUrl: videoUrl,
        thumbnailUrl: json['thumbnail'],
      ),
      videoUrl: videoUrl,
      level: json['level'] ?? 'Beginner',
      isFeatured: json['isFeatured'] ?? false,
      hasSubtitles: json['hasSubtitles'] ?? false,
      isPublished: json['isPublished'] ?? false,
      createdAt: _parseTimestamp(json['createdAt']),
    );
  }

  factory VideoLesson.fromFirestore(Map<String, dynamic> json, String docId) {
    final videoUrl = json['videoUrl']?.toString() ?? '';

    return VideoLesson(
      id: docId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '0:00',
      views: json['views']?.toString() ?? '0',
      thumbnail: resolveVideoThumbnail(
        videoUrl: videoUrl,
        thumbnailUrl: json['thumbnail'],
      ),
      videoUrl: videoUrl,
      level: json['level'] ?? 'Beginner',
      isFeatured: json['isFeatured'] ?? false,
      hasSubtitles: json['hasSubtitles'] ?? false,
      isPublished: json['isPublished'] ?? false,
      createdAt: _parseTimestamp(json['createdAt']),
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'views': views,
      'thumbnail': thumbnail,
      'videoUrl': videoUrl,
      'level': level,
      'isFeatured': isFeatured,
      'hasSubtitles': hasSubtitles,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
