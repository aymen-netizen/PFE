import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/Validators.dart';
import '../../../core/constants/app_String.dart';
import '../../../core/constants/app_Color.dart';
import '../../../widget/input/customertextfield.dart';
import '../../../widget/buttons/primary_button.dart';

import 'signup_screen.dart';
import 'forget_password_screen.dart';

import '../admin/admin_dashboard_screen.dart';
import '../assistant/assistant_dashboard_screen.dart';
import '../doctors/doctor_dashboard_screen.dart';
import '../main_navigation_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ ✅ REAL FIREBASE LOGIN
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception("Login failed");
      }

      // ✅ GET ROLE FROM FIRESTORE
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = doc.data()?['role'] ?? 'patient';

      Widget screen;

      switch (role) {
        case 'admin':
          screen = const AdminDashboardScreen();
          break;

        case 'assistant':
          screen = const AssistantDashboardScreen();
          break;

        case 'doctor':
          screen = const DoctorDashboardScreen();
          break;

        default:
          screen = MainNavigationScreen();
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );

    } on FirebaseAuthException catch (e) {

      String message = "Login failed";

      if (e.code == 'user-not-found') {
        message = "User not found";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
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
                    Icons.local_hospital,
                    size: 80,
                    color: AppColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  AppString.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                Text(
                  AppString.welcomeMsg,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                // ✅ EMAIL
                Customertextfield(
                  hintText: AppString.email,
                  controller: _emailController,
                  isPassword: false,
                  validator: validators.validateEmail,
                ),

                const SizedBox(height: 20),

                // ✅ PASSWORD
                Customertextfield(
                  hintText: AppString.password,
                  controller: _passwordController,
                  isPassword: true,
                  validator: validators.validatePassword,
                ),

                const SizedBox(height: 10),

                // ✅ FORGOT PASSWORD
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ForgetPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ LOGIN BUTTON
                PrimaryButton(
                  text: _isLoading ? 'Loading...' : AppString.login,
                  onPressed: _isLoading ? null : _login,
                ),

                const SizedBox(height: 20),

                // ✅ SIGN UP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppString.dontHaveAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text("Sign Up"),
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