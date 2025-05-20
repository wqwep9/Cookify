import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeService {
  static const String _baseUrl = 'https://api.spoonacular.com';
  static const String _apiKey = 'f7e07ef339c6405aa9f5c8d723ea06c0';

  // Поиск рецептов по категории
  static Future<List<Map<String, dynamic>>> searchByCategory({
    required String category,
    int number = 10,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/recipes/complexSearch?type=$category&number=$number&instructionsRequired=true&addRecipeInformation=true&apiKey=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results
          .map((recipe) => Map<String, dynamic>.from(recipe))
          .toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // Поиск рецептов по ингредиентам
  static Future<List<Map<String, dynamic>>> searchByIngredients({
    required String ingredients,
    int number = 10,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/recipes/findByIngredients?ingredients=$ingredients&number=$number&apiKey=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body);
      return results
          .map((recipe) => Map<String, dynamic>.from(recipe))
          .toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // Получение деталей рецепта по ID
  static Future<Map<String, dynamic>> getRecipeDetails(int id) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/recipes/$id/information?includeNutrition=false&apiKey=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }

  static Future<List<Map<String, dynamic>>> getAnalyzedInstructions(
      int id) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/recipes/$id/analyzedInstructions?apiKey=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body);
      return results
          .map((instruction) => Map<String, dynamic>.from(instruction))
          .toList();
    } else {
      throw Exception('Failed to load instructions');
    }
  }

  static Future<List<Map<String, dynamic>>> searchByCategory1({
    required String category,
    String query = '',
    required int number,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spoonacular.com/recipes/complexSearch?'
            'apiKey=f7e07ef339c6405aa9f5c8d723ea06c0'
            '&type=$category'
            '&number=$number'
            '${query.isNotEmpty ? '&query=$query' : ''}'
            '&addRecipeInformation=true'), // Добавлено для получения дополнительной информации
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception(
            'Failed to load recipes. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }
}
