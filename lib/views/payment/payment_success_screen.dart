import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class PaymentSuccessScreen extends StatefulWidget {
  final String appointmentId;
  final Map<String, dynamic> qrData;

  const PaymentSuccessScreen({
    super.key,
    required this.appointmentId,
    required this.qrData,
  });

  @override
  State<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState
    extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<Offset> _slide;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _slide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _confettiController.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: Stack(
        alignment: Alignment.center,
        children: [

          /// ✅ FIX: SCROLLABLE CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  const SizedBox(height: 20),

                  /// ✅ CHECK ICON
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 60,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ✅ TITLE
                  const Text(
                    "Payment Successful!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ✅ ID
                  Text(
                    "ID: ${widget.appointmentId}",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 25),

                  /// ✅ QR CARD
                  SlideTransition(
                    position: _slide,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                          )
                        ],
                      ),
                      child: Column(
                        children: [

                          /// ✅ FIXED QR
                          QrImageView(
                            data: widget.appointmentId,
                            size: 200,
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Scan at clinic",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ✅ DETAILS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Doctor: ${widget.qrData['doctor']}"),
                        Text("Date: ${widget.qrData['date']}"),
                        Text("Time: ${widget.qrData['time']}"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ✅ BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F7B8E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.popUntil(
                            context, (route) => route.isFirst);
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30), // ✅ VERY IMPORTANT FIX
                ],
              ),
            ),
          ),

          /// 🎉 CONFETTI
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.2,
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 0,
              emissionFrequency: 0.03,
              numberOfParticles: 10,
              gravity: 0.2,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi,
              emissionFrequency: 0.03,
              numberOfParticles: 10,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}