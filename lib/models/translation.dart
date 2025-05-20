class Translation {
  final String originalText;
  final String translatedText;
  final DateTime lastUpdated;

  Translation({
    required this.originalText,
    required this.translatedText,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'original_text': originalText,
      'translated_text': translatedText,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(
      originalText: map['original_text'],
      translatedText: map['translated_text'],
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }
} 