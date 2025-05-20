import 'package:flutter/foundation.dart';

class FavoritesService with ChangeNotifier {
  final List<Map<String, dynamic>> _favoriteRecipes = [];

  List<Map<String, dynamic>> get favorites => _favoriteRecipes;

  bool isFavorite(int recipeId) {
    return _favoriteRecipes.any((recipe) => recipe['id'] == recipeId);
  }

  void addToFavorites(Map<String, dynamic> recipe) {
    if (!isFavorite(recipe['id'])) {
      _favoriteRecipes.add(recipe);
      notifyListeners();
    }
  }

  void removeFromFavorites(int recipeId) {
    _favoriteRecipes.removeWhere((recipe) => recipe['id'] == recipeId);
    notifyListeners();
  }
}
