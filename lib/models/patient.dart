class Patient {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<String> appointments; // appointment IDs
  final DateTime registrationDate;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.appointments = const [],
    required this.registrationDate,
  });

  Patient copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    List<String>? appointments,
    DateTime? registrationDate,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      appointments: appointments ?? this.appointments,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }
}

