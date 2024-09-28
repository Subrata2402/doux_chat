import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:doux_chat/screens/home_screen.dart';
import 'package:doux_chat/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('accessToken');
    if (userData != null) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Lottie.asset("assets/animation/Animation - 1726403916430.json"),
      nextScreen: isLoggedIn ? const HomeScreen() : const Login(),
      splashTransition: SplashTransition.fadeTransition,
      duration: 3000,
      animationDuration: const Duration(milliseconds: 1000),
      backgroundColor: Colors.deepPurple,
      splashIconSize: double.infinity,
      curve: Curves.easeInOut,
    );
  }
}