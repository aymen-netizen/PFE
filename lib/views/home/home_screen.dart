import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// SCREENS
import '../appointments/my_appointments_screen.dart';
import '../profile/dossier_screen.dart';
import '../profile/analyses_screen.dart';
import '../doctors/doctor_list_screen.dart';
import '../chat/chatbot_screen.dart';

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

        /// ✅ HEADER GRADIENT
        Container(
          height: 260,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C8C8C), Color(0xFF2FA0A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
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
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// ✅ HEADER TEXT
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("TBIBI",
                              style: TextStyle(color: Colors.white70)),

                          SizedBox(height: 6),

                          Text(
                            "Hello 👋",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "Take good care of your health.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// ✅ SEARCH BAR
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Search...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// ✅ SECTION TITLE
                    const Text(
                      "Your Activity",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// ✅ GRID (PRO LOOK)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.3,

                      children: [

                        _card(context, "RDV", "$rdvCount", Icons.calendar_today,
                            const MyAppointmentsScreen()),

                        _card(context, "Medical Record", "$dossierCount",
                            Icons.folder, const DossierScreen()),

                        _card(context, "Medical Tests", "$analysesCount",
                            Icons.science, const AnalysesScreen()),

                        _card(context, "Doctors", "", Icons.person,
                            const DoctorListScreen()),

                        _card(context, "Chatbot", "", Icons.smart_toy,
                            const ChatbotScreen()),
                      ],
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

  /// ✅ ✅ CARD WITH ANIMATION + TRANSITION
  static Widget _card(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Widget screen,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),

            pageBuilder: (_, __, ___) => screen,

            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween(
                  begin: const Offset(0.2, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

Icon(icon, size: 25, color: const Color(0xFF1C8C8C)),

            const SizedBox(height: 6),

            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 5),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}