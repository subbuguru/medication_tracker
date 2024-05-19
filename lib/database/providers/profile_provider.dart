import 'package:flutter/material.dart';
import 'package:medication_tracker/database/DatabaseHelper.dart';
import 'package:medication_tracker/database/model/user_profile_model.dart';

class ProfileProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  UserProfile? _currentProfile;
  UserProfile? get currentProfile => _currentProfile;

  ProfileProvider() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    //ADD
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    //ADD
    await loadProfile();
  }

  Future<void> deleteProfile(int id) async {
    //ADD
    notifyListeners();
  }

  void updateProfile(UserProfile profile) {
    //ADD
    notifyListeners();
  }
}
