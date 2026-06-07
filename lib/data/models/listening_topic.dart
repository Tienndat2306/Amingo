class ListeningTopic {
  final String id;
  final String title;
  final String description;
  final int order;

  const ListeningTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
  });

  factory ListeningTopic.fromJson(Map<String, dynamic> json, String id) {
    return ListeningTopic(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'order': order,
      };
}