class Appointment {
  final String id;
  final String doctorId; // ✅ IMPORTANT
  final String doctorName;
  final String specialty;
  final DateTime date;
  final String time;
  final String status;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      specialty: map['specialty'] ?? '',
      date: DateTime.parse(map['date']),
      time: map['time'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
    };
  }
}