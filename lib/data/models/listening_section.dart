class ListeningSection {
  final String id;
  final String title;
  final int order;

  const ListeningSection({
    required this.id,
    required this.title,
    required this.order,
  });

  factory ListeningSection.fromJson(Map<String, dynamic> json, String id) {
    return ListeningSection(
      id: id,
      title: json['title'] ?? '',
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'order': order,
      };
}