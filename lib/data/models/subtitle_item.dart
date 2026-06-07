class SubtitleItem {
  final String content;
  final String vi;
  final double start;
  final double end;

  const SubtitleItem({
    required this.content,
    required this.vi,
    required this.start,
    required this.end,
  });

  factory SubtitleItem.fromFirestore(Map<String, dynamic> json) {
    return SubtitleItem(
      content: json['content']?.toString() ?? '',
      vi: json['vi']?.toString() ?? '',
      start: _parseDouble(json['start']),
      end: _parseDouble(json['end']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}