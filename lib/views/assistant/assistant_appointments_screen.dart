import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssistantAppointmentsScreen extends StatelessWidget {
  const AssistantAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant Dashboard'),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get(),

        builder: (context, userSnap) {

          if (!userSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData =
              userSnap.data!.data() as Map<String, dynamic>;

          // ✅ ✅ ✅ REAL SPECIALTY FROM DB
          final assistantSpecialty =
              (userData['specialty'] ?? '')
                  .toString()
                  .toLowerCase()
                  .trim();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where('specialty',
                    isEqualTo: assistantSpecialty) // ✅ FIX
                .snapshots(),

            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return Center(
                  child: Text(
                      'No appointments for: $assistantSpecialty'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {

                  final doc = docs[index];
                  final data =
                      doc.data() as Map<String, dynamic>;

                  final status = data['status'] ?? 'pending';

                  return Card(
                    margin:
                        const EdgeInsets.only(bottom: 12),
                    child: ListTile(

                      title:
                          Text(data['doctorName'] ?? ''),

                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                              '👤 ${data['patientName']}'),
                          Text(
                              '📅 ${data['date']}'),
                          Text(
                              '⏰ ${data['time']}'),

                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color:
                                  _getStatusColor(status),
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          IconButton(
                            icon: const Icon(Icons.check,
                                color: Colors.green),
                            onPressed:
                                status == 'pending'
                                    ? () async {
                                        await FirebaseFirestore
                                            .instance
                                            .collection(
                                                'appointments')
                                            .doc(doc.id)
                                            .update({
                                          'status':
                                              'confirmed',
                                        });
                                      }
                                    : null,
                          ),

                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore
                                  .instance
                                  .collection(
                                      'appointments')
                                  .doc(doc.id)
                                  .update({
                                'status': 'cancelled',
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}