import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../appointments/patient_request_form.dart'; // ✅ ADD THIS

class FirebaseBookingScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const FirebaseBookingScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<FirebaseBookingScreen> createState() =>
      _FirebaseBookingScreenState();
}

class _FirebaseBookingScreenState
    extends State<FirebaseBookingScreen> {

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // ✅ IMAGE FUNCTION (UNCHANGED)
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

    final user = FirebaseAuth.instance.currentUser!;

    final doctorName = widget.doctor['name'] ?? '';
    final doctorSpecialty = widget.doctor['specialty'] ?? '';
    final doctorUid = widget.doctor['uid'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(doctorName),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 20),

            // ✅ IMAGE
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                getDoctorImage(
                  doctorSpecialty,
                  doctorUid,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              doctorName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              doctorSpecialty,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // ✅ DATE PICKER
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Text(
                selectedDate == null
                    ? "Select Date"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
            ),

            const SizedBox(height: 20),

            // ✅ TIME PICKER
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
              child: Text(
                selectedTime == null
                    ? "Select Time"
                    : selectedTime!.format(context),
              ),
            ),

            const SizedBox(height: 30),

            // ✅ CONFIRM BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    (selectedDate == null ||
                            selectedTime == null)
                        ? null
                        : () async {

                            // ✅ FETCH SCHEDULE
                            final scheduleDoc =
                                await FirebaseFirestore.instance
                                    .collection('schedules')
                                    .doc(doctorUid)
                                    .get();

                            if (!scheduleDoc.exists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Doctor has no schedule"),
                                ),
                              );
                              return;
                            }

                            final schedule = scheduleDoc.data()!;
                            final List days = schedule['days'] ?? [];

                            // ✅ DAY NAME
                            final dayName = [
                              'Monday','Tuesday','Wednesday',
                              'Thursday','Friday','Saturday','Sunday'
                            ][selectedDate!.weekday - 1];

                            if (!days.contains(dayName)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Not available on $dayName"),
                                ),
                              );
                              return;
                            }

                            // ✅ TIME CHECK
                            final hour = selectedTime!.hour;

                            if (hour < 8 || hour > 14) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Working hours: 8 → 14"),
                                ),
                              );
                              return;
                            }

                            final formattedDate =
                                "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}";

                            final formattedTime =
                                selectedTime!.format(context);

                            // ✅ SAVE APPOINTMENT
                            final docRef =
                                await FirebaseFirestore.instance
                                    .collection('appointments')
                                    .add({
                              'patientId': user.uid,
                              'patientName': user.email ?? '',
                              'doctorId': doctorUid,
                              'doctorName': doctorName,
                              'specialty': doctorSpecialty.toLowerCase(),
                              'status': 'pending',
                              'date': formattedDate,
                              'time': formattedTime,
                            });

                            // ✅ 🔥 OPEN FORM
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PatientRequestForm(
                                  appointmentId:
                                      docRef.id,
                                ),
                              ),
                            );
                          },

                child:
                    const Text("Confirm Appointment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}