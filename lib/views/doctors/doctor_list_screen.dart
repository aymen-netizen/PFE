import 'package:flutter/material.dart';
import '../../services/firebase_doctor_service.dart';
import '../booking/firebase_booking_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() =>
      _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {

  String selectedSpecialty = 'all';
  String searchQuery = '';

  final specialties = [
    'all',
    'dentiste',
    'cardiologue',
    'dermatologue',
    'generaliste',
  ];

  String getDoctorImage(String specialty, String uid) {
    final Map<String, List<String>> imagesMap = {

      'cardiologue': [
        'assets/doctors/cardiologue/cardiologue1.jpg',
        'assets/doctors/cardiologue/cardiologue2.jpg',
        'assets/doctors/cardiologue/cardiologue3.jpg',
      ],

      'dentiste': [
        'assets/doctors/dentiste/dentiste1.jpg',
        'assets/doctors/dentiste/dentiste2.jpg',
      ],

      'generaliste': [
        'assets/doctors/medecine_generale/medecine_generale1.jpg',
      ],

      'dermatologue': [
        'assets/doctors/medecine_generale/medecine_generale1.jpg',
      ],
    };

    final list =
        imagesMap[specialty.toLowerCase()] ??
            imagesMap['dentiste']!;

    final index =
        uid.hashCode.abs() % list.length;

    return list[index];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Doctors")),

      body: Column(
        children: [

          // ✅ SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search doctor...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // ✅ ✅ NEW PREMIUM FILTER
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),

              children: specialties.map((spec) {

                final selected = selectedSpecialty == spec;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSpecialty = spec;
                    });
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF0F7B8E)
                          : Colors.white,

                      borderRadius: BorderRadius.circular(25),

                      border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : Colors.grey.shade300,
                      ),

                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0F7B8E)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                              )
                            ]
                          : [],
                    ),

                    child: Row(
                      children: [

                        if (selected) ...[
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                        ],

                        Text(
                          spec.capitalize(),
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );

              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // ✅ DOCTOR LIST
          Expanded(
            child:
                StreamBuilder<List<Map<String, dynamic>>>(
              stream:
                  FirebaseDoctorService().doctorsStream(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final doctors = snapshot.data!;

                final filtered =
                    doctors.where((doc) {

                  final name = (doc['name'] ?? '')
                      .toString()
                      .toLowerCase();

                  final specialty =
                      (doc['specialty'] ?? '')
                          .toString()
                          .toLowerCase();

                  if (selectedSpecialty != 'all' &&
                      specialty != selectedSpecialty) {
                    return false;
                  }

                  if (!name.contains(searchQuery)) {
                    return false;
                  }

                  return true;

                }).toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {

                    final doc = filtered[i];

                    return Container(
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),

                      padding:
                          const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),

                      child: Row(
                        children: [

                          CircleAvatar(
                            radius: 28,
                            backgroundImage: AssetImage(
                              getDoctorImage(
                                doc['specialty'],
                                doc['uid'],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  doc['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  doc['specialty'],
                                  style:
                                      const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Row(
                                  children: const [
                                    Icon(Icons.star,
                                        color: Colors.amber,
                                        size: 16),
                                    SizedBox(width: 3),
                                    Text("4.8"),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [

                              const Text(
                                "50 DT",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F7B8E),
                                ),
                              ),

                              const SizedBox(height: 6),

                              ElevatedButton(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF0F7B8E),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          FirebaseBookingScreen(
                                        doctor: doc,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Book",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ capitalization helper
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
