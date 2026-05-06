import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_appointment_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssistantDashboardScreen extends StatelessWidget {
  const AssistantDashboardScreen({super.key});

  Color _color(String status) {
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

  List<Map<String, dynamic>> _filter(
      List<Map<String, dynamic>> list, int tabIndex) {
    return list.where((appt) {
      final status = appt['status'] ?? '';

      if (tabIndex == 0) return status == 'pending';
      if (tabIndex == 1) return status == 'confirmed';
      return status == 'completed' || status == 'cancelled';
    }).toList();
  }

  Widget _list(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return const Center(child: Text('No RDV'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final appt = list[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt['doctorName'] ?? ''),

                Text('👤 ${appt['patientName']}'),
                Text('📅 ${appt['date']}'),
                Text('⏰ ${appt['time']}'),

                const SizedBox(height: 6),

                Text(
                  appt['status'],
                  style: TextStyle(
                    color: _color(appt['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [

                    // ✅ CONFIRM BUTTON
                    if (appt['status'] == 'pending')
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('appointments')
                              .doc(appt['id'])
                              .update({'status': 'confirmed'});
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text('Confirmer'),
                      ),

                    const SizedBox(width: 8),

                    // ✅ CANCEL BUTTON
                    if (appt['status'] != 'completed')
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('appointments')
                              .doc(appt['id'])
                              .update({'status': 'cancelled'});
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Annuler'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = FirebaseAppointmentService();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assistant Dashboard'),

          // ✅ ✅ ✅ LOGOUT BUTTON ADDED HERE
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login', // ⚠️ make sure this route exists
                  (route) => false,
                );
              },
            ),
          ],

          bottom: const TabBar(
            tabs: [
              Tab(text: "En attente"),
              Tab(text: "Confirmés"),
              Tab(text: "Terminés"),
            ],
          ),
        ),

        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: service.assistantAppointmentsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = snapshot.data!;

            return TabBarView(
              children: [
                _list(_filter(list, 0)),
                _list(_filter(list, 1)),
                _list(_filter(list, 2)),
              ],
            );
          },
        ),
      ),
    );
  }
}