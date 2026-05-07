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

  // ✅ BUILD APPOINTMENTS LIST
  Widget buildAppointments(String status) {

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

      final specialty = userData['specialty'];

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('status', isEqualTo: status)
            .where('specialty', isEqualTo: specialty) // ✅ THIS IS THE FIX
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No appointments"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data =
                  docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),

                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        data['doctorName'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),

                      Text("👤 ${data['patientName']}"),
                      Text("📅 ${data['date']}"),
                      Text("⏰ ${data['time']}"),

                      const SizedBox(height: 10),

                      if (status == 'pending')
                        Row(
                          children: [

                            ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(docs[index].id)
                                    .update({'status': 'confirmed'});
                              },
                              child: const Text("Confirm"),
                            ),

                            const SizedBox(width: 8),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(docs[index].id)
                                    .update({'status': 'cancelled'});
                              },
                              child: const Text("Cancel"),
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
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,

        // ✅ FIXED TITLE (NO DUPLICATE)
        title: StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots(),
  builder: (context, snapshot) {

    if (!snapshot.hasData || !snapshot.data!.exists) {
      return const Text(
        "Assistant Dashboard",
        style: TextStyle(color: Colors.white),
      );
    }

    final data =
        snapshot.data!.data() as Map<String, dynamic>;

    final specialty = data['specialty'];

    if (specialty == null || specialty.toString().isEmpty) {
      return const Text(
        "Assistant Dashboard",
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      "$specialty Assistant Dashboard",
      style: const TextStyle(color: Colors.white),
    );
  },
),


        iconTheme:
            const IconThemeData(color: Colors.white),

        // ✅ CHAT + LOGOUT BUTTONS
        actions: [

          IconButton(
            icon: const Icon(Icons.message,
                color: Colors.white),
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
            icon: const Icon(Icons.logout,
                color: Colors.white),
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

        // ✅ TABS FIXED (VISIBLE)
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,

          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Confirmed"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [

          // ✅ Pending
          buildAppointments('pending'),

          // ✅ Confirmed
          buildAppointments('confirmed'),
        ],
      ),
    );
  }
}