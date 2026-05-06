import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DoctorModel extends Equatable {
  final int id;
  final String name;
  final String specialty;
  final String photoUrl;
  final double rating;
  final int reviewsCount;
  final String location;
  final String phone;
  final dynamic availability;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.photoUrl = '',
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.location = '',
    this.phone = '',
    this.availability,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviewsCount'] ?? 0,
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      availability: json['availability'],
    );
  }

  ImageProvider get photo {
    if (photoUrl.isEmpty) return const AssetImage('assets/doctors/doctor1.jpg');
    if (photoUrl.startsWith('assets/')) return AssetImage(photoUrl);
    return NetworkImage(photoUrl) as ImageProvider;
  }

  @override
  List<Object?> get props => [id, name, specialty, photoUrl, rating, reviewsCount, location, phone];
}

class DoctorsResponse {
  final List<DoctorModel> data;

  DoctorsResponse(this.data);

  factory DoctorsResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<DoctorModel> doctorsList =
        list.map((i) => DoctorModel.fromJson(i)).toList();
    return DoctorsResponse(doctorsList);
  }
}