import 'package:doux_chat/screens/login.dart';
import 'package:doux_chat/services/api_services.dart';
import 'package:doux_chat/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isDisabled = true;

  Future<void> verifyEmail() async {
    final data = {
      'email': widget.email,
      'otp': otpController.text,
    };
    final response = await AuthServices().verifyEmail(data);
    if (!mounted) return;
    if (response['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
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
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(left: 25, right: 25),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/otppageimage.svg', height: 300),
                const SizedBox(height: 16),
                const Text(
                  'Verification',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter the verification code sent to your email',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Pinput(
                  length: 6,
                  onChanged: (value) => setState(() {
                    isDisabled = value.length != 6;
                  }),
                  controller: otpController,
                  cursor: Container(
                    width: 3,
                    height: 20,
                    color: Colors.purple,
                  ),
                  defaultPinTheme: PinTheme(
                      width: 50,
                      height: 50,
                      textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple, width: 2),
                      )),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 70,
                  child: ElevatedButton(
                    onPressed: !isDisabled
                        ? () {
                            verifyEmail();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text('Verify',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                // SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Didn\'t receive the code?',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Resend',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
