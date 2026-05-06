import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ DOCTOR STREAM (ALREADY WORKING)
  Stream<List<Map<String, dynamic>>> doctorAppointmentsStream() async* {
    final user = _auth.currentUser;

    if (user == null) {
      yield [];
      return;
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final doctorSpecialty = userDoc.data()?['specialty'];
    print("🔵 Doctor specialty: $doctorSpecialty");

    if (doctorSpecialty == null) {
      yield [];
      return;
    }

    final snapshots = _firestore.collection('appointments').snapshots();

    await for (final snapshot in snapshots) {
      final list = snapshot.docs.where((doc) {
        final data = doc.data();

        final apptSpecialty =
            (data['specialty'] ?? '').toString().toLowerCase();

        final status = (data['status'] ?? '').toString();

        if (apptSpecialty != doctorSpecialty.toString().toLowerCase()) {
          return false;
        }

        if (status == 'cancelled') {
          return false;
        }

        return true;
      }).map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      print("✅ Doctor list: ${list.length}");
      yield list;
    }
  }

  // ✅ ✅ ✅ NEW: ASSISTANT STREAM (SAME LOGIC)
  Stream<List<Map<String, dynamic>>> assistantAppointmentsStream() async* {
    final user = _auth.currentUser;

    if (user == null) {
      yield [];
      return;
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final assistantSpecialty = userDoc.data()?['specialty'];

    print("🟣 Assistant specialty: $assistantSpecialty");

    if (assistantSpecialty == null) {
      yield [];
      return;
    }

    final snapshots = _firestore.collection('appointments').snapshots();

    await for (final snapshot in snapshots) {
      final list = snapshot.docs.where((doc) {
        final data = doc.data();

        final apptSpecialty =
            (data['specialty'] ?? '').toString().toLowerCase();

        final status = (data['status'] ?? '').toString();

        print("🟢 Appointment specialty: ${data['specialty']}");

        if (apptSpecialty !=
            assistantSpecialty.toString().toLowerCase()) {
          return false;
        }

        if (status == 'cancelled') {
          return false;
        }

        return true;
      }).map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      print("✅ Assistant list: ${list.length}");
      yield list;
    }
  }

  // ✅ COMPLETE CONSULTATION
  Future<void> completeConsultation({
    required String appointmentId,
    required String diagnosis,
    required String doctorNotes,
    required List<String> medications,
    required List<String> analyses,
    required List<String> imaging,
    required List<String> vaccines,
    required List<String> recommendations,
  }) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'diagnosis': diagnosis,
      'doctorNotes': doctorNotes,
      'medications': medications,
      'analyses': analyses,
      'imaging': imaging,
      'vaccines': vaccines,
      'recommendations': recommendations,
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  Stream<Map<String, int>> dashboardStatsStream() async* {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    yield {};
    return;
  }

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final specialty = userDoc.data()?['specialty'];

  final snapshots =
      FirebaseFirestore.instance.collection('appointments').snapshots();

  final now = DateTime.now();

  final today =
      "${now.year.toString().padLeft(4, '0')}-"
      "${now.month.toString().padLeft(2, '0')}-"
      "${now.day.toString().padLeft(2, '0')}";

  await for (final snapshot in snapshots) {
    int totalToday = 0;
    int completed = 0;
    int pending = 0;
    int cancelled = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final apptSpecialty =
          (data['specialty'] ?? '').toString().toLowerCase();

      final status = (data['status'] ?? '').toString();
      final date = (data['date'] ?? '').toString();

      if (apptSpecialty != specialty.toString().toLowerCase()) continue;

      if (date.contains(today)) totalToday++;

      if (status == 'completed') completed++;
      if (status == 'pending' || status == 'confirmed') pending++;
      if (status == 'cancelled') cancelled++;
    }

    yield {
      'today': totalToday,
      'completed': completed,
      'pending': pending,
      'cancelled': cancelled,
    };
  }
}
}