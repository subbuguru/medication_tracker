import 'package:flutter/material.dart';
import 'package:medication_tracker/models/medication_model.dart';

class MedicationTile extends StatelessWidget {
  final Medication medication;

  MedicationTile({
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${medication.name} - ${medication.dosage}',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                //SizedBox(height: 4),
                Text(
                  medication.additionalInfo,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Theme(
            data: // Change the color of the popup menu
                Theme.of(context).copyWith(),
            child: PopupMenuButton<String>(
              onSelected: (String result) {
                // Handle menu selection
              },
              shape: RoundedRectangleBorder(
                // Making the popup menu rounded
                borderRadius: BorderRadius.circular(16.0),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red), // Red trash icon
                      SizedBox(width: 8), // Space between icon and text
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Change background color
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
