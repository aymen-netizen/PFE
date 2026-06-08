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

  late List<String> medicationsList; 
  late List<String> analysesList; 

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

    final data = doc.data();

    setState(() {
      appointmentData = data;
      _loading = false;

      medicationsList = _getMedicationsBySpecialty(); 
      analysesList = _getAnalysesBySpecialty(); 
    });
  }

  // ✅ MEDICATIONS BY SPECIALTY
  List<String> _getMedicationsBySpecialty() {
    final specialty =
        appointmentData?['specialty']?.toLowerCase() ?? '';

    switch (specialty) {
      case 'cardiologue':
      case 'cardio':
        return [
          'Aspirin',
          'Beta blockers',
          'Statins',
          'ACE inhibitors',
        ];

      case 'dentiste':
      case 'dentist':
        return [
          'Ibuprofen',
          'Amoxicillin',
          'Mouthwash',
          'Pain killers',
        ];

      case 'dermatologie':
        return [
          'Cream',
          'Antibiotic ointment',
          'Antihistamines',
          'Moisturizer',
        ];

      case 'medecine generale':
      case 'general':
        return [
          'Paracetamol',
          'Ibuprofen',
          'Vitamin C',
        ];

      default:
        return ['Paracetamol'];
    }
  }

  // ✅ ANALYSES BY SPECIALTY
  List<String> _getAnalysesBySpecialty() {
    final specialty =
        appointmentData?['specialty']?.toLowerCase() ?? '';

    switch (specialty) {
      case 'cardiologue':
      case 'cardio':
        return [
          'ECG',
          'Blood pressure test',
          'Cholesterol test',
        ];

      case 'dentiste':
      case 'dentist':
        return [
          'Dental X-Ray',
          'Oral examination',
        ];

      case 'dermatologie':
        return [
          'Skin test',
          'Allergy test',
        ];

      case 'medecine generale':
      case 'general':
        return [
          'Blood test',
          'Urine test',
        ];

      default:
        return ['Basic test'];
    }
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

    await db
        .collection('appointments')
        .doc(widget.appointmentId)
        .update({
      'diagnosis': _diagnosisController.text,
      'medications': selectedMedications,
      'analyses': selectedAnalyses,
      'status': 'completed',
    });

    final appointmentDoc = await db
        .collection('appointments')
        .doc(widget.appointmentId)
        .get();

    final data = appointmentDoc.data();
    final patientId = data?['patientId'];

    if (patientId != null) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Reason: $reason',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text('Symptoms: ${symptoms.join(', ')}'),

            const SizedBox(height: 20),

            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Diagnosis',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text('Medications'),

            ...medicationsList.map((med) => CheckboxListTile(
                  value: selectedMedications.contains(med),
                  title: Text(med),
                  onChanged: (_) =>
                      _toggle(selectedMedications, med),
                )),

            const SizedBox(height: 10),

            const Text('Tests'), 

            ...analysesList.map((a) => CheckboxListTile(
                  value: selectedAnalyses.contains(a),
                  title: Text(a),
                  onChanged: (_) =>
                      _toggle(selectedAnalyses, a),
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