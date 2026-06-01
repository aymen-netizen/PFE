import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getAppointments() {
  if (user == null) {
    return const Stream.empty();
  }

  return FirebaseFirestore.instance
      .collection('appointments')
      .where('userId', isEqualTo: user!.uid) // ✅ FIX HERE
      .snapshots();
}


  // ✅ CORRECT FILTERING
  List<QueryDocumentSnapshot> _filter(
      List<QueryDocumentSnapshot> docs, int tabIndex) {
    return docs.where((doc) {
      final status =
          (doc.data() as Map<String, dynamic>)['status'];

      if (tabIndex == 0) {
        // ✅ En attente = pending + confirmed
        return status == 'pending' || status == 'confirmed';
      }
      if (tabIndex == 1) {
        // ✅ Confirmés only
        return status == 'confirmed';
      }
      if (tabIndex == 2) {
        // ✅ Terminés = completed + cancelled
        return status == 'completed' || status == 'cancelled';
      }

      return false;
    }).toList();
  }

  Future<void> _cancelAppointment(String id) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(id)
        .update({'status': 'cancelled'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes RDV'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Confirmés'),
            Tab(text: 'Terminés'),
          ],
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _getAppointments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(_filter(docs, 0)),
              _buildList(_filter(docs, 1)),
              _buildList(_filter(docs, 2)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Center(child: Text('Aucun rendez-vous'));
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
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(data['doctorName'] ?? 'Doctor'),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📅 ${data['date']}'),
                Text('⏰ ${data['time']}'),

                const SizedBox(height: 6),

                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // ✅ CANCEL ONLY IF PENDING
            trailing: status == 'pending'
                ? IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.red),
                    onPressed: () =>
                        _cancelAppointment(doc.id),
                  )
                : null,
          ),
        );
      },
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