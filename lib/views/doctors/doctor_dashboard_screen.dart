import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_appointment_service.dart';
import 'firebase_doctor_consultation_screen.dart';
import 'doctor_schedule_screen.dart'; // ✅ ADD THIS

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  // ✅ STATUS COLOR
  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'in_consultation':
        return Colors.deepPurple;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // ✅ STATUS LABEL
  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmé';
      case 'in_consultation':
        return 'En consultation';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  // ✅ STATS CARD
  Widget _buildStatCard(
      String title, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            Text(title, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  // ✅ FILTER
  List<Map<String, dynamic>> _filter(
      List<Map<String, dynamic>> list, int tabIndex) {

    return list.where((appt) {

      final status = appt['status'] ?? '';

      if (tabIndex == 0) {
        return status == 'confirmed' ||
            status == 'in_consultation';
      }

      return status == 'completed' ||
          status == 'cancelled';

    }).toList();
  }

  // ✅ LIST BUILDER
  Widget _buildList(List<Map<String, dynamic>> list) {

    if (list.isEmpty) {
      return const Center(child: Text('Aucun patient'));
    }

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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  appt['patientName'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),

                const SizedBox(height: 6),

                Text('🩺 ${appt['doctorName']}'),
                Text('📅 ${appt['date']}'),
                Text('⏰ ${appt['time']}'),

                const SizedBox(height: 6),

                Text(
                  _statusLabel(appt['status']),
                  style: TextStyle(
                    color:
                        _statusColor(appt['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // ✅ REASON
                if (appt['reason'] != null &&
                    appt['reason']
                        .toString()
                        .isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text("📝 ${appt['reason']}"),
                  ),

                const SizedBox(height: 10),

                Row(
                  children: [

                    if (appt['status'] ==
                        'confirmed')
                      ElevatedButton(
                        onPressed: () async {

                          await FirebaseFirestore
                              .instance
                              .collection(
                                  'appointments')
                              .doc(appt['id'])
                              .update({
                            'status':
                                'in_consultation',
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FirebaseDoctorConsultationScreen(
                                      appointment:
                                          appt),
                            ),
                          );
                        },
                        child: const Text('Start'),
                      ),

                    const SizedBox(width: 8),

                    if (appt['status'] ==
                        'in_consultation')
                      ElevatedButton(
                        onPressed: () async {

                          await FirebaseFirestore
                              .instance
                              .collection(
                                  'appointments')
                              .doc(appt['id'])
                              .update({
                            'status': 'completed',
                          });
                        },
                        child:
                            const Text('Terminer'),
                      ),

                    const SizedBox(width: 8),

                    if (appt['status'] !=
                            'completed' &&
                        appt['status'] !=
                            'cancelled')
                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.red),
                        onPressed: () async {

                          await FirebaseFirestore
                              .instance
                              .collection(
                                  'appointments')
                              .doc(appt['id'])
                              .update({
                            'status': 'cancelled',
                          });
                        },
                        child:
                            const Text('Annuler'),
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
      length: 2,

      child: Scaffold(
        appBar: AppBar(
          title:
              const Text('Doctor Dashboard'),

          bottom: const TabBar(
            tabs: [
              Tab(text: "Confirmés"),
              Tab(text: "Terminés"),
            ],
          ),

          // ✅ ✅ ✅ FIXED HERE
          actions: [

            // 🔥 SCHEDULE BUTTON
            IconButton(
              icon: const Icon(Icons.schedule),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DoctorScheduleScreen(),
                  ),
                );
              },
            ),

            IconButton(
              icon:
                  const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance
                    .signOut();

                if (context.mounted) {
                  Navigator
                      .pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),

        body: Column(
          children: [

            // ✅ STATS
            StreamBuilder<Map<String, int>>(
              stream:
                  service.dashboardStatsStream(),

              builder:
                  (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Padding(
                    padding:
                        EdgeInsets.all(16),
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final stats =
                    snapshot.data!;

                return Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStatCard(
                          'Today',
                          stats['today']!,
                          Colors.blue),
                      _buildStatCard(
                          'Done',
                          stats['completed']!,
                          Colors.green),
                      _buildStatCard(
                          'Pending',
                          stats['pending']!,
                          Colors.orange),
                      _buildStatCard(
                          'Cancel',
                          stats['cancelled']!,
                          Colors.red),
                    ],
                  ),
                );
              },
            ),

            // ✅ LIST
            Expanded(
              child: StreamBuilder<
                  List<Map<String, dynamic>>>(
                stream:
                    service.doctorAppointmentsStream(),

                builder:
                    (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  final list =
                      snapshot.data!;

                  return TabBarView(
                    children: [
                      _buildList(
                          _filter(list, 0)),
                      _buildList(
                          _filter(list, 1)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}