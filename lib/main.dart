import 'package:flutter/material.dart';
import 'package:medication_tracker/providers/fda_api_provider.dart';

import 'package:medication_tracker/providers/medication_provider.dart';

import 'package:medication_tracker/ui/homeview.dart';
//import provider
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MedicationProvider()),
        ChangeNotifierProvider(create: (context) => FDAAPIServiceProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,

        // Setting the popup menu theme
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.black, // Default popup menu background color
          textStyle:
              TextStyle(color: Colors.white), // Text color for popup menu items
        ),
      ),
      home: HomeScreen(),
    );
  }
}
