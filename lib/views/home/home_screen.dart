import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../doctors/doctor_list_screen.dart';
import '../doctors/doctor_detail_screen.dart';
import '../profile/dossier_screen.dart';
import '../profile/analyses_screen.dart';
import '../appointments/my_appointments_screen.dart';
import '../../models/doctor.dart';

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

    return Stack(
      children: [

        // ✅ HEADER
        Container(
          height: 240,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            ),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                // ✅ HEADER TEXT
                const Padding(
                  padding: EdgeInsets.all(16),
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

                // ✅ SEARCH
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Rechercher un médecin...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ WHITE CARD
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
                        "Actions rapides",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _action(Icons.calendar_today, "RDV", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MyAppointmentsScreen(),
                              ),
                            );
                          }),
                          _action(Icons.person, "Médecins", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const DoctorListScreen(),
                              ),
                            );
                          }),
                          _action(Icons.folder, "Dossier", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const DossierScreen(),
                              ),
                            );
                          }),
                          _action(Icons.science, "Analyses", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AnalysesScreen(),
                              ),
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ✅ DOCTORS SECTION
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Médecins disponibles",
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const DoctorListScreen(),
                                ),
                              );
                            },
                            child: const Text("Voir tous"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ✅ ✅ FIRESTORE DOCTORS ✅
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('role', isEqualTo: 'doctor')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final docs = snapshot.data!.docs;

                          if (docs.isEmpty) {
                            return const Text("Aucun médecin");
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.5,
                            ),
                            itemBuilder: (context, index) {
                              final data =
                                  docs[index].data() as Map<String, dynamic>;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    
MaterialPageRoute(
  builder: (_) => DoctorDetailScreen(
    doctor: Doctor.fromMap(data), // ✅ FIXED
  ),
),

                                  );
                                },
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [

                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage: NetworkImage(
                                          data['image'] ??
                                              "https://via.placeholder.com/150"),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      data['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      data['specialty'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _action(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
