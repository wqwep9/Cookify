import 'package:flutter/foundation.dart';
import '../models/ingredient.dart';
import 'database_service.dart';

class CartService extends ChangeNotifier {
  List<Ingredient> _items = [];
  final DatabaseService _databaseService = DatabaseService();

  CartService() {
    _loadCart();
  }

  List<Ingredient> get items => _items;

  Future<void> _loadCart() async {
    _items = await _databaseService.getIngredients();
    notifyListeners();
  }

  Future<void> addItem(Map<String, dynamic> item) async {
    final ingredient = Ingredient(
      id: item['id'],
      name: item['name'],
      amount: item['amount'],
      unit: item['unit'],
      image: item['image'],
    );

    if (!_items.any((element) => element.id == ingredient.id)) {
      await _databaseService.insertIngredient(ingredient);
      _items.add(ingredient);
      notifyListeners();
    }
  }

  Future<void> removeItem(int itemId) async {
    await _databaseService.deleteIngredient(itemId);
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  Future<void> clearCart() async {
    await _databaseService.clearCart();
    _items.clear();
    notifyListeners();
  }
} 