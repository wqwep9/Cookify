import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/translation.dart';

class TranslationDatabaseService {
  static final TranslationDatabaseService _instance = TranslationDatabaseService._internal();
  static Database? _database;

  factory TranslationDatabaseService() => _instance;

  TranslationDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'translations.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE translations(
        original_text TEXT PRIMARY KEY,
        translated_text TEXT NOT NULL,
        last_updated TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertTranslation(Translation translation) async {
    final db = await database;
    await db.insert(
      'translations',
      translation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Translation?> getTranslation(String originalText) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      where: 'original_text = ?',
      whereArgs: [originalText],
    );

    if (maps.isEmpty) return null;
    return Translation.fromMap(maps.first);
  }

  Future<void> deleteOldTranslations() async {
    final db = await database;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    await db.delete(
      'translations',
      where: 'last_updated < ?',
      whereArgs: [thirtyDaysAgo.toIso8601String()],
    );
  }

  Future<void> clearTranslations() async {
    final db = await database;
    await db.delete('translations');
  }
} 