import 'package:cloud_firestore/cloud_firestore.dart';

class VocabularyWord {
  final String id;
  final String word;
  final String meaning;
  final String example;
  final String exampleMeaning;
  final String pronunciation;
  final String imageUrl;
  final List<String> options;
  final String correctAnswer;
  final String category;
  final String level;
  final DateTime createdAt;
  final String setId;

  VocabularyWord({
    required this.id,
    required this.word,
    required this.meaning,
    required this.example,
    required this.exampleMeaning,
    required this.pronunciation,
    required this.imageUrl,
    required this.options,
    required this.correctAnswer,
    required this.category,
    required this.level,
    required this.createdAt,
    required this.setId,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      example: json['example'] ?? '',
      exampleMeaning: json['exampleMeaning'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? 'Beginner',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      setId: json['setId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'example': example,
      'exampleMeaning': exampleMeaning,
      'pronunciation': pronunciation,
      'imageUrl': imageUrl,
      'options': options,
      'correctAnswer': correctAnswer,
      'category': category,
      'level': level,
      'createdAt': Timestamp.fromDate(createdAt),
      'setId': setId,
    };
  }
}