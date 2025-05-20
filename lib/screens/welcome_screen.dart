import 'package:flutter/material.dart';
// import 'auth/login_screen.dart';
// import 'auth/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(245, 250, 246, 123),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80.0),
              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 24, 26, 98),
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Cookify',
                style: TextStyle(
                  fontSize: 70.0,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 24, 26, 98),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: const Color.fromRGBO(255, 164, 81, 1),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                ),
                child: const Text('Войти', style: TextStyle(fontSize: 18.0)),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: const Color.fromRGBO(255, 164, 81, 1),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Зарегистрироваться',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 48.0),
              const Text(
                'Cookify',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 24, 26, 98),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }
}
