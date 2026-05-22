import 'package:equatable/equatable.dart';

class AppointmentModel extends Equatable {
  final String id; // ✅ Firestore doc id
  final String date;
  final String time;
  final String status;

  final String patientId; // ✅ Firebase UID
  final String doctorId;  // ✅ Firebase UID

  // Patient pre-consultation
  final String? reason;
  final List<dynamic>? symptoms;
  final String? notes;

  // Doctor consultation
  final String? diagnosis;
  final String? doctorNotes;

  // ✅ Checklists
  final List<dynamic>? medicationsJson;
  final List<dynamic>? analysesJson;
  final List<dynamic>? imagingJson;
  final List<dynamic>? vaccinesJson;
  final List<dynamic>? recommendationsJson;

  const AppointmentModel({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    required this.patientId,
    required this.doctorId,
    this.reason,
    this.symptoms,
    this.notes,
    this.diagnosis,
    this.doctorNotes,
    this.medicationsJson,
    this.analysesJson,
    this.imagingJson,
    this.vaccinesJson,
    this.recommendationsJson,
  });

  // ✅ FROM FIRESTORE
  factory AppointmentModel.fromMap(String id, Map<String, dynamic> map) {
    return AppointmentModel(
      id: id,
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'pending',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      reason: map['reason'],
      symptoms: map['symptoms'] is List ? map['symptoms'] : null,
      notes: map['notes'],
      diagnosis: map['diagnosis'],
      doctorNotes: map['doctorNotes'],
      medicationsJson: map['medicationsJson'],
      analysesJson: map['analysesJson'],
      imagingJson: map['imagingJson'],
      vaccinesJson: map['vaccinesJson'],
      recommendationsJson: map['recommendationsJson'],
    );
  }

  // ✅ TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'time': time,
      'status': status,
      'patientId': patientId,
      'doctorId': doctorId,
      'reason': reason,
      'symptoms': symptoms,
      'notes': notes,
      'diagnosis': diagnosis,
      'doctorNotes': doctorNotes,
      'medicationsJson': medicationsJson,
      'analysesJson': analysesJson,
      'imagingJson': imagingJson,
      'vaccinesJson': vaccinesJson,
      'recommendationsJson': recommendationsJson,
    };
  }

  @override
  List<Object?> get props => [
        id,
        date,
        time,
        status,
        patientId,
        doctorId,
        reason,
        symptoms,
        notes,
        diagnosis,
        doctorNotes,
        medicationsJson,
        analysesJson,
        imagingJson,
        vaccinesJson,
        recommendationsJson,
      ];
}
