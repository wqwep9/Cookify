// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/auth_service.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _ageController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _ageController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Регистрация'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Имя',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Пожалуйста, введите имя';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _ageController,
//                 decoration: const InputDecoration(
//                   labelText: 'Возраст',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Пожалуйста, введите возраст';
//                   }
//                   final age = int.tryParse(value);
//                   if (age == null || age <= 0) {
//                     return 'Пожалуйста, введите корректный возраст';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Пожалуйста, введите email';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   labelText: 'Пароль',
//                   border: OutlineInputBorder(),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Пожалуйста, введите пароль';
//                   }
//                   if (value.length < 6) {
//                     return 'Пароль должен содержать минимум 6 символов';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//               Consumer<AuthService>(
//                 builder: (context, authService, child) {
//                   return ElevatedButton(
//                     onPressed: authService.isLoading
//                         ? null
//                         : () async {
//                             if (_formKey.currentState!.validate()) {
//                               final success = await authService.register(
//                                 _nameController.text,
//                                 int.parse(_ageController.text),
//                                 _emailController.text,
//                                 _passwordController.text,
//                               );
//                               if (success) {
//                                 Navigator.pushReplacementNamed(context, '/home');
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Ошибка регистрации'),
//                                   ),
//                                 );
//                               }
//                             }
//                           },
//                     child: authService.isLoading
//                         ? const CircularProgressIndicator()
//                         : const Text('Зарегистрироваться'),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
