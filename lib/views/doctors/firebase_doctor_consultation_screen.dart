import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDoctorConsultationScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const FirebaseDoctorConsultationScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<FirebaseDoctorConsultationScreen> createState() =>
      _FirebaseDoctorConsultationScreenState();
}

class _FirebaseDoctorConsultationScreenState
    extends State<FirebaseDoctorConsultationScreen> {
  final TextEditingController _diagnosisController =
      TextEditingController();
  final TextEditingController _doctorNotesController =
      TextEditingController();

  bool _loading = false;

  final List<String> _selectedMedications = [];
  final List<String> _selectedAnalyses = [];
  final List<String> _selectedImaging = [];
  final List<String> _selectedVaccines = [];
  final List<String> _selectedRecommendations = [];

  final List<String> _medications = [
    'Paracetamol',
    'Ibuprofen',
    'Amoxicillin',
    'Antihistamine',
    'Cough syrup',
    'Vitamin D',
    'Iron supplement',
  ];

  final List<String> _analyses = [
    'Blood test',
    'Urine test',
    'Cholesterol test',
    'Liver test',
    'Kidney test',
  ];

  final List<String> _recommendations = [
    'Rest',
    'Drink water',
    'Avoid effort',
    'Follow-up',
  ];

  void _toggleItem(List<String> list, String item) {
    setState(() {
      list.contains(item)
          ? list.remove(item)
          : list.add(item);
    });
  }

  Future<void> _confirmConsultation() async {
  final db = FirebaseFirestore.instance;
  

  final appointmentId = widget.appointment['id'];
  final patientId = widget.appointment['userId'] ?? widget.appointment['patientId'];

  print("DEBUG: _confirmConsultation - appointmentId: $appointmentId, patientId: $patientId");

  if (appointmentId == null || patientId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Missing data'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() => _loading = true);

  try {
    // ✅ 1. UPDATE APPOINTMENT
    await db.collection('appointments').doc(appointmentId).update({
      'diagnosis': _diagnosisController.text,
      'doctorNotes': _doctorNotesController.text,
      'medications': _selectedMedications,
      'analyses': _selectedAnalyses,
      'recommendations': _selectedRecommendations,
      'status': 'completed',
    });

    // ✅ 2. FIND EXISTING DOSSIER (LINKED TO THIS APPOINTMENT)
    final dossierQuery = await db
        .collection('patients')
        .doc(patientId)
        .collection('dossier')
        .where('appointmentId', isEqualTo: appointmentId)
        .get();

    // ✅ 3. UPDATE DOSSIER (NOT ADD NEW)
    if (dossierQuery.docs.isNotEmpty) {
      final dossierId = dossierQuery.docs.first.id;

      await db
          .collection('patients')
          .doc(patientId)
          .collection('dossier')
          .doc(dossierId)
          .update({
        'diagnosis': _diagnosisController.text,
        'doctorNotes': _doctorNotesController.text,
        'medications': _selectedMedications,
        'analyses': _selectedAnalyses,
        'recommendations': _selectedRecommendations,
        'status': 'completed',
      });
    } else {
      // ✅ safety (if dossier not created before)
      await db
          .collection('patients')
          .doc(patientId)
          .collection('dossier')
          .add({
        'appointmentId': appointmentId,
        'doctorName': widget.appointment['doctorName'],
        'date': widget.appointment['date'],
        'time': widget.appointment['time'],
        'diagnosis': _diagnosisController.text,
        'doctorNotes': _doctorNotesController.text,
        'medications': _selectedMedications,
        'analyses': _selectedAnalyses,
        'recommendations': _selectedRecommendations,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consultation saved ✅'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _choiceList(List<String> items, List<String> selected) {
    return Column(
      children: items.map((item) {
        return CheckboxListTile(
          value: selected.contains(item),
          title: Text(item),
          onChanged: (_) => _toggleItem(selected, item),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appt = widget.appointment;

    final symptoms = appt['symptoms'];
    final symptomsText = symptoms is List
        ? symptoms.join(', ')
        : symptoms?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appt['patientName'] ?? 'Patient',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text('📅 ${appt['date']}'),
            Text('⏰ ${appt['time']}'),

            const SizedBox(height: 12),

            Text('Reason: ${appt['reason'] ?? ''}'),
            Text('Symptoms: $symptomsText'),

            const SizedBox(height: 20),

            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Diagnosis',
                border: OutlineInputBorder(),
              ),
            ),

            _sectionTitle('Medications'),
            _choiceList(_medications, _selectedMedications),

            _sectionTitle('Analyses'),
            _choiceList(_analyses, _selectedAnalyses),

            _sectionTitle('Recommendations'),
            _choiceList(_recommendations, _selectedRecommendations),

            const SizedBox(height: 20),

            TextField(
              controller: _doctorNotesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Doctor notes',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirmConsultation,
                child: Text(
                    _loading ? 'Saving...' : 'Confirm Consultation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}