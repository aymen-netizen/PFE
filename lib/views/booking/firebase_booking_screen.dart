import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../appointments/patient_request_form.dart'; // ✅ ADD THIS

class FirebaseBookingScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const FirebaseBookingScreen({super.key, required this.doctor});

  @override
  State<FirebaseBookingScreen> createState() =>
      _FirebaseBookingScreenState();
}

class _FirebaseBookingScreenState
    extends State<FirebaseBookingScreen> {

  List<String> timeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00'
  ];

  String? selectedTime;
  String selectedDate =
      DateTime.now().toString().split(' ')[0];

  String reason = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: Text(widget.doctor['name'] ?? 'Doctor'),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ✅ DOCTOR CARD
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                      widget.doctor['image'] ??
                          "https://via.placeholder.com/150",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctor['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.doctor['specialty'] ?? '',
                        style:
                            TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ✅ OPTIONAL REASON (we keep it)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Reason (optional)",
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  reason = value;
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Available slots",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: timeSlots.map((time) {
                  final isSelected = selectedTime == time;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedTime = time);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),

            // ✅ ✅ IMPORTANT BUTTON UPDATE
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedTime == null
                      ? null
                      : () async {

                          final docRef =
                              await FirebaseFirestore
                                  .instance
                                  .collection('appointments')
                                  .add({
                            'patientId': FirebaseAuth
                                .instance.currentUser!.uid,
                            'patientName': FirebaseAuth
                                .instance.currentUser!.email,
                            'specialty':
                                widget.doctor['specialty'],
                            'doctorName':
                                widget.doctor['name'],
                            'date': selectedDate,
                            'time': selectedTime,
                            'status': 'pending',

                            // ✅ keep reason
                            'reason': reason,

                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          // ✅ REDIRECT TO SYMPTOMS FORM
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

                  child: const Text(
                    "Confirmer le RDV",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}