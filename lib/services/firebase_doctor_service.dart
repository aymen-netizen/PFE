import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> doctorsStream() {
    return _firestore.collection('doctors').snapshots().map((snapshot) {
      final doctors = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      doctors.sort((a, b) {
        final nameA = (a['name'] ?? '').toString();
        final nameB = (b['name'] ?? '').toString();
        return nameA.compareTo(nameB);
      });

      return doctors;
    });
  }

  Future<List<Map<String, dynamic>>> getDoctorsOnce() async {
    final snapshot = await _firestore.collection('doctors').get();

    final doctors = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    doctors.sort((a, b) {
      final nameA = (a['name'] ?? '').toString();
      final nameB = (b['name'] ?? '').toString();
      return nameA.compareTo(nameB);
    });

    return doctors;
  }
}