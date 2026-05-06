import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  final String doctorUid;

  const DoctorAppointmentsScreen({
    super.key,
    required this.doctorUid,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Appointments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('appointments')
            .where('doctorUid', isEqualTo: doctorUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No patients'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
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
                    data['patientName'] ?? '',
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
                      Text('📅 ${data['date']}'),
                      Text('⏰ ${data['time']}'),
                      const SizedBox(height: 6),

                      // ✅ STATUS WITH COLOR
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // ✅ ACTION BUTTONS (SMART)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ▶ START CONSULTATION
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.blue),
                        onPressed: status == 'confirmed'
                            ? () async {
                                await firestore
                                    .collection('appointments')
                                    .doc(doc.id)
                                    .update({
                                  'status': 'in_consultation',
                                });
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
