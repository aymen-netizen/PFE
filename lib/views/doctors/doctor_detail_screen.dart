import 'package:flutter/material.dart';
import '../../../models/doctor.dart';
import '../../../core/constants/app_Color.dart';
import '../../../widget/buttons/primary_button.dart';
import '../booking/firebase_booking_screen.dart';

class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(doctor.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with photo
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.primaryColor.withOpacity(0.1),
              child: Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                  backgroundImage: AssetImage(
                    doctor.photoUrl.isNotEmpty
                        ? doctor.photoUrl
                        : 'assets/doctors/doctor1.jpg',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          doctor.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          Text('${doctor.rating} (${doctor.reviewsCount})'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctor.specialty,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (doctor.location.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(doctor.location,
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  if (doctor.phone.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(doctor.phone,
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Prendre RDV',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FirebaseBookingScreen(doctor: doctor.toMap()),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'À propos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${doctor.name} est spécialiste en ${doctor.specialty.toLowerCase()}. '
                    'Avec ${doctor.reviewsCount} avis et une note de ${doctor.rating}/5, '
                    'il/elle est parmi les meilleurs de la région.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}