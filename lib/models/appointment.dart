class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final String time;
  final String status; // pending, confirmed, completed, cancelled

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
  });
}

List<Appointment> mockAppointments = [
  Appointment(
    id: '1',
    doctorName: 'Dr. Marie Dupon',
    specialty: 'Médecine générale',
    date: DateTime.now().add(const Duration(days: 2)),
    time: '10:00',
    status: 'confirmed',
  ),
  Appointment(
    id: '2',
    doctorName: 'Dr. Jean Martin',
    specialty: 'Dentiste',
    date: DateTime.now().add(const Duration(days: 5)),
    time: '14:30',
    status: 'pending',
  ),
];

List<Appointment> userAppointments = List<Appointment>.from(mockAppointments);

