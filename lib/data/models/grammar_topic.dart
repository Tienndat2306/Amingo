import 'package:flutter/material.dart';

class GrammarTopic {
  final String id;
  final String title;
  final String description;
  final String level;
  final double progress;
  final int lessonCount;
  final IconData icon;
  final DateTime createdAt;

  GrammarTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    this.progress = 0.0,
    this.lessonCount = 0,
    required this.icon,
    required this.createdAt,
  });

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    return GrammarTopic(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? 'Beginner',
      progress: (json['progress'] ?? 0).toDouble(),
      lessonCount: json['lessonCount'] ?? 0,
      icon: _getIconFromString(json['icon'] ?? 'article'),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'progress': progress,
      'lessonCount': lessonCount,
      'icon': _getStringFromIcon(icon),
      'createdAt': createdAt.toIso8601String(),
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