import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medication_tracker/constants/app_themes.dart';
import 'package:medication_tracker/data/api/fda_api_service.dart';
import 'package:medication_tracker/data/database/database.dart';
import 'package:medication_tracker/data/providers/fda_api_provider.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/services/export/pdf_service.dart';
import 'package:medication_tracker/services/image/image_service.dart';
import 'package:medication_tracker/services/permission/check_permission_service.dart';
import 'package:medication_tracker/services/storage/local_storage_service.dart';
import 'package:medication_tracker/ui/select_profile/select_profile_view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => FDAAPIService()),
        ChangeNotifierProvider(
          create: (context) => FDAAPIServiceProvider(
            apiService: context.read<FDAAPIService>(),
          ),
        ),
        Provider(create: (context) => DatabaseService()),
        ChangeNotifierProvider(
            create: (context) => ProfileProvider(
                  databaseService: context.read<DatabaseService>(),
                )),
        ChangeNotifierProxyProvider<ProfileProvider, MedicationProvider>(
          create: (context) => MedicationProvider(
            Provider.of<ProfileProvider>(context, listen: false),
            databaseService: context.read<DatabaseService>(),
          ),
          update: (context, profileProvider, previousMedicationProvider) {
            return previousMedicationProvider ??
                MedicationProvider(profileProvider,
                    databaseService: context.read<DatabaseService>());
          },
        ),
        Provider(create: (context) => ImagePicker()), // Add ImagePicker
        Provider(create: (context) => PDFService()),
        Provider(create: (context) => CheckPermissionService()),
        Provider(create: (context) => LocalStorageService()),
        Provider(
          create: (context) => ImageService(
            picker: Provider.of<ImagePicker>(context, listen: false),
            permissionService:
                Provider.of<CheckPermissionService>(context, listen: false),
            storage: Provider.of<LocalStorageService>(context, listen: false),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside of a text field
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          //showSemanticsDebugger: false,
          theme: AppThemes.lightTheme,
          themeMode: ThemeMode.system,
          home: const SelectProfilePage()),
    );
  }
}
