import 'package:flutter/material.dart';
import '../payment/payment_screen.dart';

class PatientRequestForm extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String selectedDate;
  final String selectedTime;

  const PatientRequestForm({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<PatientRequestForm> createState() =>
      _PatientRequestFormState();
}

class _PatientRequestFormState extends State<PatientRequestForm> {

  final TextEditingController _reasonController =
      TextEditingController();

  late List<String> symptomsList; 

  final List<String> selectedSymptoms = [];

  @override
  void initState() {
    super.initState();
    symptomsList =
        _getSymptomsBySpecialty(widget.specialty);
  }

  List<String> _getSymptomsBySpecialty(String specialty) {
    final spec = specialty.toLowerCase().trim();

    if (spec.contains('dentist') || spec.contains('dentiste')) {
      return [
        'Tooth pain',
        'Gum bleeding',
        'Bad breath',
        'Tooth sensitivity',
        'Swollen gums',
        'Jaw pain',
      ];
    } else if (spec.contains('cardio')) {
      return [
        'Chest pain',
        'Shortness of breath',
        'Heart palpitations',
        'Fatigue',
        'High blood pressure',
        'Dizziness',
      ];
    } else if (spec.contains('dermato')) {
      return [
        'Skin rash',
        'Acne',
        'Itching',
        'Red spots',
        'Dry skin',
        'Skin infection',
      ];
    } else if (spec.contains('generale') || spec.contains('générale') || spec.contains('generaliste') || spec.contains('généraliste') || spec.contains('general')) {
      return [
        'Fever',
        'Headache',
        'Cough',
        'Fatigue',
        'Body pain',
        'Dizziness',
      ];
    } else if (spec.contains('pediatre') || spec.contains('pédiatre') || spec.contains('pediatrician') || spec.contains('pediatrie')) {
      return [
        'Fever (Child)',
        'Cough (Child)',
        'Growth concerns',
        'Rash (Child)',
        'Vomiting (Child)',
        'Sleep issues',
      ];
    } else if (spec.contains('ophtalmo') || spec.contains('ophthalmo') || spec.contains('eye') || spec.contains('yeux')) {
      return [
        'Blurry vision',
        'Eye pain',
        'Dry eyes',
        'Redness',
        'Itchy eyes',
        'Double vision',
      ];
    } else if (spec.contains('ortho') || spec.contains('bone') || spec.contains('joint')) {
      return [
        'Joint pain',
        'Bone pain',
        'Muscle stiffness',
        'Swelling',
        'Difficulty walking',
        'Back pain',
      ];
    } else {
      return [
        'Fever',
        'Headache',
        'Fatigue',
      ];
    }
  }

  void _toggle(String value) {
    setState(() {
      if (selectedSymptoms.contains(value)) {
        selectedSymptoms.remove(value);
      } else {
        selectedSymptoms.add(value);
      }
    });
  }

  String _buildSymptomsText() {
    String result = selectedSymptoms.join(', ');

    if (_reasonController.text.isNotEmpty) {
      result += result.isNotEmpty
          ? ' - ${_reasonController.text}'
          : _reasonController.text;
    }

    return result;
  }

  void _next() {

    if (selectedSymptoms.isEmpty &&
        _reasonController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '⚠️ Please select at least one symptom or enter details'),
        ),
      );
      return;
    }

    final symptomsText = _buildSymptomsText();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          specialty: widget.specialty,
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          symptoms: symptomsText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Describe Your Problem'),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ✅ DOCTOR INFO
            Card(
              margin: const EdgeInsets.only(bottom: 15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text("🩺 ${widget.doctorName}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text("📅 ${widget.selectedDate}"),
                    Text("⏰ ${widget.selectedTime}"),
                  ],
                ),
              ),
            ),

            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Add more details (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            const Text(
              'Select Symptoms',
              style:
                  TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: symptomsList.map((symptom) {

                  final isSelected =
                      selectedSymptoms.contains(symptom);

                  return Card(
                    child: ListTile(
                      title: Text(symptom),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggle(symptom),
                      ),
                      onTap: () => _toggle(symptom),
                    ),
                  );

                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _next,
                child: const Text(
                  'Continue to Payment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}