import 'package:flutter/material.dart';
import 'package:medication_tracker/model/fda_drug.dart';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class CreateMedicationPage extends StatefulWidget {
  final FDADrug initialDrug;

  CreateMedicationPage({required this.initialDrug});

  @override
  _CreateMedicationPageState createState() => _CreateMedicationPageState();
}

class _CreateMedicationPageState extends State<CreateMedicationPage> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _additionalInfoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text:
            "${widget.initialDrug.brandName} - ${widget.initialDrug.genericName}");
    _dosageController =
        TextEditingController(); // Initialize with appropriate data if available
    _additionalInfoController =
        TextEditingController(); // Initialize with appropriate data if available
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _accept(BuildContext context) async {
    final String name = _nameController.text;
    final String dosage = _dosageController.text;
    final String additionalInfo = _additionalInfoController.text;

    // Create a Medication object
    Medication newMedication = Medication(
      name: name,
      dosage: dosage,
      additionalInfo: additionalInfo,
    );

    // Save the medication using MedicationProvider
    try {
      await Provider.of<MedicationProvider>(context, listen: false)
          .addMedication(newMedication);
      Navigator.popUntil(
          context,
          (Route<dynamic> route) =>
              route.isFirst); // Go back to the previous screen after saving
    } catch (e) {
      // Handle errors, e.g., show a Snackbar
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving medication')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Create Medication'),
        backgroundColor: Colors.grey[200],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _dosageController,
              decoration: InputDecoration(
                labelText: 'Dosage',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _additionalInfoController,
              decoration: InputDecoration(
                labelText: 'Additional Info',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black, // Button color
                onPrimary: Colors.white, // Text color
                minimumSize: Size(double.infinity, 50), // Button size
              ),
              onPressed: () {
                // TODO: Implement the logic to add the medication
                _accept(context);
              },
              child: Text('Add Medication'),
            ),
          ],
        ),
      ),
    );
  }
}
