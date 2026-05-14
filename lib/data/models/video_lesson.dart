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
  final DateTime createdAt;

  VideoLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.views,
    required this.thumbnail,
    this.videoUrl = '',
    required this.level,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory VideoLesson.fromJson(Map<String, dynamic> json) {
    return VideoLesson(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '0:00',
      views: json['views'] ?? '0',
      thumbnail: json['thumbnail'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      level: json['level'] ?? 'Beginner',
      isFeatured: json['isFeatured'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
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
      'createdAt': createdAt.toIso8601String(),
    };
  }
}