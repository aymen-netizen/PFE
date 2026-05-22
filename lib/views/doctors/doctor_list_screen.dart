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

  // ✅ ✅ ✅ IMAGE FUNCTION (IMPORTANT)
  String getDoctorImage(String specialty, String uid) {
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
        'assets/doctors/medecine_generale/medecine_generale1.jpg',
      ],
    };

    final list =
        imagesMap[specialty.toLowerCase()] ??
            imagesMap['dentiste']!;

    final index = uid.hashCode.abs() % list.length;

    return list[index];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Doctors")),

      body: Column(
        children: [

          // ✅ SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search doctor...",
                prefixIcon: const Icon(Icons.search),
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

          // ✅ FILTER CHIPS
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: specialties.map((spec) {

                final selected =
                    selectedSpecialty == spec;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(
                          horizontal: 6),
                  child: ChoiceChip(
                    label: Text(spec),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        selectedSpecialty = spec;
                      });
                    },
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
                      child:
                          CircularProgressIndicator());
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
                      specialty !=
                          selectedSpecialty) {
                    return false;
                  }

                  if (!name.contains(
                      searchQuery)) {
                    return false;
                  }

                  return true;

                }).toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {

                    final doc = filtered[i];

                    return Card(
                      margin:
                          const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),

                      child: ListTile(

                        // ✅ IMAGE APPLIED HERE
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              AssetImage(
                            getDoctorImage(
                              doc['specialty'],
                              doc['uid'],
                            ),
                          ),
                        ),

                        title:
                            Text(doc['name'] ?? ''),

                        subtitle:
                            Text(doc['specialty']),

                        trailing: const Icon(
                            Icons.arrow_forward_ios),

                        onTap: () {
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