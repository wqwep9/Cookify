import 'package:http/http.dart' as http;
import 'dart:convert';
import 'translation_database_service.dart';
import '../models/translation.dart';

class TranslationService {
  static const String _baseUrl =
      'https://translate.googleapis.com/translate_a/single';
  static final TranslationDatabaseService _dbService =
      TranslationDatabaseService();

  // Метод для ручного добавления перевода
  static Future<void> addManualTranslation(
      String originalText, String translatedText) async {
    try {
      final translation = Translation(
        originalText: originalText,
        translatedText: translatedText,
        lastUpdated: DateTime.now(),
      );
      await _dbService.insertTranslation(translation);
    } catch (e) {
      print('Error adding manual translation: $e');
    }
  }

  // Метод для ручного добавления нескольких переводов
  static Future<void> addManualTranslations(
      Map<String, String> translations) async {
    try {
      for (var entry in translations.entries) {
        await addManualTranslation(entry.key, entry.value);
      }
    } catch (e) {
      print('Error adding manual translations: $e');
    }
  }

  static Future<String> translate(String text) async {
    try {
      // Проверяем наличие перевода в базе данных
      final cachedTranslation = await _dbService.getTranslation(text);
      if (cachedTranslation != null) {
        return cachedTranslation.translatedText;
      }

      // Если перевода нет в кэше, делаем запрос к API
      final response = await http.get(
        Uri.parse(
            '$_baseUrl?client=gtx&sl=auto&tl=ru&dt=t&q=${Uri.encodeComponent(text)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data[0] != null && data[0].isNotEmpty) {
          String translatedText = '';
          for (var part in data[0]) {
            if (part[0] != null) {
              translatedText += part[0];
            }
          }

          // Сохраняем перевод в базу данных
          final translation = Translation(
            originalText: text,
            translatedText: translatedText,
            lastUpdated: DateTime.now(),
          );
          await _dbService.insertTranslation(translation);

          return translatedText;
        }
      }
      return text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  static Future<List<String>> translateList(List<String> texts) async {
    try {
      final results = <String>[];
      for (var text in texts) {
        final translated = await translate(text);
        results.add(translated);
      }
      return results;
    } catch (e) {
      print('Translation error: $e');
      return texts;
    }
  }

  // Очистка старых переводов (старше 30 дней)
  static Future<void> cleanupOldTranslations() async {
    await _dbService.deleteOldTranslations();
  }

  // Очистка всех переводов
  static Future<void> clearAllTranslations() async {
    await _dbService.clearTranslations();
  }

  static Future<String> translateToEnglish(String text) async {
    // Здесь можно добавить ручные переводы для часто используемых кулинарных терминов
    final manualTranslations = {
      'курица': 'chicken',
      'говядина': 'beef',
      'рис': 'rice',
      'суп': 'soup',
      'салат': 'salad',
      // Добавьте другие часто используемые термины
    };

    // Проверяем, есть ли ручной перевод
    if (manualTranslations.containsKey(text.toLowerCase())) {
      return manualTranslations[text.toLowerCase()]!;
    }

    // Если ручного перевода нет, можно использовать API для перевода
    // Или просто вернуть оригинальный текст, если API не поддерживает русский-английский
    return text; // В реальном приложении здесь должен быть вызов API перевода
  }

  // static final _searchTranslations = {
  //   'курица': 'chicken',
  //   'говядина': 'beef',
  //   'рис': 'rice',
  //   'суп': 'soup',
  //   'салат': 'salad',
  //   // Добавьте другие частые запросы
  // };

  // static Future<String> translateQueryToEnglish(String query) async {
  //   // Сначала проверяем ручной словарь
  //   final lowerQuery = query.toLowerCase();
  //   if (_searchTranslations.containsKey(lowerQuery)) {
  //     return _searchTranslations[lowerQuery]!;
  //   }

  //   // Если нет в словаре, используем API переводчик (или оставляем как есть)
  //   return query; // В реальном приложении здесь должен быть вызов API перевода
  // }
}
