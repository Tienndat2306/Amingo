import '../models/video_lesson.dart';

class MockVideoData {
  static List<VideoLesson> getMockVideoLessons() {
    return [
      VideoLesson(
        id: '1',
        title: 'Introduction to English',
        description: 'Learn the basics of English language',
        duration: '15:30',
        views: '12.5K',
        thumbnail: 'https://picsum.photos/400/200?random=1',
        level: 'Beginner',
        isFeatured: true,
        createdAt: DateTime.now(),
      ),
      VideoLesson(
        id: '2',
        title: 'Common Phrases for Travel',
        description: 'Essential phrases for your next trip',
        duration: '22:15',
        views: '8.2K',
        thumbnail: 'https://picsum.photos/400/200?random=2',
        level: 'Beginner',
        isFeatured: false,
        createdAt: DateTime.now(),
      ),
      VideoLesson(
        id: '3',
        title: 'Business English Conversation',
        description: 'Master professional communication',
        duration: '28:45',
        views: '5.1K',
        thumbnail: 'https://picsum.photos/400/200?random=3',
        level: 'Intermediate',
        isFeatured: false,
        createdAt: DateTime.now(),
      ),
      VideoLesson(
        id: '4',
        title: 'Advanced Grammar Tips',
        description: 'Take your English to the next level',
        duration: '35:20',
        views: '3.8K',
        thumbnail: 'https://picsum.photos/400/200?random=4',
        level: 'Advanced',
        isFeatured: false,
        createdAt: DateTime.now(),
      ),
    ];
  }
}