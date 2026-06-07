import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'assistant_chat_screen.dart';
import 'package:intl/intl.dart';

class AssistantChatDashboard extends StatelessWidget {
  const AssistantChatDashboard({super.key});

  @override
  Widget build(BuildContext context) {

    final assistant = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Conversations",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('conversations')
      .where(
        'participants',
        arrayContains: assistant.uid,
      )
      .snapshots(),

  builder: (context, snapshot) {

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text("No conversations"));
    }

    final conversations = snapshot.data!.docs.toList()
      ..sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        final aTime = aData['lastTime'] as Timestamp?;
        final bTime = bData['lastTime'] as Timestamp?;

        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

    return ListView.builder(
      itemCount: conversations.length,

      itemBuilder: (context, index) {

        final doc = conversations[index];
        final data = doc.data() as Map<String, dynamic>;

        final participants =
            List<String>.from(data['participants'] ?? []);

        final otherUserId =
            participants.firstWhere((id) => id != assistant.uid);

        String time = "";
        if (data['lastTime'] != null) {
          final dt =
              (data['lastTime'] as Timestamp).toDate();
          time = DateFormat('HH:mm').format(dt);
        }

        return ListTile(
          leading: const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.green,
            child: Icon(Icons.person, color: Colors.white),
          ),

          title: Text(
            data['assistantName'] ?? "Patient",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          subtitle: Text(
            data['lastMessage'] ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          trailing: Text(
            time,
            style: const TextStyle(fontSize: 12),
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AssistantChatScreen(
                  patientId: otherUserId,
                  chatId: doc.id,
                ),
              ),
            );
          },
        );
      },
    );
  },
)
    );
  }
}