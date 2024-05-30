import 'package:flutter/material.dart';
import 'package:medication_tracker/database/DatabaseHelper.dart';
import 'package:medication_tracker/database/model/user_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  UserProfile? _currentProfile;
  List<UserProfile> _profiles = [];

  UserProfile? get currentProfile => _currentProfile;
  List<UserProfile> get profiles => _profiles;

  ProfileProvider() {
    loadProfile();
    loadAllProfiles();
  }

  Future<void> loadProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? currentProfileId = prefs.getInt('currentProfileId');

    if (currentProfileId == null) {
      prefs.setInt('currentProfileId', 1);
      _currentProfile = await _dbHelper.getProfile(1);
    } else {
      _currentProfile = await _dbHelper.getProfile(currentProfileId);
    }
    notifyListeners();
  }

  Future<void> loadAllProfiles() async {
    try {
      _profiles = await _dbHelper.getAllProfiles();
      notifyListeners();
    } catch (e) {
      throw DatabaseException('Failed to load profiles: $e');
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _dbHelper.insertProfile(profile);
    await loadAllProfiles();
  }

  Future<void> deleteProfile(int id) async {
    await _dbHelper.deleteProfile(id);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? currentProfileId = prefs.getInt('currentProfileId');
    if (currentProfileId == id) {
      prefs.setInt('currentProfileId', 1);
      _currentProfile = await _dbHelper.getProfile(1);
    }
    await loadAllProfiles();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _dbHelper.updateProfile(profile);
    await loadAllProfiles();
    notifyListeners();
  }

  Future<void> changeCurrentProfile(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentProfileId', id);
    await loadProfile();
  }
}
