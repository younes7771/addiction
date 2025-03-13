// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/setup_profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/record_craving_screen.dart';
import 'screens/craving_history_screen.dart';
import 'screens/emergency_screen.dart';
import 'services/profile_service.dart';
import 'models/user_profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
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
          
          // If profile exists, go to home screen, otherwise set up profile
          if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen();
          } else {
            return SetupProfileScreen();
          }
        },
      ),
      routes: {
        '/home': (context) => HomeScreen(),
        '/record-craving': (context) => RecordCravingScreen(),
        '/history': (context) => CravingHistoryScreen(),
        '/emergency': (context) => EmergencyScreen(),
      },
    );
  }
}