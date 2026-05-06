import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class FirebaseBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ GENERATE SLOTS
  List<String> generateSlots({
    required int shiftStart,
    required int shiftEnd,
  }) {
    final List<String> slots = [];

    for (int hour = shiftStart; hour < shiftEnd; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
    }

    return slots;
  }

  // ✅ AVAILABLE SLOTS
  Future<List<String>> getAvailableSlots({
    required String specialty,
    required String date,
    required int shiftStart,
    required int shiftEnd,
  }) async {
    final allSlots = generateSlots(
      shiftStart: shiftStart,
      shiftEnd: shiftEnd,
    );

    final snapshot = await _firestore
        .collection('appointments')
        .where('specialty', isEqualTo: specialty)
        .where('date', isEqualTo: date)
        .where('status', whereIn: [
      'pending',
      'confirmed',
      'checked_in',
      'in_consultation',
    ]).get();

    final takenSlots = snapshot.docs
        .map((doc) => doc.data()['time']?.toString())
        .whereType<String>()
        .toSet();

    return allSlots
        .where((slot) => !takenSlots.contains(slot))
        .toList();
  }

  // ✅ ✅ CREATE APPOINTMENT (FIXED)
  Future<String> createAppointment({
    required Map<String, dynamic> doctor,
    required String date,
    required String time,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    // ✅ ✅ USE REAL DOCTOR NAME (NO HELPER)
    final doctorName = doctor['name'] ?? 'Doctor';

    final doc = await _firestore.collection('appointments').add({
      // ✅ PATIENT
      'patientId': user.uid,
      'patientName': user.email,

      // ✅ DOCTOR
      'specialty': doctor['specialty'],
      'doctorName': doctorName,

      // ✅ EXTRA INFO
      'doctorImage': doctor['image'] ?? '',
      'location': doctor['location'] ?? '',

      // ✅ APPOINTMENT
      'date': date,
      'time': time,
      'status': 'pending',

      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }
}
