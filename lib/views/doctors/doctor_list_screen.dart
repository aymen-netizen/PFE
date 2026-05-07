import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../services/firebase_doctor_service.dart';
import '../booking/firebase_booking_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  String selectedSpecialty = 'All';
  String searchQuery = '';

  final List<String> specialties = [
    'All',
    'Dentiste',
    'Cardiologue',
    'Generaliste',
    'Dermatologue',
  ];

 String _getDoctorImage(String specialty, String doctorId) {

  final Map<String, List<String>> imagesMap = {
    'cardiologue': [
      'assets/doctors/cardiologue/cardiologue1.jpg',
      'assets/doctors/cardiologue/cardiologue2.jpg',
      'assets/doctors/cardiologue/cardiologue3.jpg',
      'assets/doctors/cardiologue/cardiologue4.jpg',
      'assets/doctors/cardiologue/cardiologue5.jpg',
    ],
    'dentiste': [
      'assets/doctors/dentiste/dentiste1.jpg',
      'assets/doctors/dentiste/dentiste2.jpg',
      'assets/doctors/dentiste/dentiste3.jpg',
      'assets/doctors/dentiste/dentiste4.jpg',
      'assets/doctors/dentiste/dentiste5.jpg',
    ],
    'generaliste': [
      'assets/doctors/medecine_generale/medecine_generale1.jpg',
      'assets/doctors/medecine_generale/medecine_generale2.jpg',
      'assets/doctors/medecine_generale/medecine_generale3.jpg',
      'assets/doctors/medecine_generale/medecine_generale4.jpg',
      'assets/doctors/medecine_generale/medecine_generale5.jpg',
    ],
    'dermatologue': [
      'assets/doctors/dentiste/dentiste1.jpg',
      'assets/doctors/dentiste/dentiste2.jpg',
    ],
  };

  final list =
      imagesMap[specialty.toLowerCase()] ?? imagesMap['dentiste']!;

  // ✅ HASH instead of index (stable mapping)
  final hash = doctorId.hashCode.abs();

  return list[hash % list.length];
}

  @override
  Widget build(BuildContext context) {
    final firebaseDoctorService = FirebaseDoctorService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
      ),

      body: Column(
        children: [

          // ✅ SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctor...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // ✅ FILTER
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: specialties.map((spec) {

                final isSelected = selectedSpecialty == spec;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSpecialty = spec;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          spec,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ✅ DOCTORS
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: firebaseDoctorService.doctorsStream(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final doctorsData = snapshot.data!;

                final filteredDoctors = doctorsData
                    .asMap()
                    .entries
                    .where((entry) {

                  final index = entry.key;
                  final data = entry.value;

                  final specialty =
                      (data['specialty'] ?? '').toLowerCase();

                  final generatedName = data['name'].toLowerCase();

                  if (selectedSpecialty != 'All' &&
                      specialty != selectedSpecialty.toLowerCase()) {
                    return false;
                  }

                  if (searchQuery.isNotEmpty &&
                      !generatedName.contains(searchQuery)) {
                    return false;
                  }

                  return true;

                }).toList();

                if (filteredDoctors.isEmpty) {
                  return const Center(
                    child: Text('No doctors found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, i) {

                    final index = filteredDoctors[i].key;
                    final data = filteredDoctors[i].value;

                    final doctor = Doctor(
                      id: data['id'] ?? '',

                      // ✅ UNIQUE NAME
                      name: data['name'],

                      specialty: data['specialty'] ?? '',
                      location: data['location'] ?? '',
                      phone: data['phone'] ?? '',
                      shiftStart: data['shiftStart'],
                      shiftEnd: data['shiftEnd'],
                      photoUrl: data['photoUrl'] ?? '',
                      rating: (data['rating'] ?? 0).toDouble(),
                      reviewsCount: data['reviewsCount'] ?? 0,
                    );

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),

                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FirebaseBookingScreen(
                                doctor: doctor.toMap(),
                              ),
                            ),
                          );
                        },

                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [

                              CircleAvatar(
                                radius: 28,
                                backgroundImage: AssetImage(
                                  _getDoctorImage(doctor.specialty, doctor.id),
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      doctor.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      doctor.specialty,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),

                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            size: 14,
                                            color: Colors.orange),
                                        const SizedBox(width: 4),
                                        Text(
                                          doctor.rating
                                              .toStringAsFixed(1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
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