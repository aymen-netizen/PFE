class Doctor {
  final String uid; // ✅ Firebase UID (very important)
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
    required this.uid,
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

  // ✅ Convert to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'specialty': specialty,
      'image': photoUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'location': location,
      'phone': phone,
      'shiftStart': shiftStart,
      'shiftEnd': shiftEnd,
      'role': 'doctor', // ✅ IMPORTANT
    };
  }

  // ✅ Create from Firestore
  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      uid: map['uid'] ?? '',
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

  // ✅ Optional: for debugging
  @override
  String toString() {
    return 'Doctor(uid: $uid, name: $name, specialty: $specialty)';
  }
}