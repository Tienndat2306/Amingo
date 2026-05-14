import 'package:flutter/material.dart';
import '../models/audio_lesson.dart';

class MockAudioData {
  static List<AudioLesson> getMockAudioLessons() {
    return [
      AudioLesson(
        id: '1',
        title: 'Daily Conversations',
        subtitle: 'Beginner Level • 5 min',
        duration: '5:23',
        isNew: true,
        isPopular: true,
        icon: Icons.headphones,
        level: 'Beginner',
        createdAt: DateTime.now(),
      ),
      AudioLesson(
        id: '2',
        title: 'Business Meeting',
        subtitle: 'Intermediate Level • 8 min',
        duration: '8:45',
        isNew: false,
        isPopular: true,
        icon: Icons.business_center,
        level: 'Intermediate',
        createdAt: DateTime.now(),
      ),
      AudioLesson(
        id: '3',
        title: 'Travel Podcast',
        subtitle: 'Beginner Level • 6 min',
        duration: '6:12',
        isNew: true,
        isPopular: false,
        icon: Icons.flight,
        level: 'Beginner',
        createdAt: DateTime.now(),
      ),
      AudioLesson(
        id: '4',
        title: 'News Report',
        subtitle: 'Advanced Level • 10 min',
        duration: '10:30',
        isNew: false,
        isPopular: false,
        icon: Icons.newspaper,
        level: 'Advanced',
        createdAt: DateTime.now(),
      ),
      AudioLesson(
        id: '5',
        title: 'Story Time',
        subtitle: 'Intermediate Level • 7 min',
        duration: '7:15',
        isNew: false,
        isPopular: true,
        icon: Icons.auto_stories,
        level: 'Intermediate',
        createdAt: DateTime.now(),
      ),
    ];
  }
}