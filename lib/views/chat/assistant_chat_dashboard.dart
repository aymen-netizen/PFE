import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'assistant_chat_screen.dart';

class AssistantChatDashboard extends StatelessWidget {
  const AssistantChatDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'patient') // ✅ ONLY PATIENTS
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('No patients'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data =
                  users[index].data() as Map<String, dynamic>;

              final patientId = users[index].id;

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),

                title: Text(data['name'] ?? 'Patient'),

                subtitle: Text(data['email'] ?? ''),

                trailing: const Icon(Icons.arrow_forward),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssistantChatScreen(
                        conversationId: patientId,
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
}
