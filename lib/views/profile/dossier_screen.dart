import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DossierScreen extends StatelessWidget {
  const DossierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
  title: const Text("Medical Record"),
  backgroundColor: Colors.green,

  // ✅ FORCE BACK BUTTON COLOR
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),

  // ✅ TEXT COLOR
  titleTextStyle: const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

      backgroundColor: const Color(0xFFF3F5F9),

      body: user == null
          ? const Center(child: Text("Not logged in"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patients')
                  .doc(user.uid)
                  .collection('dossier')
                  .orderBy('createdAt', descending: true) // ✅ latest first
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("DEBUG: Dossier Screen error: ${snapshot.error}");
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                print("DEBUG: Dossier Screen user.uid: ${user.uid}, docs count: ${docs.length}");

                if (docs.isEmpty) {
                  return const Center(child: Text("No records available"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,

                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;

                    final medications =
                        (data['medications'] ?? []) as List;
                    final analyses =
                        (data['analyses'] ?? []) as List;
                    final recommendations =
                        (data['recommendations'] ?? []) as List;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ✅ HEADER (IMPORTANT)
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Dr ${data['doctorName'] ?? ''}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                data['date'] ?? "",
                                style: const TextStyle(
                                    color: Colors.grey),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // ✅ MEDICATIONS
                          if (medications.isNotEmpty) ...[
                            const Text(
                              "Medications",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 8,
                              children: medications.map<Widget>((m) {
                                return Chip(
                                  label: Text(m),
                                  backgroundColor:
                                      Colors.blue.shade50,
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 15),

                          // ✅ ANALYSES
                          if (analyses.isNotEmpty) ...[
                            const Text(
                              "Tests",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 8,
                              children: analyses.map<Widget>((a) {
                                return Chip(
                                  label: Text(a),
                                  backgroundColor:
                                      Colors.green.shade50,
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 15),

                          // ✅ RECOMMENDATIONS
                          if (recommendations.isNotEmpty) ...[
                            const Text(
                              "Recommendations",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            const SizedBox(height: 8),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: recommendations.map<Widget>((r) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 4),
                                  child: Text("• $r"),
                                );
                              }).toList(),
                            ),
                          ],
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