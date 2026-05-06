import 'package:flutter/material.dart';
import '../../../models/doctor.dart';
import '../../../models/doctor_model.dart';
import '../doctors/doctor_list_screen.dart';
import '../doctors/doctor_detail_screen.dart';
import '../profile/dossier_screen.dart';
import '../profile/analyses_screen.dart';
import '../appointments/my_appointments_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomeContent(),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {

  List<DoctorModel> _allDoctors = [];

  @override
  void initState() {
    super.initState();

    _allDoctors = [
      DoctorModel(
        id: 1,
        name: "Dr. Ahmed",
        specialty: "Cardiology",
        photoUrl: "assets/doctors/cardiologue/cardiologue1.jpg",
        rating: 4.8,
        reviewsCount: 120,
        location: "Tunis",
        phone: "12345678",
      ),
      DoctorModel(
        id: 2,
        name: "Dr. Sarah",
        specialty: "Dentiste",
        photoUrl: "assets/doctors/dentiste/dentiste1.jpg",
        rating: 4.7,
        reviewsCount: 90,
        location: "Sfax",
        phone: "12345678",
      ),
      DoctorModel(
        id: 3,
        name: "Dr. Mehdi",
        specialty: "Pédiatre",
        photoUrl: "assets/doctors/pediatre/pediatre1.jpg",
        rating: 4.9,
        reviewsCount: 140,
        location: "Sousse",
        phone: "12345678",
      ),
      DoctorModel(
        id: 4,
        name: "Dr. Amal",
        specialty: "Médecine Générale",
        photoUrl: "assets/doctors/medecine_generale/medecine_generale1.jpg",
        rating: 4.6,
        reviewsCount: 80,
        location: "Djerba",
        phone: "12345678",
      ),
    ];
  }

  void _navigateToDoctor(DoctorModel doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorDetailScreen(
          doctor: Doctor(
            id: doctor.id.toString(),
            name: doctor.name,
            specialty: doctor.specialty,
            photoUrl: doctor.photoUrl,
            rating: doctor.rating,
            reviewsCount: doctor.reviewsCount,
            location: doctor.location,
            phone: doctor.phone,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // ✅ HEADER BACKGROUND
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

                // ✅ WHITE CONTENT CARD
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

                      // ✅ ✅ ACTIONS RAPIDES (FIXED)
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
                            "Médecins populaires",
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

                      // ✅ DOCTORS GRID (NO OVERFLOW)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _allDoctors.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                        ),
                        itemBuilder: (context, index) {
                          final d = _allDoctors[index];

                          return GestureDetector(
                            onTap: () => _navigateToDoctor(d),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage:
                                      AssetImage(d.photoUrl),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  d.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  d.specialty,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star,
                                        size: 12,
                                        color: Colors.orange),
                                    const SizedBox(width: 2),
                                    Text(
                                      d.rating.toString(),
                                      style:
                                          const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  Widget _action(
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