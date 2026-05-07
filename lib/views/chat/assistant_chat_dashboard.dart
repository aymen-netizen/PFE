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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('assistantId', isEqualTo: assistant.uid)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No conversations"));
          }

          final chats = snapshot.data!.docs;

          // ✅ sort manually
          chats.sort((a, b) {
            final aTime = a['updatedAt'] ?? Timestamp(0, 0);
            final bTime = b['updatedAt'] ?? Timestamp(0, 0);
            return (bTime as Timestamp).compareTo(aTime as Timestamp);
          });

          return ListView.builder(
            itemCount: chats.length,

            itemBuilder: (context, index) {

              final data =
                  chats[index].data() as Map<String, dynamic>;

              final participants =
                  List<String>.from(data['participants']);

              final patientId =
                  participants.firstWhere((id) => id != assistant.uid);

              // ✅ show real patient name
              final patientName =
                  data['patientName'] ?? "Patient";

              // ✅ format time
              String time = "";
              if (data['updatedAt'] != null) {
                final dt =
                    (data['updatedAt'] as Timestamp).toDate();
                time = DateFormat('HH:mm').format(dt);
              }

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssistantChatScreen(
                        patientId: patientId,
                      ),
                    ),
                  );
                },

                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),

                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),

                  child: Row(
                    children: [

                      // ✅ avatar
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person,
                            color: Colors.white),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            // ✅ name + time
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [

                                Text(
                                  patientName, // 🔥 REAL NAME
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // ✅ last message + unread
                            Row(
                              children: [

                                Expanded(
                                  child: Text(
                                    data['lastMessage'] ?? "",
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),

                                if ((data['unread'] ?? 0) > 0)
                                  Container(
                                    margin:
                                        const EdgeInsets.only(left: 6),
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration:
                                        const BoxDecoration(
                                      color: Colors.green,
                                      borderRadius:
                                          BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      data['unread'].toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
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
    );
  }
}