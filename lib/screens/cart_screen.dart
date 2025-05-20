import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/translation_service.dart';
import '../models/ingredient.dart'; // Или правильный путь к вашему файлу с моделью

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Корзина',
          style: TextStyle(
            color: Color.fromARGB(255, 24, 26, 98),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          final items = cartService.items;

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Корзина пуста',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 24, 26, 98),
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return FutureBuilder<Map<String, String>>(
                      future: _getTranslations(item),
                      builder: (context, snapshot) {
                        final translatedName =
                            snapshot.data?['name'] ?? item.name;
                        final translatedUnit =
                            snapshot.data?['unit'] ?? item.unit;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            leading: item.image != null
                                ? Image.network(
                                    'https://spoonacular.com/cdn/ingredients_100x100/${item.image}',
                                    width: 40,
                                    height: 40,
                                  )
                                : const Icon(Icons.fastfood),
                            title: Text(
                              '${item.amount.toStringAsFixed(1)} $translatedUnit $translatedName',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 24, 26, 98),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color.fromRGBO(255, 164, 81, 1),
                              ),
                              onPressed: () {
                                cartService.removeItem(item.id);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Очистить корзину'),
                          content: const Text(
                              'Вы уверены, что хотите очистить корзину?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () {
                                cartService.clearCart();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Очистить',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(255, 164, 81, 1),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Очистить корзину',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, String>> _getTranslations(Ingredient item) async {
    // Создаем словарь для хранения переводов
    final translations = <String, String>{};

    try {
      // Переводим название ингредиента
      translations['name'] = await TranslationService.translate(item.name);

      // Переводим единицу измерения, если она есть
      if (item.unit.isNotEmpty) {
        translations['unit'] = await _translateUnit(item.unit);
      }
    } catch (e) {
      print('Ошибка перевода: $e');
    }

    return translations;
  }

  Future<String> _translateUnit(String unit) async {
    // Словарь для перевода распространенных единиц измерения
    const unitTranslations = {
      'cup': 'стакан',
      'cups': 'стакана',
      'tablespoon': 'ст. ложка',
      'tablespoons': 'ст. ложки',
      'teaspoon': 'ч. ложка',
      'teaspoons': 'ч. ложки',
      'ounce': 'унция',
      'ounces': 'унции',
      'gram': 'грамм',
      'grams': 'грамма',
      'kilogram': 'килограмм',
      'kilograms': 'килограмма',
      'liter': 'литр',
      'liters': 'литра',
      'milliliter': 'миллилитр',
      'milliliters': 'миллилитра',
      'piece': 'шт.',
      'pieces': 'шт.',
      'pinch': 'щепотка',
      'pinches': 'щепотки',
      'slice': 'ломтик',
      'slices': 'ломтика',
      'clove': 'зубчик',
      'cloves': 'зубчика',
      'bunch': 'пучок',
      'bunches': 'пучка',
      'can': 'банка',
      'cans': 'банки',
      'package': 'упаковка',
      'packages': 'упаковки',
      'bag': 'пакет',
      'bags': 'пакета',
      'bottle': 'бутылка',
      'bottles': 'бутылки',
      'jar': 'баночка',
      'jars': 'баночки',
    };

    // Приводим к нижнему регистру для сравнения
    final lowerUnit = unit.toLowerCase();

    // Если есть ручной перевод - возвращаем его
    if (unitTranslations.containsKey(lowerUnit)) {
      return unitTranslations[lowerUnit]!;
    }

    // Если нет ручного перевода - пытаемся перевести через сервис
    return await TranslationService.translate(unit);
  }
}
