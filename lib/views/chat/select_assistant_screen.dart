import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newapp/views/chat/chat_screen.dart';

class SelectAssistantScreen extends StatelessWidget {
  const SelectAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Select Assistant"),
        backgroundColor: const Color(0xFF0F7B8E),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'assistant')
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No assistants found"),
            );
          }

          final assistants = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: assistants.length,

            itemBuilder: (context, index) {

              final data =
                  assistants[index].data() as Map<String, dynamic>;

              final assistantId = assistants[index].id;
              final name = data['name'] ?? "Assistant";
              
              // ✅ IMPORTANT FIX
              final specialty = data['specialty'] ?? "General";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        assistantId: assistantId,
                        profession: specialty, // ✅ correct value
                      ),
                    ),
                  );
                },

                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),

                  child: Row(
                    children: [

                      // ✅ AVATAR
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFE8F7F8),
                        child: const Icon(
                          Icons.medical_services,
                          color: Color(0xFF0F7B8E),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ✅ TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              specialty, // ✅ cardiologue / dentiste...
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              "AI Assistant • Online",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
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