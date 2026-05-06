import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorConsultationScreen extends StatefulWidget {
  final String appointmentId;

  const DoctorConsultationScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<DoctorConsultationScreen> createState() =>
      _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState
    extends State<DoctorConsultationScreen> {
  final TextEditingController _diagnosisController =
      TextEditingController();

  bool _loading = true;
  Map<String, dynamic>? appointmentData;

  final List<String> medicationsList = [
    'Paracetamol',
    'Ibuprofen',
    'Amoxicillin',
    'Vitamin C',
  ];

  final List<String> analysesList = [
    'Blood test',
    'Urine test',
    'X-Ray',
    'MRI',
  ];

  final List<String> selectedMedications = [];
  final List<String> selectedAnalyses = [];

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    final doc = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointmentId)
        .get();

    setState(() {
      appointmentData = doc.data();
      _loading = false;
    });
  }

  void _toggle(List<String> list, String value) {
    setState(() {
      list.contains(value)
          ? list.remove(value)
          : list.add(value);
    });
  }

  Future<void> _save() async {
  final db = FirebaseFirestore.instance;

  // ✅ Update appointment
  await db
      .collection('appointments')
      .doc(widget.appointmentId)
      .update({
    'diagnosis': _diagnosisController.text,
    'medications': selectedMedications,
    'analyses': selectedAnalyses,
    'status': 'completed',
  });

  // ✅ GET appointment to retrieve patientId
  final appointmentDoc = await db
      .collection('appointments')
      .doc(widget.appointmentId)
      .get();

  final data = appointmentDoc.data();

  final patientId = data?['patientId'];

  if (patientId != null) {
    // ✅ SAVE TO DOSSIER (history)
    await db
        .collection('patients')
        .doc(patientId)
        .collection('dossier')
        .add({
      'diagnosis': _diagnosisController.text,
      'medications': selectedMedications,
      'analyses': selectedAnalyses,
      'date': FieldValue.serverTimestamp(),
    });

    // ✅ SAVE ANALYSES separately
    for (var analysis in selectedAnalyses) {
      await db
          .collection('patients')
          .doc(patientId)
          .collection('analyses')
          .add({
        'name': analysis,
        'status': 'pending',
        'date': FieldValue.serverTimestamp(),
      });
    }
  }

  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final reason = appointmentData?['reason'] ?? '';
    final symptoms =
        (appointmentData?['symptoms'] ?? []) as List;

    return Scaffold(
      appBar: AppBar(title: const Text('Consultation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ PATIENT INFO
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reason: $reason',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Symptoms: ${symptoms.join(', ')}'),
            ),

            const SizedBox(height: 20),

            // ✅ DIAGNOSIS
            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Diagnosis',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ MEDICATIONS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Medications'),
            ),

            ...medicationsList.map((med) => CheckboxListTile(
                  value: selectedMedications.contains(med),
                  title: Text(med),
                  onChanged: (_) => _toggle(selectedMedications, med),
                )),

            const SizedBox(height: 10),

            // ✅ ANALYSES
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Analyses'),
            ),

            ...analysesList.map((a) => CheckboxListTile(
                  value: selectedAnalyses.contains(a),
                  title: Text(a),
                  onChanged: (_) => _toggle(selectedAnalyses, a),
                )),

            const Spacer(),

            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Consultation'),
            )
          ],
        ),
      ),
    );
  }
}