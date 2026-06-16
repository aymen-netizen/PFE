import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// ✅ eye toggle
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user;
      if (user == null) throw Exception();

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};
      final role = data['role'] ?? 'patient';
      final status = data['status'] ?? 'active';

      if (status == 'deleted' || status == 'inactive') {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account is inactive or deleted')),
        );
        return;
      }

      Widget next;

      switch (role) {
        case 'admin':
          next = const AdminDashboardScreen();
          break;
        case 'assistant':
          next = const AssistantDashboardScreen();
          break;
        case 'doctor':
          next = const DoctorDashboardScreen();
          break;
        default:
          next = const MainNavigationScreen();
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => next),
        (route) => false,
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        /// ✅ Elegant gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F6F8), Color(0xFFE8F5E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                /// ✅ LOGO
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    size: 60,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 30),

                /// ✅ CARD
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// ✅ EMAIL
                        TextFormField(
  controller: _emailController,
  decoration: InputDecoration(
    hintText: "Email",
    prefixIcon: const Icon(Icons.email_outlined),
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Email required";
    }
    if (!value.contains('@')) {
      return "Invalid email";
    }
    return null;
  },
),

                        const SizedBox(height: 15),

                        /// ✅ PASSWORD WITH WORKING EYE
                        TextFormField(
  controller: _passwordController,
  obscureText: _obscurePassword,
  decoration: InputDecoration(
    hintText: "Password",
    prefixIcon: const Icon(Icons.lock_outline),
    filled: true,
    fillColor: Colors.grey.shade100,

    /// ✅ WORKING EYE
    suffixIcon: IconButton(
      icon: Icon(
        _obscurePassword
            ? Icons.visibility_off
            : Icons.visibility,
      ),
      onPressed: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Password required";
    }
    if (value.length < 6) {
      return "Too short";
    }
    return null;
  },
),


                        const SizedBox(height: 10),

                        /// ✅ FORGOT PASSWORD
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
                                  color: Colors.green),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// ✅ LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
  backgroundColor: Colors.green.shade600,
  elevation: 2,
  shadowColor: Colors.greenAccent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  ),
),
                            child: Text(
                              _isLoading
                                  ? "Loading..."
                                  : "Login",
                              style:
                                  const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// ✅ CREATE ACCOUNT
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
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                                color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
