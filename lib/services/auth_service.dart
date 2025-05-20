import 'package:flutter/material.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final isValid = await _databaseService.validateUser(email, password);
      if (isValid) {
        _currentUser = await _databaseService.getUserByEmail(email);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, int age, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = User(
        name: name,
        age: age,
        email: email,
        password: password,
      );
      await _databaseService.insertUser(user);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required int age,
    required String email,
  }) async {
    final userId = currentUser?.id;

    if (userId == null) {
      throw Exception('Пользователь не авторизован');
    }

    await _databaseService.updateUser(
      userId: userId,
      name: name,
      age: age,
      email: email,
    );

    // Обновляем текущего пользователя
    _currentUser = User(
      id: userId,
      name: name,
      age: age,
      email: email,
      password: currentUser!.password, // Сохраняем текущий пароль
    );

    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    final userId = currentUser?.id;

    if (userId == null) {
      throw Exception('Пользователь не авторизован');
    }

    await _databaseService.updateUserPassword(
      userId: userId,
      newPassword: newPassword,
    );

    // Обновляем текущего пользователя
    _currentUser = User(
      id: userId,
      name: currentUser!.name,
      age: currentUser!.age,
      email: currentUser!.email,
      password: newPassword,
    );

    notifyListeners();
  }
} 