import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qr_result_screen.dart';

import 'package:mobile_scanner/mobile_scanner.dart';


class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {

  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),

      body: MobileScanner(
  onDetect: (capture) async {

    if (scanned) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty) return;

    final String? id = barcodes.first.rawValue;

    if (id == null) return;

    scanned = true;

    // ✅ FETCH FROM FIRESTORE
    final doc = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(id)
        .get();

    if (!doc.exists) {
      scanned = false;
      return;
    }

    final data = doc.data();

    if (data == null) {
      scanned = false;
      return;
    }

    // ✅ NAVIGATE TO RESULT
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRResultScreen(data: data),
      ),
    );

    scanned = false;
  },
)
    );
  }
}
