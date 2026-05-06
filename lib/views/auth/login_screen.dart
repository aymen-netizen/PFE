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
import '../main_navigation_screen.dart';
import '../doctors/doctor_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // ✅ LOGIN WITH FIREBASE AUTH
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      // ✅ FETCH USER ROLE FROM FIRESTORE
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      final data = doc.data();

      if (data == null) {
        throw Exception("User not found in Firestore");
      }

      final role = data['role'];

      if (!mounted) return;

      // ✅ ROLE-BASED NAVIGATION
      if (role == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const AdminDashboardScreen()),
          (route) => false,
        );
      } else if (role == 'assistant') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const AssistantDashboardScreen()),
          (route) => false,
        );
      } else if (role == 'doctor') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const DoctorDashboardScreen()),
          (route) => false,
        );
      } else {
        // ✅ DEFAULT → PATIENT
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
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
                    Icons.local_hospital,
                    size: 80,
                    color: AppColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 32),

                // ✅ TITLE
                Text(
                  AppString.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  AppString.welcomeMsg,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey[600]),
                ),

                const SizedBox(height: 48),

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

                const SizedBox(height: 12),

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
                    child: Text(
                      AppString.forgotPassword,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ✅ LOGIN BUTTON
                PrimaryButton(
  text: _isLoading ? 'Loading...' : AppString.login,
  onPressed: _isLoading ? null : _login, // ✅ THIS IS THE KEY
),


                const SizedBox(height: 24),

                // ✅ SIGN UP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppString.dontHaveAccount,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        );
                      },
                      child: Text(
                        AppString.signUp,
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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