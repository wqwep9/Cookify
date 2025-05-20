import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
// import '../../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(245, 250, 246, 123),
      // appBar: AppBar(
      //   title: const Text(
      //     'Регистрация',
      //     style: TextStyle(color: Color.fromARGB(255, 24, 26, 98)),
      //   ),
      //   backgroundColor: const Color.fromARGB(245, 250, 246, 123),
      //   elevation: 0,
      //   iconTheme: const IconThemeData(color: Color.fromARGB(255, 24, 26, 98)),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 1.0),
              const Text(
                'Cookify',
                style: TextStyle(
                  fontSize: 80.0,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 24, 26, 98),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'Имя',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 24, 26, 98),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 24, 26, 98),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите имя';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _ageController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.none,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'Возраст',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 24, 26, 98),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 24, 26, 98),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите возраст';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age <= 0) {
                          return 'Пожалуйста, введите корректный возраст';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'Email',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 24, 26, 98),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 24, 26, 98),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.visiblePassword,
                      textCapitalization: TextCapitalization.none,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'Пароль',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 24, 26, 98),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 26, 98),
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 24, 26, 98),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите пароль';
                        }
                        if (value.length < 6) {
                          return 'Пароль должен содержать минимум 6 символов';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        return ElevatedButton(
                          onPressed: authService.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success = await authService.register(
                                      _nameController.text,
                                      int.parse(_ageController.text),
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                    if (success) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/main',
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Ошибка регистрации'),
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            backgroundColor:
                                const Color.fromRGBO(255, 164, 81, 1),
                            foregroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            minimumSize: const Size(double.infinity, 60),
                          ),
                          child: authService.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Зарегистрироваться',
                                  style: TextStyle(fontSize: 18.0)),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  'Войти',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Color.fromARGB(255, 24, 26, 98),
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              // const Text(
              //   'Cookify',
              //   style: TextStyle(
              //     fontSize: 18.0,
              //     fontWeight: FontWeight.bold,
              //     color: Color.fromARGB(255, 24, 26, 98),
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
