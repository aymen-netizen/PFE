import 'package:flutter/material.dart';
import '../../services/firebase_doctor_service.dart';
import '../../services/firebase_specialty_service.dart';
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

  final Stream<List<Map<String, dynamic>>> _specialtyStream =
      FirebaseSpecialtyService().streamSpecialties();
  final Stream<List<Map<String, dynamic>>> _doctorStream =
      FirebaseDoctorService().doctorsStream();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Doctors")),

      body: Column(
        children: [

          ///  SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search doctor...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
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

          /// ✅ FILTER (DYNAMIC FROM FIREBASE)
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _specialtyStream,
            builder: (context, specialtySnapshot) {
              if (!specialtySnapshot.hasData) {
                return const SizedBox(
                  height: 56,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final specialties = [
                {'label': 'All', 'value': 'all'},
                ...specialtySnapshot.data!.map((s) {
                  final name = (s['name'] as String).trim();
                  return {
                    'label': name.toTitleCase(),
                    'value': name.toLowerCase(),
                  };
                }),
              ];

              return SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: specialties.length,
                  itemBuilder: (context, index) {
                    final specialty = specialties[index];
                    final specValue = specialty['value'] as String;
                    final specLabel = specialty['label'] as String;
                    final selected = selectedSpecialty == specValue;

                    return ChoiceChip(
                      label: Text(specLabel),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          selectedSpecialty = specValue;
                        });
                      },
                      selectedColor: const Color(0xFF0F7B8E),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: selected ? Colors.transparent : Colors.grey.shade300,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          /// ✅ LIST
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _doctorStream,
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

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        selectedSpecialty == 'all'
                            ? 'No doctors found. Try another search.'
                            : 'No doctors found for ${selectedSpecialty.toTitleCase()}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {

                    final doc = filtered[i];

                    /// ✅ ✅ CLEAN IMAGE PATH
                    final rawImage = (doc['image'] ?? '').toString();
                    final cleanedImage = rawImage
                        .trim()
                        .replaceAll(RegExp(r'\s+'), '')
                        .replaceAll('assets/', '');
                    final hasImage = cleanedImage.isNotEmpty;
                    final imageProvider = hasImage
                        ? AssetImage('assets/$cleanedImage')
                        : null;
                    final initials = (doc['name'] ?? '')
                        .toString()
                        .trim()
                        .isNotEmpty
                        ? doc['name'].toString().trim()[0].toUpperCase()
                        : 'D';

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),

                      child: Row(
                        children: [

                          /// ✅ AVATAR
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFFEAF3F5),
                            backgroundImage: imageProvider,
                            child: imageProvider == null
                                ? Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Color(0xFF0F7B8E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),

                          const SizedBox(width: 12),

                          /// ✅ INFO
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
                                  doc['specialty'] ?? '',
                                  style: const TextStyle(
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

                          /// ✅ RIGHT SIDE
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
                                style: ElevatedButton.styleFrom(
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

/// ✅ STRING EXTENSION
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}
