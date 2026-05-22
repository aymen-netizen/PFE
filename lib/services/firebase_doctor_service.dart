import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDoctorService {
  Stream<List<Map<String, dynamic>>> doctorsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          ...data,
          'uid': doc.id, // ✅ CRUCIAL (doctorId source)
        };
      }).toList();
    });
  }
}