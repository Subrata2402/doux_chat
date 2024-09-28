import 'package:doux_chat/screens/home_screen.dart';
import 'package:doux_chat/screens/login.dart';
import 'package:doux_chat/screens/register.dart';
import 'package:doux_chat/screens/splash_screen.dart';
import 'package:doux_chat/services/socket_service.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SocketService().connect();
    return MaterialApp(
      title: 'Doux Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const Login(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}