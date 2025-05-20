// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/auth_service.dart';
// import 'register_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Вход'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
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
//                               final success = await authService.login(
//                                 _emailController.text,
//                                 _passwordController.text,
//                               );
//                               if (success) {
//                                 Navigator.pushReplacementNamed(context, '/home');
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Неверный email или пароль'),
//                                   ),
//                                 );
//                               }
//                             }
//                           },
//                     child: authService.isLoading
//                         ? const CircularProgressIndicator()
//                         : const Text('Войти'),
//                   );
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const RegisterScreen(),
//                     ),
//                   );
//                 },
//                 child: const Text('Зарегистрироваться'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
