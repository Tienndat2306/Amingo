import 'package:flutter/material.dart';

class AudioLesson {
  final String id;
  final String title;
  final String subtitle;
  final String duration;
  final bool isNew;
  final bool isPopular;
  final IconData icon;
  final String audioUrl;
  final String transcript;
  final String level;
  final DateTime createdAt;

  AudioLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    this.isNew = false,
    this.isPopular = false,
    required this.icon,
    this.audioUrl = '',
    this.transcript = '',
    this.level = 'Beginner',
    required this.createdAt,
  });

  factory AudioLesson.fromJson(Map<String, dynamic> json) {
    return AudioLesson(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      duration: json['duration'] ?? '0:00',
      isNew: json['isNew'] ?? false,
      isPopular: json['isPopular'] ?? false,
      icon: _getIconFromString(json['icon'] ?? 'headphones'),
      audioUrl: json['audioUrl'] ?? '',
      transcript: json['transcript'] ?? '',
      level: json['level'] ?? 'Beginner',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'duration': duration,
      'isNew': isNew,
      'isPopular': isPopular,
      'icon': _getStringFromIcon(icon),
      'audioUrl': audioUrl,
      'transcript': transcript,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'headphones': return Icons.headphones;
      case 'business_center': return Icons.business_center;
      case 'flight': return Icons.flight;
      case 'newspaper': return Icons.newspaper;
      case 'auto_stories': return Icons.auto_stories;
      default: return Icons.headphones;
    }
  }

  static String _getStringFromIcon(IconData icon) {
    switch (icon) {
      case Icons.headphones: return 'headphones';
      case Icons.business_center: return 'business_center';
      case Icons.flight: return 'flight';
      case Icons.newspaper: return 'newspaper';
      case Icons.auto_stories: return 'auto_stories';
      default: return 'headphones';
    }
  }
}