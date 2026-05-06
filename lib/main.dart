import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_Theme.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'firebase_options.dart';

// ✅ OPTIONAL (TEMP: for seeding doctors)
import 'utils/seed_doctors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ RUN ONCE TO ADD DOCTORS (THEN REMOVE)
  // await seedDoctors();  // ⚠️ uncomment → run once → remove

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

      // ✅ ROUTES (READY FOR PHASE 3)
      routes: {
        '/login': (context) => const LoginScreen(),

        // ✅ future (you will use these next)
        // '/doctor': (context) => const DoctorDashboardScreen(),
        // '/assistant': (context) => const AssistantDashboardScreen(),
        // '/home': (context) => const PatientHomeScreen(),
      },

      home: const SplashScreen(),
    );
  }
}