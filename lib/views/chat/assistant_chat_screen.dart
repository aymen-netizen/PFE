import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssistantChatScreen extends StatefulWidget {
  final String patientId;

  const AssistantChatScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<AssistantChatScreen> createState() =>
      _AssistantChatScreenState();
}

class _AssistantChatScreenState
    extends State<AssistantChatScreen> {

  final TextEditingController _controller = TextEditingController();

  String getChatId(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort();
    return ids.join("_");
  }

  @override
  Widget build(BuildContext context) {

    final assistant = FirebaseAuth.instance.currentUser!;
    final chatId = getChatId(assistant.uid, widget.patientId);

    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.green,
  iconTheme: const IconThemeData(color: Colors.white), // ✅ FIX

  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),

  title: const Text(
    "Chat",
    style: TextStyle(color: Colors.white),
  ),
),


      body: Column(
        children: [

          // ✅ MESSAGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,

                  itemBuilder: (context, index) {

                    final data =
                        messages[index].data() as Map<String, dynamic>;

                    final isMe =
                        data['senderId'] == assistant.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.green
                              : Colors.grey.shade300,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: Text(data['text'] ?? ""),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ✅ INPUT
          Container(
            padding: const EdgeInsets.all(10),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type message...",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {

                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    // ✅ SEND MESSAGE
                    await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .add({
                      'senderId': assistant.uid,
                      'text': text,
                      'timestamp':
                          FieldValue.serverTimestamp(),
                    });

                    // ✅ UPDATE CHAT ROOT (KEEP CONSISTENT)
                    await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .set({
                      'participants': [
                        assistant.uid,
                        widget.patientId
                      ],
                      'assistantId': assistant.uid,
                      'lastMessage': text,
                      'updatedAt':
                          FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));

                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}