import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../../api/recipe_service.dart';
import '../../services/translation_service.dart';
import '../../services/favorites_service.dart';

class RecipesScreen extends StatefulWidget {
  final Function(List<Map<String, dynamic>>)? onIngredientsChanged;

  const RecipesScreen({super.key, this.onIngredientsChanged});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  int _selectedCategoryIndex = 0;
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _selectedIngredients = [];

  final Map<String, String> _categoryQueries = {
    'Завтрак': 'breakfast',
    'Обед': 'lunch',
    'Ужин': 'side dish',
    'Закуски': 'snack',
    'Супы': 'soup',
    'Салаты': 'salad',
    'Десерты': 'dessert',
  };

  final List<String> categories = [
    'Завтрак',
    'Обед',
    'Ужин',
    'Закуски',
    'Супы',
    'Салаты',
    'Десерты',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      // Очищаем все переводы
      await TranslationService.clearAllTranslations();

      // Добавляем ручные переводы (как с английского на русский, так и корректировки русских)
      final translations = {
        'Powerhouse Almond Matcha Superfood Smoothie':
            'Миндальный смузи с матчей',
        'Баттернат Сквош Фриттата': 'Фритатта из тыквы с орехами',
        'Фритатта из тыквы с орехами':
            'Фритатта из тыквы с орехами', // Корректировка русского
        'Арахисовое масло и смузи желе': 'Бананово-клубничный смузи с арахисом',
        'Медленная туманная говядина': 'Тушеная говядина',
        'Тушеная говядина': 'Говядина тушеная', // Корректировка русского
        'Гарлики Кале': 'Кейл с чесноком',
        'Цветная капуста, коричневый рис и жареный растиный рис':
            'Коричневый рис с цветной капустой и брокколи',
        'Брокколини ФИФАФ': 'Брокколини с киноа',
        'Легко сделать весенние рулоны': 'Спринг-роллы',
        'Кукуруза авокадо сальса': 'Сальса с авокадо и кукурузой',
        'Острый черноглазый гороховый карри со швейцарским мангольдом и жареным баклажаном':
            'Острый гороховый карри с баклажаном',
        'Травоядные "белая фасоль и капуста суп': 'Суп из белой фасоли',
        'Шпинатный салат с клубничным винегретом': 'Салат с курицей и шпинатом',
        'Салат из морковки и капусты с кориандром+тмин сухой рулет':
            'Салат из моркови',
        'Green Monster Ice Pops': 'Мороженое с манго и бананом',
        'Торт с арахисовым арахисом карамель': 'Торт с арахисом и карамелью',
        'Cacao Chia Pudding с авокадо мусс': 'Чиа-пудинг с какао и авокадо',
        'Шоколадный пудинг - восторженная диета': 'Шоколадный пудинг',
        'FING FOODS: кексы Frittata': 'Яичные кексы-фриттата',
        'Спаржа и гороховый суп: настоящая удобная еда':
            'Гороховый суп со спаржой',
        'Клубничный салат из квиноа': 'Легкий салат и киноа',
        'Салат из квиноа и нута с высушенными на солнце помидорами и сушеными вишнями':
            'Салат из киноа и нута с помидорами',
      };

      for (var entry in translations.entries) {
        await TranslationService.addManualTranslation(entry.key, entry.value);
      }

      print('Manual translations initialized successfully');
      await _loadRecipes(categories[_selectedCategoryIndex]);
    } catch (e) {
      print('Error initializing data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка инициализации: $e')),
        );
      }
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      _loadRecipes(categories[_selectedCategoryIndex]);
    }
  }

  Future<void> _loadRecipes(String category, {String query = ''}) async {
    setState(() {
      _isLoading = true;
      _recipes = [];
    });

    //   try {
    //     final categoryQuery = _categoryQueries[category] ?? '';
    //     final recipes = await RecipeService.searchByCategory(
    //       category: categoryQuery,
    //       number: 5,
    //     );

    //     final translatedRecipes = await Future.wait(
    //       recipes.map((recipe) async {
    //         // Сначала пробуем получить ручной перевод
    //         final translatedTitle =
    //             await TranslationService.translate(recipe['title']);
    //         // Затем дополнительно проверяем, не нужна ли коррекция русского перевода
    //         final correctedTitle =
    //             await TranslationService.translate(translatedTitle);
    //         return {
    //           ...recipe,
    //           'title':
    //               correctedTitle, // Используем окончательный вариант перевода
    //         };
    //       }),
    //     );

    //     if (mounted) {
    //       setState(() {
    //         _recipes = translatedRecipes;
    //       });
    //     }
    //   } catch (e) {
    //     if (mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text('Ошибка загрузки: $e')),
    //       );
    //     }
    //   } finally {
    //     if (mounted) {
    //       setState(() => _isLoading = false);
    //     }
    //   }
    // }
    try {
      final categoryQuery = _categoryQueries[category] ?? '';
      String translatedQuery = query;

      // Если запрос не пустой и содержит русские буквы, переводим его на английский
      if (query.isNotEmpty && query.contains(RegExp(r'[а-яА-Я]'))) {
        translatedQuery = await TranslationService.translateToEnglish(query);
      }

      final recipes = await RecipeService.searchByCategory1(
        category: categoryQuery,
        query: translatedQuery,
        number: 5,
      );

      final translatedRecipes = await Future.wait(
        recipes.map((recipe) async {
          // Сначала пробуем получить ручной перевод
          final translatedTitle =
              await TranslationService.translate(recipe['title']);
          // Затем дополнительно проверяем, не нужна ли коррекция русского перевода
          final correctedTitle =
              await TranslationService.translate(translatedTitle);
          return {
            ...recipe,
            'title':
                correctedTitle, // Используем окончательный вариант перевода
          };
        }),
      );

      if (mounted) {
        setState(() {
          _recipes = translatedRecipes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки деталей: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Рецепты',
          style: TextStyle(
            color: Color.fromARGB(255, 24, 26, 98),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: true,
        elevation: 0,
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(40),
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 250.0, vertical: 1),
        //     child: TextField(
        //       // controller: _searchController,
        //       // textInputAction: TextInputAction.search,
        //       // keyboardType: TextInputType.text,
        //       // textCapitalization: TextCapitalization.sentences,
        //       // decoration: InputDecoration(
        //       //   hintText: 'Поиск рецептов...',
        //       //   prefixIcon: const Icon(
        //       //     Icons.search,
        //       //     color: Color.fromARGB(255, 24, 26, 98),
        //       //   ),
        //       //   border: OutlineInputBorder(
        //       //     borderRadius: BorderRadius.circular(30),
        //       //     borderSide: const BorderSide(
        //       //       color: Color.fromARGB(255, 24, 26, 98),
        //       //       width: 2.0,
        //       //     ),
        //       //  ),
        //       // enabledBorder: OutlineInputBorder(
        //       //   borderRadius: BorderRadius.circular(30),
        //       //   borderSide: const BorderSide(
        //       //     color: Color.fromARGB(255, 24, 26, 98),
        //       //     width: 2.0,
        //       //   ),
        //       // ),
        //       // focusedBorder: OutlineInputBorder(
        //       //   borderRadius: BorderRadius.circular(30),
        //       //   borderSide: const BorderSide(
        //       //     color: Color.fromARGB(255, 24, 26, 98),
        //       //     width: 2.0,
        //       //   ),
        //       // ),
        //       //   contentPadding: const EdgeInsets.symmetric(vertical: 12),
        //       // ),
        //       onSubmitted: (value) {
        //         _loadRecipes(categories[_selectedCategoryIndex], query: value);
        //       },
        //     ),
        //   ),
        // ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(categories[index]),
                    selected: _selectedCategoryIndex == index,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategoryIndex = index;
                        _loadRecipes(
                          categories[index],
                          query: _searchController.text,
                        );
                      });
                    },
                    selectedColor: const Color.fromARGB(245, 250, 246, 123),
                    labelStyle: TextStyle(
                      color: _selectedCategoryIndex == index
                          ? const Color.fromARGB(255, 24, 26, 98)
                          : const Color.fromARGB(255, 24, 26, 98),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                  ),
                );
              },
            ),
          ),
          _isLoading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 24, 26, 98),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      return GestureDetector(
                        onTap: () => _showRecipeDetails(recipe['id']),
                        child: _buildRecipeCard(recipe),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

Widget _buildRecipeCard(Map<String, dynamic> recipe) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
          child: Image.network(
            recipe['image'] ?? 'https://via.placeholder.com/150',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 150,
              color: Colors.grey[300],
              child: const Icon(Icons.fastfood, size: 50, color: Colors.grey),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe['title'] ?? 'Название рецепта',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 24, 26, 98),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    ),
  );
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
                  child: FutureBuilder<String>(
                    future: _getFinalTranslation(
                        recipe['title'] ?? 'Название рецепта'),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? recipe['title'] ?? 'Название рецепта',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
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

  Future<String> _getFinalTranslation(String text) async {
    // Получаем первый перевод
    final firstTranslation = await TranslationService.translate(text);
    // Проверяем, не нужна ли коррекция для русского текста
    final finalTranslation =
        await TranslationService.translate(firstTranslation);
    return finalTranslation;
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
                  FutureBuilder<String>(
                    future: _getFinalTranslation(
                        '${ingredient['amount']?.toStringAsFixed(1) ?? ''} '
                        '${ingredient['unit'] ?? ''} ${ingredient['name']}'),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ??
                            '${ingredient['amount']?.toStringAsFixed(1) ?? ''} '
                                '${ingredient['unit'] ?? ''} ${ingredient['name']}',
                        style: const TextStyle(fontSize: 16),
                      );
                    },
                  ),
                  if (ingredient['original'] != null)
                    FutureBuilder<String>(
                      future: _getFinalTranslation(ingredient['original']),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? ingredient['original'],
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        );
                      },
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
                  FutureBuilder<String>(
                    future: _getFinalTranslation(step['step']),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? step['step'],
                        style: const TextStyle(fontSize: 16),
                      );
                    },
                  ),
                ],
              ),
            ))
        .toList();
  }
}
