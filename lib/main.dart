import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_Theme.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/profile/profile_screen.dart'; // ADD THIS
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await seedDoctors(); // run once then remove

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plateforme Santé RDV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.LightTheme(),

      // ✅ ROUTES
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),  // VERY IMPORTANT

        // (optional future routes)
        // '/doctor': (context) => const DoctorDashboardScreen(),
        // '/assistant': (context) => const AssistantDashboardScreen(),
        // '/home': (context) => const PatientHomeScreen(),
      },

      home: const SplashScreen(),
    );
  }
}
