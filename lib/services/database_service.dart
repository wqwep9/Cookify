import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/ingredient.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cookify.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Проверяем существование таблиц
        final tables = await db.query(
          'sqlite_master',
          where: 'type = ? AND name IN (?, ?)',
          whereArgs: ['table', 'users', 'ingredients'],
        );

        if (tables.length < 2) {
          // Если какой-то таблицы нет, создаем её
          if (!tables.any((t) => t['name'] == 'users')) {
            await db.execute('''
              CREATE TABLE users(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                age INTEGER NOT NULL,
                email TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL
              )
            ''');
          }
          if (!tables.any((t) => t['name'] == 'ingredients')) {
            await db.execute('''
              CREATE TABLE ingredients(
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                amount REAL NOT NULL,
                unit TEXT NOT NULL,
                image TEXT
              )
            ''');
          }
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE ingredients(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        unit TEXT NOT NULL,
        image TEXT
      )
    ''');
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<bool> validateUser(String email, String password) async {
    final user = await getUserByEmail(email);
    return user != null && user.password == password;
  }

  Future<void> insertIngredient(Ingredient ingredient) async {
    final db = await database;
    await db.insert(
      'ingredients',
      ingredient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Ingredient>> getIngredients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ingredients');
    return List.generate(maps.length, (i) => Ingredient.fromMap(maps[i]));
  }

  Future<void> deleteIngredient(int id) async {
    final db = await database;
    await db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('ingredients');
  }

  Future<void> updateUser({
    required int userId,
    required String name,
    required int age,
    required String email,
  }) async {
    final db = await database;
    await db.update(
      'users',
      {
        'name': name,
        'age': age,
        'email': email,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateUserPassword({
    required int userId,
    required String newPassword,
  }) async {
    final db = await database;
    await db.update(
      'users',
      {
        'password': newPassword,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
} 