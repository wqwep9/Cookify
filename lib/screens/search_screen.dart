import 'package:flutter/material.dart';
import '../api/recipe_service.dart';
import '../services/translation_service.dart';
import '../services/favorites_service.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;
  final List<String> _enteredIngredients = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchRecipes() async {
    if (_enteredIngredients.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // Объединяем все ингредиенты в одну строку через запятую
      final ingredientsString = _enteredIngredients.join(',');

      // Переводим ингредиенты на английский
      final translatedIngredients = await Future.wait(_enteredIngredients.map(
          (ingredient) =>
              TranslationService.translateToEnglish(ingredient.trim())));

      final translatedIngredientsString = translatedIngredients.join(',');

      final recipes = await RecipeService.searchByIngredients(
        ingredients: translatedIngredientsString,
        number: 10,
      );

      // Получаем полную информацию о рецептах
      final detailedRecipes = await Future.wait(
        recipes.map((recipe) async {
          final details = await RecipeService.getRecipeDetails(recipe['id']);
          return {
            ...recipe,
            ...details,
          };
        }),
      );

      // Переводим названия рецептов
      final translatedRecipes = await Future.wait(
        detailedRecipes.map((recipe) async {
          final translatedTitle =
              await TranslationService.translate(recipe['title']);
          final correctedTitle =
              await TranslationService.translate(translatedTitle);
          return {
            ...recipe,
            'title': correctedTitle,
          };
        }),
      );

      setState(() => _recipes = translatedRecipes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка поиска: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addIngredient() {
    final ingredient = _searchController.text.trim();
    if (ingredient.isNotEmpty && !_enteredIngredients.contains(ingredient)) {
      setState(() {
        _enteredIngredients.add(ingredient);
        _searchController.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _enteredIngredients.remove(ingredient);
    });
    if (_enteredIngredients.isNotEmpty) {
      _searchRecipes();
    } else {
      setState(() => _recipes = []);
    }
  }

  Future<void> _showRecipeDetails(int recipeId) async {
    setState(() => _isLoading = true);

    try {
      final recipeDetails = await RecipeService.getRecipeDetails(recipeId);
      final instructions =
          await RecipeService.getAnalyzedInstructions(recipeId);

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => RecipeDetailsDialog(
              recipe: recipeDetails,
              instructions: instructions,
              onIngredientSelected: (ingredient) {
                final cartService = context.read<CartService>();
                if (cartService.items
                    .any((item) => item.id == ingredient['id'])) {
                  cartService.removeItem(ingredient['id']);
                } else {
                  cartService.addItem(ingredient);
                }
              },
              selectedIngredients: context
                  .watch<CartService>()
                  .items
                  .map((item) => item.toMap())
                  .toList(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки деталей: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Поиск по ингредиентам',
          style: TextStyle(
            color: Color.fromARGB(255, 24, 26, 98),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'Добавить ингредиент',
                          hintStyle:
                              TextStyle(color: Colors.grey[400], fontSize: 18),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color.fromARGB(255, 24, 26, 98),
                        size: 32,
                      ),
                      onPressed: _addIngredient,
                    ),
                  ],
                ),
                if (_enteredIngredients.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _enteredIngredients.map((ingredient) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 164, 81, 1)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ingredient,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 24, 26, 98),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _removeIngredient(ingredient),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Color.fromARGB(255, 24, 26, 98),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _searchRecipes,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 164, 81, 1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Найти рецепты',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _isLoading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 24, 26, 98),
                      strokeWidth: 3,
                    ),
                  ),
                )
              : Expanded(
                  child: _recipes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _enteredIngredients.isEmpty
                                    ? 'Добавьте ингредиенты для поиска рецептов'
                                    : 'Нажмите "Найти рецепты"',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20.0),
                          itemCount: _recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = _recipes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                    ),
                                    child: Image.network(
                                      recipe['image'] ??
                                          'https://via.placeholder.com/150',
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.fastfood,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe['title'] ?? 'Название рецепта',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromARGB(255, 24, 26, 98),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}

class RecipeDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final List<Map<String, dynamic>> instructions;
  final Function(Map<String, dynamic>) onIngredientSelected;
  final List<Map<String, dynamic>> selectedIngredients;

  const RecipeDetailsDialog({
    super.key,
    required this.recipe,
    required this.instructions,
    required this.onIngredientSelected,
    required this.selectedIngredients,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.85,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recipe['title'] ?? 'Название рецепта',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Consumer<FavoritesService>(
                      builder: (context, favoritesService, child) {
                        final isFavorite =
                            favoritesService.isFavorite(recipe['id']);
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            if (isFavorite) {
                              favoritesService
                                  .removeFromFavorites(recipe['id']);
                            } else {
                              favoritesService.addToFavorites(recipe);
                            }
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                recipe['image'] ?? 'https://via.placeholder.com/150',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ингредиенты:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildIngredientsList(recipe['extendedIngredients']),
            const SizedBox(height: 24),
            const Text(
              'Инструкция по приготовлению:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildInstructionsList(instructions),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIngredientsList(List<dynamic>? ingredients) {
    if (ingredients == null || ingredients.isEmpty) {
      return [const Text('Нет информации об ингредиентах')];
    }

    return ingredients.map((ingredient) {
      final isSelected = selectedIngredients.any(
        (item) => item['id'] == ingredient['id'],
      );

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                final newIngredient = {
                  'id': ingredient['id'],
                  'name': ingredient['name'],
                  'amount': ingredient['amount'],
                  'unit': ingredient['unit'],
                  'image': ingredient['image'],
                };
                onIngredientSelected(newIngredient);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ingredient['amount']?.toStringAsFixed(1) ?? ''} '
                    '${ingredient['unit'] ?? ''} ${ingredient['name']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (ingredient['original'] != null)
                    Text(
                      ingredient['original'],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
            if (ingredient['image'] != null)
              Image.network(
                'https://spoonacular.com/cdn/ingredients_100x100/${ingredient['image']}',
                width: 40,
                height: 40,
              ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildInstructionsList(List<Map<String, dynamic>> instructions) {
    if (instructions.isEmpty) {
      return [const Text('Инструкция не найдена')];
    }

    final steps = instructions[0]['steps'] as List<dynamic>?;
    if (steps == null || steps.isEmpty) {
      return [const Text('Инструкция не найдена')];
    }

    return steps
        .map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Шаг ${step['number']}:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['step'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ))
        .toList();
  }
}
