import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vocabulary_word.dart';

class VocabularySet {
  final String id;
  final String title;
  final int wordCount;
  final int learnedCount;
  final String level;
  final IconData icon;
  final int color;
  final List<VocabularyWord> words;
  final DateTime createdAt;

  VocabularySet({
    required this.id,
    required this.title,
    this.wordCount = 0,
    this.learnedCount = 0,
    required this.level,
    required this.icon,
    required this.color,
    this.words = const [],
    required this.createdAt,
  });

  double get progress => wordCount > 0 ? learnedCount / wordCount : 0;

  factory VocabularySet.fromJson(Map<String, dynamic> json) {
    return VocabularySet(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      wordCount: json['wordCount'] ?? 0,
      learnedCount: json['learnedCount'] ?? 0,
      level: json['level'] ?? 'Beginner',
      icon: _getIconFromString(json['icon'] ?? 'school'),
      color: json['color'] ?? 0xFFFFA726,
      words: [],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'wordCount': wordCount,
      'learnedCount': learnedCount,
      'level': level,
      'icon': _getStringFromIcon(icon),
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'wb_sunny': return Icons.wb_sunny;
      case 'business': return Icons.business;
      case 'flight_takeoff': return Icons.flight_takeoff;
      case 'computer': return Icons.computer;
      case 'restaurant': return Icons.restaurant;
      default: return Icons.school;
    }
  }

  static String _getStringFromIcon(IconData icon) {
    switch (icon) {
      case Icons.wb_sunny: return 'wb_sunny';
      case Icons.business: return 'business';
      case Icons.flight_takeoff: return 'flight_takeoff';
      case Icons.computer: return 'computer';
      case Icons.restaurant: return 'restaurant';
      default: return 'school';
    }
  }
}