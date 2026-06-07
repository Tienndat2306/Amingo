String? extractYoutubeVideoId(String urlOrId) {
  final value = urlOrId.trim();
  if (value.isEmpty) return null;

  final plainIdPattern = RegExp(r'^[a-zA-Z0-9_-]{11}$');
  if (plainIdPattern.hasMatch(value)) return value;

  final uri = Uri.tryParse(value);
  if (uri == null) return null;

  final host = uri.host.toLowerCase();
  if (host.contains('youtube.com')) {
    final watchId = uri.queryParameters['v'];
    if (watchId != null && plainIdPattern.hasMatch(watchId)) return watchId;

    final segments = uri.pathSegments;
    if (segments.length >= 2 &&
        ['embed', 'shorts', 'live'].contains(segments.first) &&
        plainIdPattern.hasMatch(segments[1])) {
      return segments[1];
    }
  }

  if (host == 'youtu.be' || host.endsWith('.youtu.be')) {
    final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    if (id != null && plainIdPattern.hasMatch(id)) return id;
  }

  return null;
}

String resolveVideoThumbnail({
  required String videoUrl,
  String? thumbnailUrl,
}) {
  final customThumbnail = thumbnailUrl?.trim() ?? '';
  final thumbnailVideoId = extractYoutubeVideoId(customThumbnail);

  if (thumbnailVideoId != null) {
    return youtubeThumbnailUrl(thumbnailVideoId);
  }

  if (customThumbnail.isNotEmpty) return customThumbnail;

  final videoId = extractYoutubeVideoId(videoUrl);
  return videoId == null ? '' : youtubeThumbnailUrl(videoId);
}

String youtubeThumbnailUrl(String videoId) {
  return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}
