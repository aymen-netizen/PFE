import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ IMPORT SCREENS
import '../appointments/my_appointments_screen.dart';
import '../profile/dossier_screen.dart';
import '../profile/analyses_screen.dart';
import '../doctors/doctor_list_screen.dart';
import '../chat/chatbot_screen.dart'; // ✅ NEW

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomeContent(),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Stack(
      children: [
        Container(
          height: 260,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C8C8C), Color(0xFF2FA0A0)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),

        SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
    .collection('appointments')
    .where('userId', isEqualTo: user?.uid)
    .snapshots(),

            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final appointments = snapshot.data!.docs;

              // ✅ COUNTS
              int rdvCount = appointments.length;
              int dossierCount = appointments.length;

              int analysesCount = 0;

              for (var doc in appointments) {
                final data = doc.data() as Map<String, dynamic>;

                if (data['analyses'] != null) {
                  analysesCount += (data['analyses'] as List).length;
                }
              }

              return SingleChildScrollView(
                child: Column(
                  children: [

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Plateforme Santé",
                              style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 8),
                          Text(
                            "Bonjour 👋",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Prenez soin de votre santé",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Rechercher...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(18),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Votre activité",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              _infoCard(context, "RDV",
                                  "$rdvCount", Icons.calendar_today, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const MyAppointmentsScreen()),
                                );
                              }),

                              _infoCard(context, "Dossier",
                                  "$dossierCount", Icons.folder, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const DossierScreen()),
                                );
                              }),

                              _infoCard(context, "Analyses",
                                  "$analysesCount", Icons.science, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const AnalysesScreen()),
                                );
                              }),

                              _infoCard(context, "Médecins",
                                  "", Icons.person, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const DoctorListScreen()),
                                );
                              }),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // ✅ ✅ NEW ROW (CHATBOT)
                          Row(
                            children: [

                              _infoCard(context, "Chatbot",
                                  "", Icons.smart_toy, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ChatbotScreen()),
                                );
                              }),

                            ],
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget _infoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1C8C8C)),
            const SizedBox(height: 8),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
