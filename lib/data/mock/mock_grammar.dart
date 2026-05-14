import 'package:flutter/material.dart';
import '../models/grammar_topic.dart';

class MockGrammarData {
  static List<GrammarTopic> getMockGrammarTopics() {
    return [
      GrammarTopic(
        id: '1',
        title: 'Present Simple Tense',
        description: 'Learn how to use present simple for daily routines and facts.',
        level: 'Beginner',
        progress: 0.65,
        lessonCount: 12,
        icon: Icons.schedule,
        createdAt: DateTime.now(),
      ),
      GrammarTopic(
        id: '2',
        title: 'Past Simple Tense',
        description: 'Master past actions and completed events.',
        level: 'Beginner',
        progress: 0.30,
        lessonCount: 10,
        icon: Icons.history,
        createdAt: DateTime.now(),
      ),
      GrammarTopic(
        id: '3',
        title: 'Future Simple Tense',
        description: 'Express future plans, predictions, and promises.',
        level: 'Intermediate',
        progress: 0.0,
        lessonCount: 8,
        icon: Icons.timeline,
        createdAt: DateTime.now(),
      ),
      GrammarTopic(
        id: '4',
        title: 'Present Continuous',
        description: 'Actions happening now or around now.',
        level: 'Beginner',
        progress: 0.80,
        lessonCount: 9,
        icon: Icons.play_circle,
        createdAt: DateTime.now(),
      ),
      GrammarTopic(
        id: '5',
        title: 'Prepositions of Place',
        description: 'Master in, on, at, under, and more.',
        level: 'Beginner',
        progress: 0.45,
        lessonCount: 15,
        icon: Icons.place,
        createdAt: DateTime.now(),
      ),
      GrammarTopic(
        id: '6',
        title: 'Modal Verbs',
        description: 'Learn can, could, may, might, must, should.',
        level: 'Intermediate',
        progress: 0.15,
        lessonCount: 14,
        icon: Icons.rule,
        createdAt: DateTime.now(),
      ),
    ];
  }
}