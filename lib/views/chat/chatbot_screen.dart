import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../payment/payment_screen.dart';

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
  String selectedDoctorName = "";
  String selectedDate = "";
  String selectedTime = "";
  String selectedPaymentMethod = "";

  List<Map<String, dynamic>> doctors = [];

  List<String> availableTimes = [
    "09:00",
    "10:00",
    "11:00",
    "14:00",
    "15:00",
  ];

  @override
  void initState() {
    super.initState();

    messages.add({
      "sender": "bot",
      "text":
          "👋 Welcome! I'm your medical assistant.\n\n"
          "Describe your symptoms and I will guide you."
    });
  }

  // ✅ LOAD DOCTORS
  Future<void> loadDoctors() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .get();

    doctors = snapshot.docs.where((doc) {
      return (doc['specialty'] ?? "").toString().toLowerCase()
          .trim() ==
          selectedSpecialty;
    }).map((doc) {
      return {
        "id": doc.id,
        "name": doc['name'],
      };
    }).toList();
  }

  void sendBotMessage(String text) {
    setState(() {
      messages.add({"sender": "bot", "text": text});
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
    selectedDate = "";
    selectedTime = "";
    selectedPaymentMethod = "";
  }

  // ✅ AI LOGIC (FIXED ASYNC)
 Future<void> handleAI(String text) async {

  final input = text.toLowerCase();

  // ❤️ HEART
  if (input.contains("chest") ||
      input.contains("heart") ||
      input.contains("breath")) {

    selectedSpecialty = "cardiologue";

    currentStep = "symptoms";

    sendBotMessage(
      "❤️ I understand your symptoms.\n\n"
      "👉 Do you also have:\n"
      "• Dizziness\n"
      "• Palpitations\n"
      "• Fatigue ?\n\n"
      "Type or choose symptoms."
    );

    setState(() {});
    return;
  }

  // ✅ USER ADDS SYMPTOMS
  if (currentStep == "symptoms") {

    // you could store them if needed
    await loadDoctors();

    currentStep = "doctor";

    sendBotMessage("✅ Thank you.\n\nPlease choose a doctor:");

    setState(() {});
    return;
  }

  // ✅ YES
  if (input.contains("yes")) {

    await loadDoctors();

    currentStep = "doctor";

    sendBotMessage("✅ Choose a doctor:");

    setState(() {});
    return;
  }

  sendBotMessage("💬 Please describe your symptoms.");
}
  // ✅ DATE
  Future<void> pickDate() async {

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;

    selectedDate = picked.toString().split(" ")[0];

    currentStep = "time";

    sendBotMessage("🕒 Select time:");

    setState(() {});
  }

  // ✅ BOOK
  Future<void> bookAppointment() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('appointments').add({
      'patientId': user.uid,
      'doctorId': selectedDoctor,
      'doctorName': selectedDoctorName,
      'specialty': selectedSpecialty,
      'date': selectedDate,
      'time': selectedTime,
      'status': "pending",
      'paymentMethod': selectedPaymentMethod,
      'createdAt': FieldValue.serverTimestamp(),
    });

    sendBotMessage("✅ Appointment booked!");
    resetFlow();
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

          // ✅ CHAT
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {

                final msg = messages[index];
                final isUser = msg['sender'] == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ DOCTORS
          if (currentStep == "doctor")
            Wrap(
              children: doctors.map((d) => ElevatedButton(
                onPressed: () {
                  selectedDoctor = d['id'];
                  selectedDoctorName = d['name'];

                  currentStep = "date";

                  sendBotMessage("📅 Pick a date");

                  setState(() {});
                },
                child: Text(d['name']),
              )).toList(),
            ),

          // ✅ DATE
          if (currentStep == "date")
            ElevatedButton(
              onPressed: pickDate,
              child: const Text("Select Date"),
            ),

          // ✅ TIME
          if (currentStep == "time")
            Wrap(
              children: availableTimes.map((t) =>
                  ElevatedButton(
                    onPressed: () {
                      selectedTime = t;
                      currentStep = "payment";

                      sendBotMessage("💳 Choose payment");

                      setState(() {});
                    },
                    child: Text(t),
                  )
              ).toList(),
            ),

          // ✅ PAYMENT
          if (currentStep == "payment")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    selectedPaymentMethod = "Cash";
                    bookAppointment();
                  },
                  child: const Text("Cash"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    selectedPaymentMethod = "Card";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          doctorId: selectedDoctor,
                          doctorName: selectedDoctorName,
                          specialty: selectedSpecialty,
                          selectedDate: selectedDate,
                          selectedTime: selectedTime,
                          symptoms: "",
                        ),
                      ),
                    );
                  },
                  child: const Text("Card"),
                ),
              ],
            ),

          // ✅ INPUT
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                      hintText: "Describe symptoms..."),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {

                  final text = _controller.text.trim();
                  if (text.isEmpty) return;

                  addUserMessage(text);

                  await handleAI(text);

                  _controller.clear();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}