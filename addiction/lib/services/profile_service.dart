import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileService {
  static const String _storageKey = 'user_profile';

  Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_storageKey);
    
    if (profileJson == null) {
      return null;
    }
    
    return UserProfile.fromJson(jsonDecode(profileJson));
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
  }

  Future<int> getSoberDays() async {
    final profile = await getProfile();
    if (profile == null) {
      return 0;
    }
    
    return DateTime.now().difference(profile.soberSince).inDays;
  }
}