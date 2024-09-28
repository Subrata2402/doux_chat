import 'package:doux_chat/screens/otp_screen.dart';
import 'package:doux_chat/services/api_services.dart';
import 'package:doux_chat/services/helper.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isChecked = false;
  bool showPassword = false;

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      customSnackBar(context, "Password doesn't match", "warning");
      return;
    }
    final data = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'userName': usernameController.text,
      'email': emailController.text,
      'password': passwordController.text,
    };
    final response = await AuthServices().register(data);
    if (!mounted) return;
    if (response['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(email: emailController.text),
        ),
      );
      customSnackBar(context, response['message'], "success");
    } else {
      customSnackBar(context, response['message'], "error");
    }
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
        automaticallyImplyLeading: false,
        // centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 825,
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
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                  child: Text("Register",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold))),
              const SizedBox(height: 30),
              _buildInputField("First Name", firstNameController, Icons.person,
                  "Enter your first name"),
              const SizedBox(height: 16),
              _buildInputField("Last Name", lastNameController, Icons.person,
                  "Enter your last name"),
              const SizedBox(height: 16),
              _buildInputField("Username", usernameController, Icons.person,
                  "Enter your username"),
              const SizedBox(height: 16),
              _buildInputField("Email", emailController,
                  Icons.mail_outline_rounded, "Enter your email"),
              const SizedBox(height: 16),
              // _buildInputField("Password", passwordController, Icons.visibility,
              //     "Enter your password",
              //     obscureText: !showPassword),
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
                    },
                    icon: Icon(showPassword
                        ? Icons.visibility
                        : Icons.visibility_off_rounded),
                  ),
                ),
                obscureText: !showPassword,
              ),
              const SizedBox(height: 16),
              // _buildInputField("Confirm Password", confirmPasswordController,
              //     Icons.visibility, "Confirm your password",
              //     obscureText: true),
              const Text("Confirm Password",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Enter your password",
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(showPassword
                        ? Icons.visibility
                        : Icons.visibility_off_rounded),
                  ),
                ),
                obscureText: !showPassword,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // sendVerificationCode();
                    register();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                  child: const Text('Register',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?",
                      style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Login",
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

  Widget _buildInputField(String label, TextEditingController controller,
      IconData icon, String hintText,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hintText,
            suffixIcon: Icon(icon),
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
