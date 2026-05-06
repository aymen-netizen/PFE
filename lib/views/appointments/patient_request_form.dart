import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientRequestForm extends StatefulWidget {
  final String appointmentId;

  const PatientRequestForm({super.key, required this.appointmentId});

  @override
  State<PatientRequestForm> createState() =>
      _PatientRequestFormState();
}

class _PatientRequestFormState extends State<PatientRequestForm> {

  final TextEditingController _reasonController =
      TextEditingController();

  final List<String> symptomsList = [
    'Fever',
    'Headache',
    'Cough',
    'Fatigue',
    'Chest pain',
    'Dizziness',
  ];

  final List<String> selectedSymptoms = [];

  void _toggle(String value) {
    setState(() {
      if (selectedSymptoms.contains(value)) {
        selectedSymptoms.remove(value);
      } else {
        selectedSymptoms.add(value);
      }
    });
  }

  Future<void> _save() async {

    // ✅ VALIDATION
    if (_reasonController.text.isEmpty &&
        selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select symptoms or enter a reason'),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointmentId)
        .update({
      'reason': _reasonController.text,
      'symptoms': selectedSymptoms,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Symptoms')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Add more details',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Symptoms',
                style: TextStyle(
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: symptomsList.map((symptom) {
                  return CheckboxListTile(
                    value:
                        selectedSymptoms.contains(symptom),
                    title: Text(symptom),
                    onChanged: (_) => _toggle(symptom),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}