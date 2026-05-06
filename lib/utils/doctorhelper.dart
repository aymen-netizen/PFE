final Map<String, List<String>> doctorsBySpecialty = {
  'dentiste': [
    'Dr Farouk Saied',
    'Dr Amine Ben Ali',
    'Dr Salma Trabelsi',
    'Dr Youssef Khlifi',
    'Dr Mariem Gharbi',
  ],
  'cardiologue': [
    'Dr Ahmed Trabelsi',
    'Dr Sami Ben Youssef',
    'Dr Ons Mejri',
    'Dr Khaled Mhiri',
    'Dr Walid Karray',
  ],
  'generaliste': [
    'Dr Lina Mansour',
    'Dr Hatem Jaziri',
    'Dr Soumaya Abid',
    'Dr Fares Kammoun',
    'Dr Ines Bouaziz',
  ],
  'dermatologue': [
    'Dr Rania Ghedira',
    'Dr Mehdi Charfi',
    'Dr Sarra Ben Amor',
    'Dr Imed Hammami',
    'Dr Nadia Zitouni',
  ],
};

String getDoctorNameFromSpecialty(String specialty, int index) {
  final list = doctorsBySpecialty[specialty.toLowerCase()];

  if (list == null || list.isEmpty) {
    return 'Doctor';
  }

  return list[index % list.length];
}