import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_doctor_consultation_screen.dart';


class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not authenticated")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Patients'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: user.uid) // ✅ FIXED
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('Aucun rendez-vous'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data =
                  doc.data() as Map<String, dynamic>? ?? {};

              final status = data['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),

                  // ✅ PATIENT NAME
                  title: Text(
                    data['patientName'] ?? 'Patient',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  // ✅ DETAILS
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('📅 ${data['date'] ?? ''}'),
                      Text('⏰ ${data['time'] ?? ''}'),

                      const SizedBox(height: 6),

                      // ✅ EXTRA INFO (Optional but pro 🔥)
                      if (data['patientPhone'] != null)
                        Text('📞 ${data['patientPhone']}'),

                      if (data['reason'] != null)
                        Text('📝 ${data['reason']}'),

                      const SizedBox(height: 6),

                      // ✅ STATUS
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // ✅ ACTIONS
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ▶ START CONSULTATION
                      IconButton(
  icon: const Icon(Icons.play_arrow, color: Colors.blue),
  onPressed: status == 'confirmed'
      ? () async {

          // ✅ update status
          await firestore
              .collection('appointments')
              .doc(doc.id)
              .update({
            'status': 'in_consultation',
          });

          // ✅ OPEN CONSULTATION SCREEN WITH CORRECT DATA
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FirebaseDoctorConsultationScreen(
                appointment: {
                  ...data,

                  // ✅ IMPORTANT FIXES
                  'id': doc.id,
                  'patientId': data['userId'], // 🔥 THIS FIXES YOUR ERROR
                },
              ),
            ),
          );
        }
      : null,
),

                      // ✅ FINISH CONSULTATION
                      IconButton(
                        icon: const Icon(Icons.check_circle,
                            color: Colors.green),
                        onPressed: status == 'in_consultation'
                            ? () async {
                                await firestore
                                    .collection('appointments')
                                    .doc(doc.id)
                                    .update({
                                  'status': 'completed',
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ STATUS COLORS
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_consultation':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}