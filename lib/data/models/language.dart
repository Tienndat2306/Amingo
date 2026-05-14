class Language {
  final String name;
  final String nativeName;
  final String flagEmoji;
  final String countryCode;
  final String code;

  const Language({
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
    required this.countryCode,
    this.code = 'en',
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'] ?? '',
      nativeName: json['nativeName'] ?? '',
      flagEmoji: json['flagEmoji'] ?? '🇺🇸',
      countryCode: json['countryCode'] ?? 'US',
      code: json['code'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nativeName': nativeName,
      'flagEmoji': flagEmoji,
      'countryCode': countryCode,
      'code': code,
    };
  }

  static const List<Language> availableLanguages = [
    Language(
      name: 'English',
      nativeName: 'English',
      flagEmoji: '🇺🇸',
      countryCode: 'US',
      code: 'en',
    ),
    Language(
      name: 'Spanish',
      nativeName: 'Español',
      flagEmoji: '🇪🇸',
      countryCode: 'ES',
      code: 'es',
    ),
    Language(
      name: 'French',
      nativeName: 'Français',
      flagEmoji: '🇫🇷',
      countryCode: 'FR',
      code: 'fr',
    ),
    Language(
      name: 'German',
      nativeName: 'Deutsch',
      flagEmoji: '🇩🇪',
      countryCode: 'DE',
      code: 'de',
    ),
    Language(
      name: 'Japanese',
      nativeName: '日本語',
      flagEmoji: '🇯🇵',
      countryCode: 'JP',
      code: 'ja',
    ),
    Language(
      name: 'Korean',
      nativeName: '한국어',
      flagEmoji: '🇰🇷',
      countryCode: 'KR',
      code: 'ko',
    ),
  ];
}