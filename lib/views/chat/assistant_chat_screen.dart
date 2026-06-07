import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class AssistantChatScreen extends StatefulWidget {
  final String patientId;
  final String chatId;

  const AssistantChatScreen({
    super.key,
    required this.patientId,
    required this.chatId,
  });

  @override
  State<AssistantChatScreen> createState() =>
      _AssistantChatScreenState();
}

class _AssistantChatScreenState
    extends State<AssistantChatScreen> {

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    markMessagesAsRead();
    resetUnread();
  }

  Future<void> markMessagesAsRead() async {
    final assistant = FirebaseAuth.instance.currentUser!;

    final messages = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: assistant.uid)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Future<void> resetUnread() async {
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.chatId)
        .update({
      'hasUnread': false,
    });
  }

  @override
  Widget build(BuildContext context) {

    final assistant = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Chat",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
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
                        margin:
                            const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                          borderRadius:
                              BorderRadius.circular(15),
                        ),

                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [

                            if (data['text'] != null)
                              Text(data['text']),

                            if (data['image'] != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8),
                                child: Image.memory(
                                  base64Decode(data['image']),
                                  height: 150,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.send,
                      color: Colors.green),

                  onPressed: () async {

                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    _controller.clear();

                    await FirebaseFirestore.instance
                        .collection('conversations')
                        .doc(widget.chatId)
                        .collection('messages')
                        .add({
                      'senderId': assistant.uid,
                      'text': text,
                      'timestamp':
                          FieldValue.serverTimestamp(),
                      'isRead': false,
                    });

                    await FirebaseFirestore.instance
                        .collection('conversations')
                        .doc(widget.chatId)
                        .update({
                      'lastMessage': text,
                      'lastTime':
                          FieldValue.serverTimestamp(),
                      'hasUnread': true,
                    });
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