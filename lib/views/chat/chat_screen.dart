import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {

  final String assistantId;
  final String profession;

  const ChatScreen({
    super.key,
    required this.assistantId,
    required this.profession,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController _controller = TextEditingController();

  String getChatId(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort();
    return ids.join("_");
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    final chatId = getChatId(user.uid, widget.assistantId);

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
                        data['senderId'] == user.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                          borderRadius:
                              BorderRadius.circular(15),
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
                  icon: const Icon(Icons.send,
                      color: Colors.green),
                  onPressed: () async {

                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    // ✅ SEND MESSAGE
                    await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .add({
                      'senderId': user.uid,
                      'text': text,
                      'timestamp':
                          FieldValue.serverTimestamp(),
                    });

                    // ✅ ✅ UPDATE CHAT ROOT (IMPORTANT)
                    await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .set({
                      'participants': [
                        user.uid,
                        widget.assistantId
                      ],
                      'assistantId': widget.assistantId,
                      'profession': widget.profession,
                      'patientName': user.displayName ?? "Patient",
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