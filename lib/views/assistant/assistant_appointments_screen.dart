import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssistantAppointmentsScreen extends StatelessWidget {
  const AssistantAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant - Appointments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ IMPORTANT FIX: NO orderBy
        stream: firestore.collection('appointments').snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No appointments'));
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

                  // ✅ Doctor name
                  title: Text(
                    data['doctorName'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // ✅ Details
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('👤 ${data['patientName'] ?? ''}'),
                      Text('📅 ${data['date']}'),
                      Text('⏰ ${data['time']}'),

                      const SizedBox(height: 6),

                      // ✅ STATUS COLOR
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
                      // ✅ CONFIRM (only if pending)
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: status == 'pending'
                            ? () async {
                                await firestore
                                    .collection('appointments')
                                    .doc(doc.id)
                                    .update({
                                  'status': 'confirmed',
                                });
                              }
                            : null,
                      ),

                      // ✅ CANCEL (not if completed)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: status != 'completed'
                            ? () async {
                                await firestore
                                    .collection('appointments')
                                    .doc(doc.id)
                                    .update({
                                  'status': 'cancelled',
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
