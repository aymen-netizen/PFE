import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newapp/services/chatbot_logic.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {

  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> messages = [];

  String currentStep = "chat";
  String selectedSpecialty = "";
  String selectedDoctor = "";
  String selectedDoctorName = ""; // ✅ NEW
  String selectedTime = "";

  List<String> symptoms = [];
  List<String> selectedSymptoms = [];

  List<Map<String, dynamic>> doctors = [];

  // ✅ LOAD DOCTORS
  Future<void> loadDoctors() async {

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .get();

    doctors = snapshot.docs.where((doc) {

      final dbValue = (doc['specialty'] ?? "")
          .toString()
          .toLowerCase()
          .trim();

      return dbValue == selectedSpecialty;

    }).map((doc) {
      return {
        "id": doc.id,
        "name": doc['name'],
      };
    }).toList();
  }

  void sendBotMessage(String text) {
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        messages.add({"sender": "bot", "text": text});
      });
    });
  }

  void addUserMessage(String text) {
    setState(() {
      messages.add({"sender": "user", "text": text});
    });
  }

  void resetFlow() {
    currentStep = "chat";
    selectedSpecialty = "";
    selectedDoctor = "";
    selectedDoctorName = "";
    selectedTime = "";
    symptoms = [];
    selectedSymptoms = [];
  }

  // ✅ DATE PICKER
  Future<void> pickDate() async {

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;

    final dayName = [
      "Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"
    ][picked.weekday - 1];

    final schedule = await FirebaseFirestore.instance
        .collection('schedules')
        .doc(selectedDoctor)
        .get();

    if (!schedule.exists) {
      sendBotMessage("⚠️ No schedule found.");
      return;
    }

    final data = schedule.data()!;
    final List days = data['days'];

    if (!days.contains(dayName)) {
      sendBotMessage("❌ Not available on $dayName");
      return;
    }

    final selectedDate = picked.toString().split(" ")[0];

    selectedTime = selectedDate; // ✅ still using date (will upgrade later)
    currentStep = "confirm";

    sendBotMessage(
        "✅ Available!\nDoctor: $selectedDoctorName\nDate: $selectedTime\nConfirm?"
    );

    setState(() {});
  }

  // ✅ BOOK APPOINTMENT (UPDATED 🔥)
  Future<void> bookAppointment() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('appointments').add({
      'patientId': user.uid,
      'doctorId': selectedDoctor,
      'doctorName': selectedDoctorName, // ✅ FIX
      'specialty': selectedSpecialty,
      'date': selectedTime,
      'time': "10:00", // ✅ TEMP (upgrade later)
      'symptoms': symptoms,
      'status': "pending",
      'createdAt': FieldValue.serverTimestamp(),
    });

    sendBotMessage("✅ Appointment booked!");
    resetFlow();
  }

  // ✅ FLOW
  void handleStep(String value) {

    addUserMessage(value);

    // CHAT
    if (currentStep == "chat") {

      if (value.contains("Book")) {
        currentStep = "start";
        sendBotMessage("Choose a specialty:");
      }

      else if (value.contains("Ask")) {
        sendBotMessage("💬 Ask me anything!");
      }

      setState(() {});
    }

    // SPECIALTY
    else if (currentStep == "start") {

      selectedSpecialty = value.split(" ").last.toLowerCase();
      selectedSymptoms = [];

      currentStep = "symptoms";
      sendBotMessage("Select your symptoms:");

      setState(() {});
    }

    // SYMPTOMS
    else if (currentStep == "symptoms") {

      if (selectedSymptoms.contains(value)) {
        selectedSymptoms.remove(value);
      } else {
        selectedSymptoms.add(value);
      }

      setState(() {});
    }

    // DOCTOR
    else if (currentStep == "doctor") {

      final selected = doctors.firstWhere((d) => d['name'] == value);

      selectedDoctor = selected['id'];
      selectedDoctorName = selected['name']; // ✅ FIX

      currentStep = "time";
      sendBotMessage("Pick a date:");

      setState(() {});
    }

    // CONFIRM
    else if (currentStep == "confirm") {

      if (value.contains("Confirm")) {
        bookAppointment();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical Assistant"),
        backgroundColor: Colors.green,
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {

                final msg = messages[index];
                final isUser = msg['sender'] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ BUTTONS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [

                if (currentStep == "chat") ...[
                  bigButton("📅 Book Appointment"),
                  bigButton("💬 Ask Question"),
                ],

                if (currentStep == "start") ...[
                  bigButton("🦷 Dentiste"),
                  bigButton("❤️ Cardiologue"),
                  bigButton("🧴 Dermatologue"),
                  bigButton("🩺 Generaliste"),
                ],

                if (currentStep == "symptoms") ...[
                  ...getSymptoms(),
                  bigButton("✅ Next", onTap: nextFromSymptoms),
                ],

                if (currentStep == "doctor") ...[
                  for (var doc in doctors)
                    bigButton(doc['name']),
                ],

                if (currentStep == "time") ...[
                  bigButton("📅 Pick Date", onTap: pickDate),
                ],

                if (currentStep == "confirm") ...[
                  bigButton("✅ Confirm"),
                ],
              ],
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: "Type..."),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;

                  addUserMessage(text);

                  if (currentStep == "chat") {
                    sendBotMessage(ChatbotLogic.getReply(text));
                  }

                  _controller.clear();
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  // ✅ BUTTON
  Widget bigButton(String text, {VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap ?? () => handleStep(text),
        child: Text(text),
      ),
    );
  }

  // ✅ SYMPTOMS
  List<Widget> getSymptoms() {

    Map<String, List<String>> data = {
      "dentiste": ["Tooth pain", "Sensitivity", "Swelling"],
      "cardiologue": ["Chest pain", "Short breath", "Palpitations"],
      "dermatologue": ["Rash", "Itching", "Red spots"],
      "generaliste": ["Fever", "Fatigue", "Headache"],
    };

    final list = data[selectedSpecialty];

    if (list == null) {
      return [const Text("⚠️ No symptoms")];
    }

    return list.map((s) => bigButton(s, onTap: () => handleStep(s))).toList();
  }

  void nextFromSymptoms() async {
    if (selectedSymptoms.isEmpty) {
      sendBotMessage("⚠️ Select symptoms");
      return;
    }

    symptoms = List.from(selectedSymptoms);

    await loadDoctors();

    currentStep = "doctor";
    sendBotMessage("Choose a doctor:");
    setState(() {});
  }
}
