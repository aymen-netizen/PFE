import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedDoctors() async {
  final db = FirebaseFirestore.instance;

  final Map<String, List<String>> doctorsBySpecialty = {
    'Dentiste': [
      'Dr Farouk Saied',
      'Dr Amine Ben Ali',
      'Dr Salma Trabelsi',
      'Dr Youssef Khlifi',
      'Dr Mariem Gharbi',
    ],
    'Cardiologue': [
      'Dr Ahmed Trabelsi',
      'Dr Sami Ben Youssef',
      'Dr Ons Mejri',
      'Dr Khaled Mhiri',
      'Dr Walid Karray',
    ],
    'Generaliste': [
      'Dr Lina Mansour',
      'Dr Hatem Jaziri',
      'Dr Soumaya Abid',
      'Dr Fares Kammoun',
      'Dr Ines Bouaziz',
    ],
    'Dermatologue': [
      'Dr Rania Ghedira',
      'Dr Mehdi Charfi',
      'Dr Sarra Ben Amor',
      'Dr Imed Hammami',
      'Dr Nadia Zitouni',
    ],
  };

  for (var specialty in doctorsBySpecialty.keys) {
    for (var doctorName in doctorsBySpecialty[specialty]!) {
      await db.collection('doctors').add({
        'name': doctorName,
        'specialty': specialty,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  print('✅ All doctors inserted successfully');
}