import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String assistantId;
  final String profession;
  final String chatId;

  const ChatScreen({
    super.key,
    required this.assistantId,
    required this.profession,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE8F7F8),
              child: const Icon(
                Icons.medical_services,
                color: Color(0xFF0F7B8E),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.profession,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Assistant • Online",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          ],
        ),
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

                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,

                  itemBuilder: (context, index) {

                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == user.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(10),

                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF0F7B8E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                            )
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [

                            Text(
                              data['text'] ?? "",
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),

                            if (isMe)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  data['isRead'] == true
                                      ? "✔✔ Seen"
                                      : "✔ Sent",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
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
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 10),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                ),
              ],
            ),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFF0F7B8E),
                  ),

                  onPressed: () async {

                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    _controller.clear();

                    final currentUser = FirebaseAuth.instance.currentUser!;

                    await FirebaseFirestore.instance
                        .collection('conversations')
                        .doc(widget.chatId)
                        .collection('messages')
                        .add({
                      'senderId': currentUser.uid,
                      'text': text,
                      'timestamp': FieldValue.serverTimestamp(),
                      'isRead': false,
                    });

                    await FirebaseFirestore.instance
                        .collection('conversations')
                        .doc(widget.chatId)
                        .update({
                      'lastMessage': text,
                      'lastTime': FieldValue.serverTimestamp(),
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