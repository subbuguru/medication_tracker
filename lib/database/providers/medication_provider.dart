import 'package:flutter/material.dart';
import 'package:medication_tracker/services/camera/CameraService.dart';
import 'package:medication_tracker/database/DatabaseHelper.dart';
import 'package:medication_tracker/database/model/medication_model.dart';

class MedicationProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<Medication> _medications = [];
  bool _isLoading = false;

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;

  MedicationProvider() {
    loadMedications();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  //load medications based on given profileId
  Future<void> loadMedications(int profileId) async {
    setLoading(true);
    try {
      List<Medication> loadedMedications =
          await _databaseHelper.getMedications(profileId);

      // Adjust image paths for each medication
      List<Future> imagePathAdjustments = [];
      for (var medication in loadedMedications) {
        if (medication.imageUrl.isNotEmpty) {
          imagePathAdjustments.add(
            CameraHelper.getImagePath(medication.imageUrl).then((path) {
              medication.imageUrl = path;
            }),
          );
        }
      }

      // Wait for all image path adjustments to complete
      await Future.wait(imagePathAdjustments);

      _medications = loadedMedications;
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> addMedication(Medication medication) async {
    await _databaseHelper.insertMedication(medication);
    await loadMedications();
  }

  Future<void> updateMedication(Medication medication) async {
    await _databaseHelper.updateMedication(medication);
    await loadMedications();
  }

  Future<void> deleteMedication(int id) async {
    await _databaseHelper.deleteMedication(id);
    await loadMedications();
  }
}
