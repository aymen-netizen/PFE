import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_success_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String selectedDate;
  final String selectedTime;
  final String symptoms;

  const PaymentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.selectedDate,
    required this.selectedTime,
    required this.symptoms,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  String cardNumber = "";
  String expiry = "";
  bool isRedirecting = false;  // IMPORTANT

  @override
  void initState() {
    super.initState();
    loadCard();
  }

  Future<void> loadCard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    if (data != null) {
      final number = data['cardNumber'] ?? "";
      final exp = data['cardExpiry'] ?? "";

      // ✅ REDIRECT IF NO CARD
      if (number.isEmpty && !isRedirecting) {
        isRedirecting = true;

        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("⚠️ Please add a card first"),
            ),
          );

          Navigator.pushNamed(context, '/profile').then((_) {
            isRedirecting = false;
            loadCard(); // ✅ reload after return
          });
        });

        return;
      }

      // ✅ LOAD CARD
      setState(() {
        cardNumber = number;
        expiry = exp;
      });
    }
  }

  String maskCard(String number) {
    if (number.length < 4) return "**** **** **** ****";
    return "**** **** **** ${number.substring(number.length - 4)}";
  }

  Future<void> _pay() async {
    final currentUser = FirebaseAuth.instance.currentUser!;

    final doc = await FirebaseFirestore.instance
        .collection('appointments')
        .add({
      'doctorId': widget.doctorId,
      'doctorName': widget.doctorName,
      'specialty': widget.specialty,
      'date': widget.selectedDate,
      'time': widget.selectedTime,
      'symptoms': widget.symptoms,
      'price': 50,
      'userId': currentUser.uid,
      'status': 'pending',
      'paymentMethod': "Card",
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('patients')
        .doc(currentUser.uid)
        .collection('dossier')
        .add({
      'appointmentId': doc.id,
      'doctorName': widget.doctorName,
      'date': widget.selectedDate,
      'medications': [],
      'analyses': [],
      'recommendations': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    final qrData = {
      "id": doc.id,
      "doctor": widget.doctorName,
      "date": widget.selectedDate,
      "time": widget.selectedTime
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          appointmentId: doc.id,
          qrData: qrData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Payment")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ✅ CARD UI
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A5FC1), Color(0xFF6A82FB)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("MASTER CARD",
                      style: TextStyle(color: Colors.white70)),

                  const Spacer(),

                  Text(
                    maskCard(cardNumber),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      expiry,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ✅ WARNING MESSAGE
            if (cardNumber.isEmpty)
              const Center(
                child: Text(
                  "⚠️ Add a card in Profile first",
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 20),

            // ✅ PAY BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: cardNumber.isEmpty ? null : _pay,
                child: const Text("Pay Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
