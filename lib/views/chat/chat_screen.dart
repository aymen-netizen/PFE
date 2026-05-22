// ✅ FIXED + CLEAN UI (NO LOGIC CHANGES)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  File? _selectedImage;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  String getChatId(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort();
    return ids.join("_");
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImage = bytes;
        _selectedImage = null;
      });
    } else {
      setState(() {
        _selectedImage = File(picked.path);
        _webImage = null;
      });
    }
  }

  Future<void> sendImage(String chatId, User user) async {
    String base64Image;

    if (kIsWeb && _webImage != null) {
      base64Image = base64Encode(_webImage!);
    } else if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    } else {
      return;
    }

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'image': base64Image,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _selectedImage = null;
      _webImage = null;
    });
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
      backgroundColor: Colors.grey[50],

      // ✅ CLEAN APPBAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.local_hospital, color: Colors.green),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.profession,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "AI Assistant • Online",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            )
          ],
        ),
      ),

      body: Column(
        children: [

          // ✅ CHAT LIST
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
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    final data =
                        messages[index].data() as Map<String, dynamic>;

                    final isMe = data['senderId'] == user.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.green.shade500
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft:
                                Radius.circular(isMe ? 16 : 4),
                            bottomRight:
                                Radius.circular(isMe ? 4 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                            )
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            if (data['text'] != null)
                              Text(
                                data['text'],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isMe
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),

                            if (data['image'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    base64Decode(data['image']),
                                    height: 150,
                                    fit: BoxFit.cover,
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

          // ✅ IMAGE PREVIEW
          if (_selectedImage != null || _webImage != null)
            Container(
              margin: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.memory(_webImage!, height: 100)
                    : Image.file(_selectedImage!, height: 100),
              ),
            ),

          // ✅ INPUT BAR
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 10),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),

            child: Row(
              children: [

                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.grey),
                  onPressed: pickImage,
                ),

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
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () async {

                    final text = _controller.text.trim();

                    if (text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .add({
                        'senderId': user.uid,
                        'text': text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                    }

                    if (_selectedImage != null || _webImage != null) {
                      await sendImage(chatId, user);
                    }

                    await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .set({
                      'participants': [user.uid, widget.assistantId],
                      'assistantId': widget.assistantId,
                      'profession': widget.profession,
                      'patientName': user.displayName ?? "Patient",
                      'lastMessage': text.isNotEmpty ? text : "📷 Image",
                      'updatedAt': FieldValue.serverTimestamp(),
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