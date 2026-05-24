import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentScreen extends StatelessWidget {

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

  String maskCard(String number) {
    if (number.length < 4) return "****";
    return "**** **** **** ${number.substring(number.length - 4)}";
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final cardNumber = data['cardNumber'] ?? '';
          final expiry = data['cardExpiry'] ?? '';

          // ✅ NO CARD
          if (cardNumber.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No card found"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Add card in profile"),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                const SizedBox(height: 40),

                const Icon(
                  Icons.credit_card,
                  size: 80,
                  color: Colors.green,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Consultation Fee",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "50 DT",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ CARD UI
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        maskCard(cardNumber),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "VALID THRU $expiry",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ✅ ✅ FINAL PAY BUTTON (ONLY SAVE HERE)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                    ),

                    onPressed: () async {

                      // ✅ LOADING
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      );

                      await Future.delayed(
                          const Duration(seconds: 2));

                      // ✅ SAVE TO FIREBASE (ONLY HERE)
                      await FirebaseFirestore.instance
                          .collection('appointments')
                          .add({
                        "doctorId": doctorId,
                        "doctorName": doctorName,
                        "specialty": specialty.toLowerCase(),
                        "patientId": user.uid,
                        "patientName": user.email,
                        "date": selectedDate,
                        "time": selectedTime,
                        "symptoms": symptoms,
                        "status": "pending",
                      });

                      Navigator.pop(context);

                      // ✅ SUCCESS
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content:
                              Text("RDV confirmé ✅"),
                        ),
                      );

                      Navigator.popUntil(
                          context,
                          (route) => route.isFirst);
                    },

                    child: const Text("Pay Now"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}