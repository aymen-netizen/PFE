import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateConversationPage extends StatelessWidget {
  final String patientId = "ss4jFoXumPYeiVTFih7zUrz0oOJ3";
  final String assistantId = "4ZuWe53VXdc1Sj3WWUp8ghjc0ig2";

  CreateConversationPage({super.key});

  Future<void> createConversation() async {
    final chatId = FirebaseFirestore.instance
        .collection('conversations')
        .doc()
        .id;

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(chatId)
        .set({
      'chatId': chatId,
      'participants': [patientId, assistantId],
      'lastMessage': "",
      'lastTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    print("✅ Conversation created: $chatId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Conversation"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await createConversation();
          },
          child: Text("Create Conversation"),
        ),
      ),
    );
  }
}