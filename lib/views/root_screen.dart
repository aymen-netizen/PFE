import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../views/home/home_screen.dart';
import '../views/assistant/assistant_appointments_screen.dart';
import '../views/doctors/doctor_appointments_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final role = data?['role'] ?? "patient";

        // ✅ PATIENT
        if (role == "patient") {
          return const HomeScreen();
        }

        // ✅ ASSISTANT
        if (role == "assistant") {
          return const AssistantAppointmentsScreen();
        }

        // ✅ DOCTOR
        if (role == "doctor") {
          return DoctorAppointmentsScreen(
            doctorUid: user.uid,
          );
        }

        // fallback
        return const HomeScreen();
      },
    );
  }
}