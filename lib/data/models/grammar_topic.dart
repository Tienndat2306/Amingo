import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GrammarTopic {
  final String id;
  final String title;
  final String description;
  final String level;
  final double progress;
  final IconData icon;
  final DateTime createdAt;

  // THÊM CÁC FIELD MỚI
  final String theory;
  final List<String> formulas;
  final List<String> keywords;
  final List<GrammarRule> rules;
  final List<GrammarExample> examples;
  final int quizCount;
  final int passingScore;
  final int estimatedTime;

  GrammarTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    this.progress = 0.0,
    required this.icon,
    required this.createdAt,
    this.theory = '',
    this.formulas = const [],
    this.keywords = const [],
    this.rules = const [],
    this.examples = const [],
    this.quizCount = 0,
    this.passingScore = 70,
    this.estimatedTime = 15,
  });

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    return GrammarTopic(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? 'Beginner',
      progress: (json['progress'] ?? 0).toDouble(),
      icon: _getIconFromString(json['icon'] ?? 'article'),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      theory: json['theory'] ?? '',
      formulas: List<String>.from(json['formulas'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      rules: (json['rules'] as List?)
          ?.map((e) => GrammarRule.fromJson(e))
          .toList() ?? [],
      examples: (json['examples'] as List?)
          ?.map((e) => GrammarExample.fromJson(e))
          .toList() ?? [],
      quizCount: json['quizCount'] ?? 0,
      passingScore: json['passingScore'] ?? 70,
      estimatedTime: json['estimatedTime'] ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'progress': progress,
      'icon': _getStringFromIcon(icon),
      'createdAt': Timestamp.fromDate(createdAt),
      'theory': theory,
      'formulas': formulas,
      'keywords': keywords,
      'rules': rules.map((e) => e.toJson()).toList(),
      'examples': examples.map((e) => e.toJson()).toList(),
      'quizCount': quizCount,
      'passingScore': passingScore,
      'estimatedTime': estimatedTime,
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'schedule': return Icons.schedule;
      case 'history': return Icons.history;
      case 'timeline': return Icons.timeline;
      case 'play_circle': return Icons.play_circle;
      case 'place': return Icons.place;
      case 'rule': return Icons.rule;
      default: return Icons.article;
    }
  }

  static String _getStringFromIcon(IconData icon) {
    switch (icon) {
      case Icons.schedule: return 'schedule';
      case Icons.history: return 'history';
      case Icons.timeline: return 'timeline';
      case Icons.play_circle: return 'play_circle';
      case Icons.place: return 'place';
      case Icons.rule: return 'rule';
      default: return 'article';
    }
  }
}

class GrammarRule {
  final String title;
  final String description;
  final List<String> formulas;
  final List<GrammarExample> examples;
  final List<String> exceptions;
  final List<String> notes;

  GrammarRule({
    required this.title,
    required this.description,
    this.formulas = const [],
    this.examples = const [],
    this.exceptions = const [],
    this.notes = const [],
  });

  factory GrammarRule.fromJson(Map<String, dynamic> json) {
    return GrammarRule(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      formulas: List<String>.from(json['formulas'] ?? []),
      examples: (json['examples'] as List?)
          ?.map((e) => GrammarExample.fromJson(e))
          .toList() ?? [],
      exceptions: List<String>.from(json['exceptions'] ?? []),
      notes: List<String>.from(json['notes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'formulas': formulas,
      'examples': examples.map((e) => e.toJson()).toList(),
      'exceptions': exceptions,
      'notes': notes,
    };
  }
}

class GrammarExample {
  final String sentence;
  final String meaning;
  final bool isCorrect;
  final String explanation;

  GrammarExample({
    required this.sentence,
    required this.meaning,
    this.isCorrect = true,
    this.explanation = '',
  });

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      sentence: json['sentence'] ?? '',
      meaning: json['meaning'] ?? '',
      isCorrect: json['isCorrect'] ?? true,
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentence': sentence,
      'meaning': meaning,
      'isCorrect': isCorrect,
      'explanation': explanation,
    };
  }
}