import 'package:flutter/material.dart';

class QRResultScreen extends StatelessWidget {

  final Map<String, dynamic> data;

  const QRResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    final meds = List<String>.from(data['medications'] ?? []);
    final analyses = List<String>.from(data['analyses'] ?? []);
    final recs = List<String>.from(data['recommendations'] ?? []);

    return Scaffold(
      appBar: AppBar(title: const Text("Medical Record")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [

            Text("Doctor: ${data['doctorName']}",
                style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Text("Date: ${data['date']}"),
            Text("Time: ${data['time']}"),
            Text("Specialty: ${data['specialty']}"),

            const Divider(height: 30),

            Text("Diagnosis: ${data['diagnosis'] ?? '-'}"),

            const SizedBox(height: 15),

            const Text("Medications",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...meds.map((m) => Text("• $m")),

            const SizedBox(height: 15),

            const Text("Analyses",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...analyses.map((a) => Text("• $a")),

            const SizedBox(height: 15),

            const Text("Recommendations",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...recs.map((r) => Text("• $r")),

            const SizedBox(height: 15),

            const Divider(),

            Text("Payment: ${data['paymentMethod']}"),
            Text("Status: ${data['status']}"),
            Text("Symptoms: ${data['symptoms']}"),
          ],
        ),
      ),
    );
  }
}
