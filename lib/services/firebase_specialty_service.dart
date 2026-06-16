import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSpecialtyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _specialtiesCollection =
      FirebaseFirestore.instance.collection('specialties');

  String _normalize(String value) => value.trim().toLowerCase();

  List<Map<String, dynamic>> _mergeSpecialties(List<Map<String, dynamic>> rawEntries) {
    final Map<String, Map<String, dynamic>> map = {};
    for (final raw in rawEntries) {
      final name = (raw['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;

      final normalized = _normalize(name);
      if (map.containsKey(normalized)) continue;

      map[normalized] = {
        'name': name,
        'docId': raw['docId'],
      };
    }
    return map.values.toList();
  }

  List<Map<String, dynamic>> _mapSpecialties(List<Map<String, dynamic>> entries) {
    final sortedEntries = entries
      ..sort((a, b) {
        final aName = (a['name'] ?? '').toLowerCase();
        final bName = (b['name'] ?? '').toLowerCase();
        return aName.compareTo(bName);
      });

    return sortedEntries
        .map((entry) => {
              'name': entry['name'] ?? '',
              'uid': _normalize(entry['name'] ?? ''),
              'docId': entry['docId'],
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _buildSpecialtyMap() async {
    final collectionSnapshot = await _specialtiesCollection.get();
    final collectionNames = collectionSnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'name': data['name'] ?? '',
            'docId': doc.id,
          };
        })
        .toList();

    final doctorsSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .get();
    final doctorNames = doctorsSnapshot.docs
        .map((doc) {
          final data = doc.data();
          return {
            'name': data['specialty'] ?? '',
            'docId': null,
          };
        })
        .toList();

    return _mergeSpecialties([...collectionNames, ...doctorNames]);
  }

  Stream<List<Map<String, dynamic>>> streamSpecialties() {
    return _specialtiesCollection.snapshots().asyncMap((snapshot) async {
      final collectionNames = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'name': data['name'] ?? '',
              'docId': doc.id,
            };
          }).toList();

      final doctorsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();
      final doctorNames = doctorsSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'name': data['specialty'] ?? '',
              'docId': null,
            };
          }).toList();

      final entries = _mergeSpecialties([...collectionNames, ...doctorNames]);
      return _mapSpecialties(entries);
    });
  }

  Stream<List<Map<String, dynamic>>> streamSpecialtyCollection() {
    return _specialtiesCollection.snapshots().map((snapshot) {
      final entries = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final rawName = data['name'];
        return {
          'name': rawName is String ? rawName : '',
          'uid': doc.id,
          'docId': doc.id,
        };
      }).toList();
      entries.sort((a, b) => (a['name'] as String).toLowerCase().compareTo((b['name'] as String).toLowerCase()));
      return entries;
    });
  }

  Future<List<Map<String, dynamic>>> getSpecialties() async {
    final map = await _buildSpecialtyMap();
    return _mapSpecialties(map);
  }

  Future<void> createSpecialty(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;

    final normalized = _normalize(trimmedName);
    final existing = await _specialtiesCollection.get();
    final exists = existing.docs.any((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final docName = data['name'] is String ? data['name'] as String : '';
      return _normalize(docName) == normalized;
    });

    if (exists) {
      throw Exception('This specialty already exists');
    }

    await _specialtiesCollection.add({
      'name': trimmedName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSpecialty(String uid, String name) async {
    await _specialtiesCollection.doc(uid).update({
      'name': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSpecialty(String uid) async {
    await _specialtiesCollection.doc(uid).delete();
  }

  Future<int> countSpecialties() async {
    final snapshot = await _specialtiesCollection.get();
    return snapshot.docs.length;
  }
}
