import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../services/favorites_service.dart';
import '../api/recipe_service.dart';
import '../services/cart_service.dart';
import '../services/translation_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(
            color: Color.fromARGB(255, 24, 26, 98),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color.fromARGB(255, 24, 26, 98),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color.fromARGB(255, 24, 26, 98),
          tabs: const [
            Tab(
              icon: Icon(Icons.favorite, size: 30), // Увеличенная иконка
            ),
            Tab(
              icon: Icon(Icons.settings, size: 30), // Увеличенная иконка
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Вкладка "Избранные рецепты"
          _buildFavoritesTab(),

          // Вкладка "Настройки"
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<FavoritesService>(
      builder: (context, favoritesService, child) {
        final favorites = favoritesService.favorites;

        if (favorites.isEmpty) {
          return const Center(
            child: Text(
              'У вас пока нет избранных рецептов',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final recipe = favorites[index];
            return GestureDetector(
              onTap: () => _showRecipeDetails(context, recipe),
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        recipe['image'] ?? 'https://via.placeholder.com/150',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.fastfood, size: 50),
                        ),
                      ),
                    ),
                    ListTile(
                      title: FutureBuilder<String>(
                        future: _getFinalTranslation(
                            recipe['title'] ?? 'Название рецепта'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ??
                                recipe['title'] ??
                                'Название рецепта',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          size: 28,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          favoritesService.removeFromFavorites(recipe['id']);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showRecipeDetails(
      BuildContext context, Map<String, dynamic> recipe) async {
    try {
      final recipeDetails = await RecipeService.getRecipeDetails(recipe['id']);
      final instructions =
          await RecipeService.getAnalyzedInstructions(recipe['id']);

      if (context.mounted) {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки деталей: $e')),
        );
      }
    }
  }

  Widget _buildSettingsTab() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;

        if (user == null) {
          return const Center(
            child: Text(
              'Пользователь не авторизован',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromRGBO(255, 164, 81, 1),
                        width: 3,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundColor: Color.fromARGB(255, 230, 230, 230),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Color.fromARGB(255, 24, 26, 98),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 24, 26, 98),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                            Icons.cake, 'Возраст', user.age.toString()),
                        Divider(height: 1, color: Colors.grey[200]),
                        _buildInfoRow(Icons.email, 'Email', user.email),
                        Divider(height: 1, color: Colors.grey[200]),
                        _buildInfoRow(Icons.lock, 'Пароль', '••••••••'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditProfileDialog(
                      initialName: user.name,
                      initialAge: user.age,
                      initialEmail: user.email,
                      onSave: (name, age, email) async {
                        try {
                          await authService.updateProfile(
                            name: name,
                            age: age,
                            email: email,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Профиль успешно обновлен'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ошибка обновления профиля: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(255, 164, 81, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Редактировать профиль',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ChangePasswordDialog(
                      onSave: (newPassword) async {
                        try {
                          await authService.updatePassword(newPassword);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Пароль успешно изменен'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ошибка изменения пароля: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(255, 164, 81, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Изменить пароль',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  authService.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(255, 164, 81, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout,
                      size: 24,
                      color: Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Выйти',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 164, 81, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color.fromRGBO(255, 164, 81, 1),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 24, 26, 98),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getFinalTranslation(String text) async {
    final firstTranslation = await TranslationService.translate(text);
    final finalTranslation =
        await TranslationService.translate(firstTranslation);
    return finalTranslation;
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
    final firstTranslation = await TranslationService.translate(text);
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

class EditProfileDialog extends StatefulWidget {
  final String initialName;
  final int initialAge;
  final String initialEmail;
  final Function(String name, int age, String email) onSave;

  const EditProfileDialog({
    super.key,
    required this.initialName,
    required this.initialAge,
    required this.initialEmail,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _ageController = TextEditingController(text: widget.initialAge.toString());
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать профиль'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Возраст',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final age = int.tryParse(_ageController.text.trim()) ?? 0;
            final email = _emailController.text.trim();

            if (name.isEmpty || age <= 0 || email.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Пожалуйста, заполните все поля корректно'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            widget.onSave(name, age, email);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(255, 164, 81, 1),
          ),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  final Function(String) onSave;

  const ChangePasswordDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Изменить пароль'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Текущий пароль',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureCurrentPassword,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'Новый пароль',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureNewPassword,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Подтвердите новый пароль',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            final currentPassword = _currentPasswordController.text.trim();
            final newPassword = _newPasswordController.text.trim();
            final confirmPassword = _confirmPasswordController.text.trim();

            if (currentPassword.isEmpty ||
                newPassword.isEmpty ||
                confirmPassword.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Пожалуйста, заполните все поля'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (newPassword != confirmPassword) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Новые пароли не совпадают'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (newPassword.length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Пароль должен содержать минимум 6 символов'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            widget.onSave(newPassword);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(255, 164, 81, 1),
          ),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
