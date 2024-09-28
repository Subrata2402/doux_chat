import 'dart:convert';

import 'package:doux_chat/screens/home_screen.dart';
import 'package:doux_chat/screens/otp_screen.dart';
import 'package:doux_chat/services/api_services.dart';
import 'package:doux_chat/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;
  bool showPassword = false;

  Future<void> login() async {
    final data = {
      'userName': usernameController.text,
      'password': passwordController.text,
    };
    final response = await AuthServices().login(data);
    if (!mounted) return;
    if (response['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', response['accessToken']);
      await prefs.setString('userData', jsonEncode(response['data']));
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      customSnackBar(context, response['message'], "success");
    } else {
      if (response['message'] == 'Email not verified') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(email: response['data']['email']),
          ),
        );
      }
      customSnackBar(context, response['message'], "error");
    }
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    if (!mounted) return;
    if (accessToken != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Doux Chat',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        // centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          height: 500,
          width: MediaQuery.of(context).size.width - 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                  child: Text("Login",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold))),
              const SizedBox(height: 30),
              const Text("Username",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your username",
                  suffixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Password",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Enter your password",
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      }, icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off)),
                ),
                obscureText: !showPassword,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                      }),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isChecked = !isChecked;
                      });
                    },
                    child: const Text("Remember me",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Forgot password?",
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                  child: const Text('Login',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?",
                      style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text("Sign up",
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
