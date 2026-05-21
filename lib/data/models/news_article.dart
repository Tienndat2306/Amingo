import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleSection {
  final String heading;
  final List<String> paragraphs;

  ArticleSection({
    required this.heading,
    required this.paragraphs,
  });

  factory ArticleSection.fromJson(Map<String, dynamic> json) {
    return ArticleSection(
      heading: json['heading'] ?? '',
      paragraphs: List<String>.from(
        json['paragraphs'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'paragraphs': paragraphs,
    };
  }
}

class NewsArticle {
  final String id;
  final String title;
  final String category;
  final String content;
  final List<String> paragraphs;
  final List<ArticleSection> sections;
  final List<String> words;
  final String imageUrl;
  final String originalUrl;
  final String language;
  final String difficulty;
  final int wordCount;
  final String translatedTitle;
  final List<String> translatedParagraphs;
  final String audioUrl;
  final DateTime? createdAt;

  NewsArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.paragraphs,
    required this.sections,
    required this.words,
    required this.imageUrl,
    required this.originalUrl,
    required this.language,
    required this.difficulty,
    required this.wordCount,
    required this.translatedTitle,
    required this.translatedParagraphs,
    required this.audioUrl,
    required this.createdAt,
  });

  factory NewsArticle.fromFirestore(
      DocumentSnapshot doc,
      ) {
    final data = doc.data() as Map<String, dynamic>;

    return NewsArticle(
      id: data['id'] ?? doc.id,

      title: data['title'] ?? '',

      category: data['category'] ?? '',

      content: data['content'] ?? '',

      paragraphs: List<String>.from(
        data['paragraphs'] ?? [],
      ),

      sections: (data['sections'] as List<dynamic>? ?? [])
          .map(
            (e) => ArticleSection.fromJson(e),
      ).toList(),

      words: List<String>.from(
        data['words'] ?? [],
      ),

      imageUrl: data['imageUrl'] ?? '',

      originalUrl: data['originalUrl'] ?? '',

      language: data['language'] ?? 'en',

      difficulty: data['difficulty'] ?? 'A1',

      wordCount: data['wordCount'] ?? 0,

      translatedTitle:
      data['translatedTitle'] ?? '',

      translatedParagraphs:
      List<String>.from(
        data['translatedParagraphs'] ?? [],
      ),

      audioUrl: data['audioUrl'] ?? '',

      createdAt:
      (data['createdAt'] as Timestamp?)
          ?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'content': content,
      'paragraphs': paragraphs,
      'sections':
      sections.map((e) => e.toJson()).toList(),
      'words': words,
      'imageUrl': imageUrl,
      'originalUrl': originalUrl,
      'language': language,
      'difficulty': difficulty,
      'wordCount': wordCount,
      'translatedTitle': translatedTitle,
      'translatedParagraphs':
      translatedParagraphs,
      'audioUrl': audioUrl,
      'createdAt': createdAt,
    };
  }
}