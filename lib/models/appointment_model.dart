import 'package:equatable/equatable.dart';
import 'user_model.dart';
import 'doctor_model.dart';

class AppointmentModel extends Equatable {
  final int id;
  final String date;
  final String time;
  final String status;
  final int patientId;
  final int doctorId;

  final UserModel? patient;
  final DoctorModel? doctor;

  // Patient pre-consultation
  final String? reason;
  final List<dynamic>? symptoms;
  final String? notes;

  // Doctor consultation
  final String? diagnosis;
  final String? doctorNotes;

  // ✅ New checklist-based fields
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
    this.patient,
    this.doctor,
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

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'pending',
      patientId: json['patientId'] ?? 0,
      doctorId: json['doctorId'] ?? 0,

      // Relations (Sequelize aliases)
      patient: json['User'] != null
          ? UserModel.fromJson(json['User'])
          : null,
      doctor: json['Doctor'] != null
          ? DoctorModel.fromJson(json['Doctor'])
          : null,

      // Patient form
      reason: json['reason'],
      symptoms: json['symptoms'] is List ? json['symptoms'] : null,
      notes: json['notes'],

      // Doctor data
      diagnosis: json['diagnosis'],
      doctorNotes: json['doctorNotes'],

      // ✅ Checklist JSON
      medicationsJson:
          json['medicationsJson'] is List ? json['medicationsJson'] : null,
      analysesJson:
          json['analysesJson'] is List ? json['analysesJson'] : null,
      imagingJson:
          json['imagingJson'] is List ? json['imagingJson'] : null,
      vaccinesJson:
          json['vaccinesJson'] is List ? json['vaccinesJson'] : null,
      recommendationsJson:
          json['recommendationsJson'] is List ? json['recommendationsJson'] : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        time,
        status,
        patientId,
        doctorId,
        patient,
        doctor,
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