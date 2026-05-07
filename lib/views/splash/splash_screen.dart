import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../assistant/assistant_dashboard_screen.dart';
import '../main_navigation_screen.dart';
import '../doctors/doctor_appointments_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {

    try {
      await Future.delayed(const Duration(seconds: 2));

      // ✅ ALWAYS CHECK USER FIRST
      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      // ✅ NOT CONNECTED → LOGIN
      if (user == null) {
        _goTo(const LoginScreen());
        return;
      }

      // ✅ GET ROLE FROM FIRESTORE
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final role = doc.data()?['role'] ?? 'patient';

      Widget targetScreen;

      // ✅ ROLE NAVIGATION
      switch (role) {
        case 'admin':
          targetScreen = const AdminDashboardScreen();
          break;

        case 'assistant':
          targetScreen = const AssistantDashboardScreen();
          break;

        case 'doctor':
          targetScreen = DoctorAppointmentsScreen(
            doctorUid: user.uid,
          );
          break;

        default:
          targetScreen = const MainNavigationScreen();
      }

      _goTo(targetScreen);

    } catch (e) {
      // ✅ FAILSAFE → SEND TO LOGIN
      _goTo(const LoginScreen());
    }
  }

  // ✅ SAFE NAVIGATION METHOD
  void _goTo(Widget screen) {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.green,

      body: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}