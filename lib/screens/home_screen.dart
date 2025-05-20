import 'package:flutter/material.dart';
import 'package:cookify/screens/auth/recipes_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  List<Map<String, dynamic>> _selectedIngredients = [];

  void _onIngredientsChanged(List<Map<String, dynamic>> ingredients) {
    setState(() {
      _selectedIngredients = ingredients;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      RecipesScreen(onIngredientsChanged: _onIngredientsChanged),
      const SearchScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: _screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Рецепты',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
