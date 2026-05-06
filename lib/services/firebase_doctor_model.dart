class FirebaseDoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final String phone;
  final String photoUrl;
  final double rating;
  final int reviewsCount;
  final int shiftStart;
  final int shiftEnd;
  final String? doctorUid;

  FirebaseDoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.phone,
    required this.photoUrl,
    required this.rating,
    required this.reviewsCount,
    required this.shiftStart,
    required this.shiftEnd,
    this.doctorUid,
  });

  factory FirebaseDoctorModel.fromMap(Map<String, dynamic> data) {
    return FirebaseDoctorModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      location: data['location'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      rating: (data['rating'] is int)
          ? (data['rating'] as int).toDouble()
          : (data['rating'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      shiftStart: data['shiftStart'] ?? 8,
      shiftEnd: data['shiftEnd'] ?? 12,
      doctorUid: data['doctorUid'],
    );
  }
}