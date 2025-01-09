import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const _databaseName = "CombinedDatabase.db";
  static const _databaseVersion = 1;

  static const medicationTable = 'medications';
  static const profileTable = 'profiles';

  DatabaseService();
  Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create profiles table
    await db.execute('''
      CREATE TABLE $profileTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        pcp TEXT,
        healthConditions TEXT,
        pharmacy TEXT
      )
    ''');

    // Create medications table with foreign key
    await db.execute('''
      CREATE TABLE $medicationTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        additionalInfo TEXT NOT NULL,
        imageUrl TEXT,
        FOREIGN KEY (profile_id) REFERENCES $profileTable (id) ON DELETE CASCADE
      )
    ''');

    // Migrate data from old databases
    await _migrateData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // No upgrade yet.
  }

  Future<void> _migrateData(Database db) async {
    try {
      await db.transaction((txn) async {
        print('Starting database migration...');

        // 1. Check and log old database paths
        String oldProfilePath =
            join(await getDatabasesPath(), "UserProfileDatabase.db");
        String oldMedsPath =
            join(await getDatabasesPath(), "MedicationDatabase.db");

        print('Old Profile DB path: $oldProfilePath');
        print('Old Meds DB path: $oldMedsPath');
        print('Profile DB exists: ${await databaseExists(oldProfilePath)}');
        print('Meds DB exists: ${await databaseExists(oldMedsPath)}');

        int defaultProfileId;

        // Profile migration
        try {
          if (await databaseExists(oldProfilePath)) {
            print('Opening old profile database...');
            Database oldProfileDb = await openDatabase(oldProfilePath);
            List<Map<String, dynamic>> oldProfiles =
                await oldProfileDb.query('profile_table');

            print('Found ${oldProfiles.length} profiles to migrate');

            defaultProfileId = oldProfiles.isNotEmpty
                ? await txn.insert(profileTable, oldProfiles[0])
                : await _createDefaultProfile(txn);

            print('Created/migrated profile with ID: $defaultProfileId');

            await oldProfileDb.close();
          } else {
            print('No old profile database found, creating default profile');
            defaultProfileId = await _createDefaultProfile(txn);
          }
        } catch (e) {
          print('Error during profile migration: $e');
          rethrow;
        }

        // Medication migration
        try {
          if (await databaseExists(oldMedsPath)) {
            print('Opening old medications database...');
            Database oldMedsDb = await openDatabase(oldMedsPath);
            List<Map<String, dynamic>> oldMedicationsRead =
                await oldMedsDb.query('medication_table');

            print('Found ${oldMedicationsRead.length} medications to migrate');

            for (var medicationRead in oldMedicationsRead) {
              // Create modifiable copy
              Map<String, dynamic> medication =
                  Map<String, dynamic>.from(medicationRead);
              medication['profile_id'] = defaultProfileId;
              int medId = await txn.insert(medicationTable, medication);
              print('Migrated medication ID: $medId');
            }

            await oldMedsDb.close();
          } else {
            print('No old medications database found');
          }
        } catch (e) {
          print('Error during medication migration: $e');
          rethrow;
        }

        print('Migration completed successfully');
      });
    } catch (e, stackTrace) {
      print('Fatal migration error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Migration failed: $e');
    }
  }

  Future<int> _createDefaultProfile(Transaction txn) async {
    return await txn.insert(profileTable, {
      'name': 'Default Profile',
      'dob': DateTime.now().toIso8601String(),
      'pcp': '',
      'healthConditions': '',
      'pharmacy': ''
    });
  }

  // Add methods for CRUD operations on profiles and medications
  Future<List<UserProfile>> getAllProfiles() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(profileTable);
    return List.generate(maps.length, (i) => UserProfile.fromMap(maps[i]));
  }

  Future<UserProfile?> getProfile(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      profileTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  Future<int> insertProfile(UserProfile profile) async {
    Database db = await database;
    return await db.insert(profileTable, profile.toMap());
  }

  Future<int> updateProfile(UserProfile profile) async {
    Database db = await database;
    return await db.update(
      profileTable,
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteProfile(int id) async {
    Database db = await database;
    return await db.delete(
      profileTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Medication>> getMedicationsForProfile(int profileId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      medicationTable,
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
  }

  Future<int> insertMedication(Medication medication) async {
    Database db = await database;
    return await db.insert(medicationTable, medication.toMap());
  }

  Future<int> updateMedication(Medication medication) async {
    Database db = await database;
    return await db.update(
      medicationTable,
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  Future<int> deleteMedication(int id) async {
    Database db = await database;
    return await db.delete(
      medicationTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
