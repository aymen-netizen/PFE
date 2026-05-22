import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

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

  final TextEditingController _controller =
      TextEditingController();

  String getChatId(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort();
    return ids.join("_");
  }

  @override
  Widget build(BuildContext context) {

    final assistant =
        FirebaseAuth.instance.currentUser!;

    final chatId =
        getChatId(assistant.uid, widget.patientId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        iconTheme:
            const IconThemeData(color: Colors.white),
        title: const Text("Chat",
            style: TextStyle(color: Colors.white)),
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
                      child:
                          CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding:
                      const EdgeInsets.all(10),
                  itemCount: messages.length,

                  itemBuilder: (context, index) {

                    final data =
                        messages[index].data()
                            as Map<String, dynamic>;

                    final isAssistant =
                        data['senderId'] ==
                            assistant.uid;

                    return Align(
                      alignment: isAssistant
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin:
                            const EdgeInsets.symmetric(
                                vertical: 5),
                        padding:
                            const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: isAssistant
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                          borderRadius:
                              BorderRadius.circular(
                                  15),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              isAssistant
                                  ? CrossAxisAlignment
                                      .end
                                  : CrossAxisAlignment
                                      .start,
                          children: [

                            // ✅ TEXT
                            if (data['text'] != null)
                              Text(data['text']),

                            // ✅ IMAGE (CAN VIEW ONLY)
                            if (data['image'] != null)
                              Padding(
                                padding:
                                    const EdgeInsets
                                        .only(top: 8),
                                child: Image.memory(
                                  base64Decode(
                                      data['image']),
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

          // ✅ INPUT (TEXT ONLY)
          Container(
            padding:
                const EdgeInsets.all(10),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        InputDecoration(
                      hintText: "Type message...",
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.send,
                      color: Colors.green),
                  onPressed: () async {

                    final text =
                        _controller.text.trim();
                    if (text.isEmpty) return;

                    // ✅ SEND TEXT ONLY
                    await FirebaseFirestore
                        .instance
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .add({
                      'senderId':
                          assistant.uid,
                      'text': text,
                      'timestamp':
                          FieldValue
                              .serverTimestamp(),
                    });

                    // ✅ UPDATE CHAT
                    await FirebaseFirestore
                        .instance
                        .collection('chats')
                        .doc(chatId)
                        .set({
                      'participants': [
                        assistant.uid,
                        widget.patientId
                      ],
                      'assistantId':
                          assistant.uid,
                      'lastMessage': text,
                      'updatedAt':
                          FieldValue
                              .serverTimestamp(),
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
