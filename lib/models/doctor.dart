class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String photoUrl;
  final double rating;
  final int reviewsCount;
  final String location;
  final String phone;
  final int? shiftStart;
  final int? shiftEnd;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.photoUrl,
    required this.rating,
    required this.reviewsCount,
    required this.location,
    required this.phone,
    this.shiftStart,
    this.shiftEnd,
  });

  // ✅ ✅ FIX YOUR ERROR (MOST IMPORTANT)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'image': photoUrl, // ✅ important (match UI)
      'rating': rating,
      'reviewsCount': reviewsCount,
      'location': location,
      'phone': phone,
      'shiftStart': shiftStart,
      'shiftEnd': shiftEnd,
    };
  }

  // ✅ OPTIONAL BUT VERY USEFUL
  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      photoUrl: map['image'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
      shiftStart: map['shiftStart'],
      shiftEnd: map['shiftEnd'],
    );
  }
}


List<Doctor> mockDoctors = [];