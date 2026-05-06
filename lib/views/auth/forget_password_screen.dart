import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ ADD THIS

import '../../../core/utils/Validators.dart';
import '../../../core/constants/app_String.dart';
import '../../../core/constants/app_Color.dart';
import '../../../widget/input/customertextfield.dart';
import '../../../widget/buttons/primary_button.dart';
import 'login.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    final email = _emailController.text.trim();

    print("TRY RESET FOR: $email");

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter your email")),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);

      print("✅ EMAIL SENT");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reset email sent ✅"),
        ),
      );

    } on FirebaseAuthException catch (e) {
      print("❌ ERROR CODE: ${e.code}");
      print("❌ ERROR MESSAGE: ${e.message}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // ✅ ICON
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: AppColors.primaryColor,
                ),
              ),

              const SizedBox(height: 32),

              // ✅ TITLE
              Text(
                AppString.forgotPassword,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              const Text(
                'Enter your email to receive reset link',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              Form(
                key: _formKey,
                child: Column(
                  children: [

                    Customertextfield(
                      hintText: AppString.email,
                      controller: _emailController,
                      isPassword: false,
                      validator: validators.validateEmail,
                    ),

                    const SizedBox(height: 32),

                    PrimaryButton(
                      text: _isLoading
                          ? 'Sending...'
                          : 'Send',
                      onPressed: _isLoading
                          ? null
                          : resetPassword, // ✅ FIXED
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Login(),
                    ),
                  );
                },
                child: const Text("Back to login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}