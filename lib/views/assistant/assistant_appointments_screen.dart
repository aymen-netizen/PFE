import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../chat/assistant_chat_screen.dart';

class AssistantAppointmentsScreen extends StatelessWidget {
  const AssistantAppointmentsScreen({super.key});

  Future<String> getOrCreateConversation(
    String assistantId,
    String patientId,
  ) async {
    final query = await FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContains: assistantId)
        .get();

    for (var doc in query.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(patientId)) {
        return doc.id;
      }
    }

    final newDoc =
        FirebaseFirestore.instance.collection('conversations').doc();

    await newDoc.set({
      'participants': [assistantId, patientId],
      'lastMessage': "",
      'lastTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newDoc.id;
  }

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

          final assistantSpecialty =
              (userData['specialty'] ?? '')
                  .toString()
                  .toLowerCase()
                  .trim();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where('specialty', isEqualTo: assistantSpecialty)
                .snapshots(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            data['patientName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text('📅 ${data['date']}'),
                          Text('⏰ ${data['time']}'),

                          const SizedBox(height: 10),

                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [

                              IconButton(
                                icon: const Icon(
                                  Icons.chat,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {

                                  final patientId =
                                      data['patientId'] ??
                                      data['userId'];

                                  final chatId =
                                      await getOrCreateConversation(
                                    user.uid,
                                    patientId,
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AssistantChatScreen(
                                        patientId: patientId,
                                        chatId: chatId,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(width: 10),

                              ElevatedButton(
                                onPressed: status == 'pending'
                                    ? () async {
                                        await FirebaseFirestore.instance
                                            .collection('appointments')
                                            .doc(doc.id)
                                            .update({
                                          'status': 'confirmed',
                                        });
                                      }
                                    : null,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),

                                child: const Text("Confirm"),
                              ),

                              const SizedBox(width: 10),

                              ElevatedButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('appointments')
                                      .doc(doc.id)
                                      .update({
                                    'status': 'cancelled',
                                  });
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),

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