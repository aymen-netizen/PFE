import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class AnalysesScreen extends StatefulWidget {
  const AnalysesScreen({super.key});

  @override
 State<AnalysesScreen> createState() => _AnalysesScreenState();
}

class _AnalysesScreenState extends State<AnalysesScreen> {

  final ImagePicker _picker = ImagePicker();

  // ✅ FIX: use late + initState (prevents NULL crash)

Map<String, Uint8List> selectedImages = {};



  // ✅ PICK IMAGE
  Future<Uint8List?> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return await picked.readAsBytes();
  }

  // ✅ UNIQUE KEY
  String getKey(String docId, String analysis) {
    return "${docId}_$analysis";
  }

  // ✅ PREVIEW
  void showPreview(BuildContext context, String title, Uint8List bytes) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Image.memory(bytes),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analyses"),
        backgroundColor: Colors.green,
      ),

      backgroundColor: const Color(0xFFF3F5F9),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .doc(user.uid)
            .collection('dossier')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No analyses found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,

            itemBuilder: (context, index) {

              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final analyses =
                  List<String>.from(data['analyses'] ?? []);

              final docId = doc.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ✅ HEADER
                    Text(
                      "Dr ${data['doctorName'] ?? ''}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      data['date'] ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Analyses",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: analyses.map((a) {

                        final key = getKey(docId, a);

                        // ✅ SAFE ACCESS (NO containsKey)
                        final image = selectedImages[key];

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // ✅ CHIP
                            Chip(
                              label: Text(a),
                              backgroundColor: Colors.blue.shade50,
                            ),

                            const SizedBox(height: 6),

                            // ✅ BUTTON / ACTIONS
                            image == null
                                ? ElevatedButton(
                                    onPressed: () async {
                                      final bytes = await pickImage();
                                      if (bytes == null) return;

                                      setState(() {
                                        selectedImages[key] = bytes;
                                      });

                                      showPreview(context, a, bytes);
                                    },
                                    child: const Text("Add Image"),
                                  )

                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                      // ✅ VIEW
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility,
                                          color: Colors.green,
                                        ),
                                        onPressed: () =>
                                            showPreview(context, a, image),
                                      ),

                                      // ✅ DELETE
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectedImages.remove(key);
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                            // ✅ IMAGE PREVIEW
                            if (image != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    image,
                                    width: 90,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        );

                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}