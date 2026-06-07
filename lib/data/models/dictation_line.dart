class DictationLine {
  final String id;
  final int index;
  final String correctText;
  final String audioUrl;

  const DictationLine({
    required this.id,
    required this.index,
    required this.correctText,
    required this.audioUrl,
  });

  factory DictationLine.fromJson(Map<String, dynamic> json, String id) {
    return DictationLine(
      id: id,
      index: (json['index'] is num) ? (json['index'] as num).toInt() : 0,
      correctText: json['correctText'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'correctText': correctText,
        'audioUrl': audioUrl,
      };
}