// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/setup_profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/record_craving_screen.dart';
import 'screens/craving_history_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/setup_profile_screen.dart';
import 'services/profile_service.dart';
import 'models/user_profile.dart';
import 'screens/craving_prediction_screen.dart'; // Add this import



void main() {
  runApp(RecoveryApp());
}

class RecoveryApp extends StatelessWidget {
  final ProfileService _profileService = ProfileService();

  RecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recovery Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: FutureBuilder<UserProfile?>(
        future: _profileService.getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Si le profil existe, aller à l'écran d'accueil, sinon configurer le profil
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          } else {
            return const SetupProfileScreen();
          }
        },
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/record-craving': (context) => const RecordCravingScreen(),
        '/history': (context) => const CravingHistoryScreen(),
        '/emergency': (context) => EmergencyScreen(),
        '/profile': (context) => const SetupProfileScreen(),
        '/prediction': (context) => CravingPredictionScreen(), // Add this route
        

      },
    );
  }
}