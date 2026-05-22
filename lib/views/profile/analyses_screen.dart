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

  // ✅ stable image storage
  final Map<String, Uint8List> selectedImages = {};

  // ✅ pick image (web + mobile)
  Future<Uint8List?> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return await picked.readAsBytes();
  }

  // ✅ unique key per analysis
  String getKey(String docId, String analysis) {
    return "$docId::$analysis";
  }

  // ✅ preview dialog (FIXED)
  void showPreview(BuildContext context, String title, Uint8List bytes) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Image.memory(bytes),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Close"),
          ),
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
        iconTheme: const IconThemeData(color: Colors.white),
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
              final analyses = List<String>.from(data['analyses'] ?? []);
              final docId = doc.id;

              if (analyses.isEmpty) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    )
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ✅ Header
                    Text(
                      "Dr ${data['doctorName'] ?? ''}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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

                    // ✅ ANALYSES
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: analyses.map((a) {

                        final key = getKey(docId, a);
                        final hasImage = selectedImages.containsKey(key);
                        final image = selectedImages[key];

                        return KeyedSubtree(
                          key: ValueKey(key),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // ✅ Analysis chip
                              Chip(
                                label: Text(a),
                                backgroundColor: Colors.blue.shade50,
                              ),

                              const SizedBox(height: 6),

                              // ✅ Button ↔ Icons
                              !hasImage
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                      ),

                                      onPressed: () async {
                                        final bytes = await pickImage();
                                        if (bytes == null) return;

                                        setState(() {
                                          selectedImages[key] = bytes;
                                        });

                                        if (mounted) {
                                          showPreview(context, a, bytes);
                                        }
                                      },

                                      child: const Text(
                                        "Add Image",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    )

                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        // ✅ VIEW BUTTON
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {
                                            if (image != null) {
                                              showPreview(context, a, image);
                                            }
                                          },
                                        ),

                                        // ✅ REMOVE BUTTON (NOW FULLY WORKING ✅)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
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

                              // ✅ small thumbnail
                              if (hasImage && image != null)
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
                          ),
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