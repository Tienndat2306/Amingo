class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String content;
  final String category;
  final String readTime;
  final String date;
  final String imageUrl;
  final bool isBreaking;
  final String views;
  final DateTime createdAt;

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    this.content = '',
    required this.category,
    required this.readTime,
    required this.date,
    required this.imageUrl,
    this.isBreaking = false,
    this.views = '0',
    required this.createdAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      readTime: json['readTime'] ?? '5 min read',
      date: json['date'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isBreaking: json['isBreaking'] ?? false,
      views: json['views'] ?? '0',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'readTime': readTime,
      'date': date,
      'imageUrl': imageUrl,
      'isBreaking': isBreaking,
      'views': views,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}