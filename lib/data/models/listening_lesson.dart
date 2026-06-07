class ListeningLesson {
  final String id;
  final String title;
  final int order;
  final int totalParts;
  final String vocabLevel;

  const ListeningLesson({
    required this.id,
    required this.title,
    required this.order,
    required this.totalParts,
    required this.vocabLevel,
  });

  factory ListeningLesson.fromFirestore(Map<String, dynamic> json, String id) {
    return ListeningLesson(
      id: id,
      title: json['title'] ?? '',
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
      totalParts: (json['totalParts'] is num) ? (json['totalParts'] as num).toInt() : 0,
      vocabLevel: json['vocabLevel'] ?? 'A1',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'order': order,
        'totalParts': totalParts,
        'vocabLevel': vocabLevel,
      };
}