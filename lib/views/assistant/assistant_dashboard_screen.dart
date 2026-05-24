import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chat/assistant_chat_dashboard.dart';

class AssistantDashboardScreen extends StatefulWidget {
  const AssistantDashboardScreen({super.key});

  @override
  State<AssistantDashboardScreen> createState() =>
      _AssistantDashboardScreenState();
}

class _AssistantDashboardScreenState
    extends State<AssistantDashboardScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // ✅ STATUS BADGE
  Widget buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case "confirmed":
        color = Colors.green;
        label = "Confirmed";
        break;
      case "cancelled":
        color = Colors.red;
        label = "Cancelled";
        break;
      case "pending":
      default:
        color = Colors.orange;
        label = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ✅ BUILD APPOINTMENTS
  Widget buildAppointments(String tabStatus) {

    final user = FirebaseAuth.instance.currentUser!;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {

        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData =
            userSnapshot.data!.data() as Map<String, dynamic>;

        final assistantSpecialty =
            (userData['specialty'] ?? '')
                .toString()
                .toLowerCase()
                .trim();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .snapshots(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // ✅ FILTER CORRECTLY
            final docs = snapshot.data!.docs.where((doc) {

              final data =
                  doc.data() as Map<String, dynamic>;

              final specialty =
                  (data['specialty'] ?? '')
                      .toString()
                      .toLowerCase()
                      .trim();

              final status =
                  (data['status'] ?? 'pending');

              return specialty == assistantSpecialty &&
                     status == tabStatus;

            }).toList();

            if (docs.isEmpty) {
              return const Center(child: Text("No appointments"));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {

                final docSnap = docs[index];
                final data =
                    docSnap.data() as Map<String, dynamic>;

                final patientId = data['patientId'];
                final doctorId = data['doctorId'];
                final status = data['status'] ?? 'pending';

                // ✅ FETCH NAMES
                return FutureBuilder(
                  future: Future.wait([
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(patientId)
                        .get(),
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(doctorId)
                        .get(),
                  ]),
                  builder: (context,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshotUsers) {

                    if (!snapshotUsers.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final patientData =
                        snapshotUsers.data![0].data()
                            as Map<String, dynamic>?;
                    final doctorData =
                        snapshotUsers.data![1].data()
                            as Map<String, dynamic>?;

                    final patientName =
                        patientData?['name'] ?? 'Patient';
                    final doctorName =
                        doctorData?['name'] ?? 'Doctor';

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            // ✅ DOCTOR NAME
                            Text(
                              "🩺 $doctorName",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // ✅ PATIENT NAME
                            Text("👤 $patientName"),

                            Text("📅 ${data['date']}"),

                            const SizedBox(height: 10),

                            // ✅ STATUS BADGE
                            buildStatusBadge(status),

                            const SizedBox(height: 10),

                            // ✅ ACTION BUTTONS
                            if (status == 'pending')
                              Row(
                                children: [

                                  ElevatedButton(
                                    onPressed: () async {
                                      await FirebaseFirestore
                                          .instance
                                          .collection('appointments')
                                          .doc(docSnap.id)
                                          .update({
                                        'status': 'confirmed'
                                      });
                                    },
                                    child:
                                        const Text("✅ Confirm"),
                                  ),

                                  const SizedBox(width: 8),

                                  ElevatedButton(
                                    style:
                                        ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.red),
                                    onPressed: () async {
                                      await FirebaseFirestore
                                          .instance
                                          .collection('appointments')
                                          .doc(docSnap.id)
                                          .update({
                                        'status': 'cancelled'
                                      });
                                    },
                                    child:
                                        const Text("❌ Cancel"),
                                  ),
                                ],
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,

        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("Assistant Dashboard");
            }

            final data =
                snapshot.data!.data() as Map<String, dynamic>;

            return Text(
              "${data['specialty']} Assistant Dashboard",
              style: const TextStyle(color: Colors.white),
            );
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AssistantChatDashboard(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Confirmed"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          buildAppointments('pending'),
          buildAppointments('confirmed'),
        ],
      ),
    );
  }
}