import 'package:cookbook_app/screens/welcome_page.dart';
import 'package:cookbook_app/screens/auth/login_page.dart';
import 'package:cookbook_app/screens/auth/register_page.dart';
import 'package:cookbook_app/screens/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFFEF3A16),
      ),
      home: const MainScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
