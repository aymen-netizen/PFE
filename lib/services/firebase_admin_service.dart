import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<List<Map<String, dynamic>>> streamUsersByRole(String role) {
    return _usersCollection
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = (data['status'] ?? 'active').toString();
            return {
              'uid': doc.id,
              ...data,
              'status': status,
            };
          })
          .where((data) => data['status'] != 'deleted')
          .toList();
    });
  }

  Stream<int> countUsersByRole(String role) {
    return streamUsersByRole(role).map((users) => users.length);
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return {
      'uid': doc.id,
      ...data,
      'status': (data['status'] ?? 'active').toString(),
    };
  }

  Future<void> createUser({
    required String role,
    required String name,
    required String email,
    required String phone,
    required String password,
    String specialty = '',
  }) async {
    // Create Firebase Auth account
    final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = authResult.user!.uid;

    // Create Firestore user document with the Auth uid
    await _usersCollection.doc(uid).set({
      'uid': uid,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'role': role,
      'specialty': specialty.trim(),
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUser({
    required String uid,
    required String name,
    required String email,
    required String phone,
    String specialty = '',
    String? status,
  }) async {
    final updateData = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'specialty': specialty.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status != null) {
      updateData['status'] = status;
    }

    await _usersCollection.doc(uid).update(updateData);
  }

  Future<void> deleteUser(String uid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    await _usersCollection.doc(uid).update({
      'status': 'deleted',
      'deletedAt': FieldValue.serverTimestamp(),
      'deletedBy': currentUser?.uid,
    });
  }
}