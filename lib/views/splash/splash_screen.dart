import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_String.dart';
import '../../../core/constants/app_Color.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../assistant/assistant_dashboard_screen.dart';
import '../main_navigation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  final user = FirebaseAuth.instance.currentUser;

  // NOT LOGGED IN
  if (user == null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return;
  }

  // GET ROLE FROM FIREBASE
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final data = doc.data();
  final role = data?['role'] ?? 'patient';

  // ADMIN
  if (role == 'admin') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
    );
    return;
  }

  // ASSISTANT
  if (role == 'assistant') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AssistantDashboardScreen()),
    );
    return;
  }

  // DOCTOR
  if (role == 'doctor') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorAppointmentsScreen(
          doctorUid: user.uid,
        ),
      ),
    );
    return;
  }

  // DEFAULT → PATIENT
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppString.appTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Accès aux soins simplifié',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
