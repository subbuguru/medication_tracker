// database_service.dart
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';
import 'package:result_dart/result_dart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const _databaseName = "MedicationDatabase.db";
  static const _databaseVersion = 3;

  static const medicationTable = 'medication_table';
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
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.transaction((txn) async {
      if (oldVersion < 3) {
        await txn.execute('''
          CREATE TABLE $profileTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            dob TEXT NOT NULL,
            pcp TEXT,
            healthConditions TEXT,
            pharmacy TEXT
          )
        ''');

        await txn.execute(
            'ALTER TABLE $medicationTable ADD COLUMN profile_id INTEGER REFERENCES $profileTable(id)');

        String oldProfilePath =
            join(await getDatabasesPath(), "UserProfileDatabase.db");
        int defaultProfileId;

        if (await databaseExists(oldProfilePath)) {
          Database oldProfileDb = await openDatabase(oldProfilePath);
          List<Map<String, dynamic>> oldProfiles =
              await oldProfileDb.query('profile_table');

          defaultProfileId = oldProfiles.isNotEmpty
              ? await txn.insert(profileTable, oldProfiles[0])
              : await txn.insert(profileTable, {
                  'name': 'Default Profile',
                  'dob': DateTime.now().toIso8601String(),
                  'pcp': '',
                  'healthConditions': '',
                  'pharmacy': ''
                });

          await oldProfileDb.close();
          await deleteDatabase(oldProfilePath);
        } else {
          defaultProfileId = await txn.insert(profileTable, {
            'name': 'Default Profile',
            'dob': DateTime.now().toIso8601String(),
            'pcp': '',
            'healthConditions': '',
            'pharmacy': ''
          });
        }

        await txn.execute(
            'UPDATE $medicationTable SET profile_id = ?', [defaultProfileId]);
      }
    });
  }

// Profile Methods
  Future<Result<List<UserProfile>>> getAllProfiles() async {
    try {
      Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(profileTable);
      return Success(
          List.generate(maps.length, (i) => UserProfile.fromMap(maps[i])));
    } catch (e) {
      return Failure(Exception('Failed to get all profiles: $e'));
    }
  }

  Future<Result<UserProfile>> getProfile(int id) async {
    try {
      Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        profileTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      return Success(UserProfile.fromMap(maps.first));
    } catch (e) {
      return Failure(Exception('Failed to get profile: $e'));
    }
  }

  Future<Result<int>> insertProfile(UserProfile profile) async {
    try {
      Database db = await database;
      final result = await db.insert(profileTable, profile.toMap());
      return Success(result);
    } catch (e) {
      return Failure(Exception('Failed to insert profile: $e'));
    }
  }

  Future<Result<int>> updateProfile(UserProfile profile) async {
    try {
      Database db = await database;
      final result = await db.update(
        profileTable,
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [profile.id],
      );
      return Success(result);
    } catch (e) {
      return Failure(Exception('Failed to update profile: $e'));
    }
  }

  Future<Result<int>> deleteProfile(int id) async {
    try {
      Database db = await database;
      final result = await db.delete(
        profileTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      return Success(result);
    } catch (e) {
      return Failure(Exception('Failed to delete profile: $e'));
    }
  }

// Medication Methods
  Future<Result<List<Medication>>> getMedications(int profileId) async {
    try {
      Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        medicationTable,
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );
      return Success(
          List.generate(maps.length, (i) => Medication.fromMap(maps[i])));
    } catch (e) {
      return Failure(Exception('Failed to get medications: $e'));
    }
  }

  Future<Result<int>> insertMedication(Medication medication) async {
    try {
      Database db = await database;
      final result = await db.insert(medicationTable, medication.toMap());
      return Success(result);
    } catch (e) {
      return Failure(Exception('Failed to insert medication: $e'));
    }
  }

  Future<Result<int>> updateMedication(Medication medication) async {
    try {
      Database db = await database;
      final result = await db.update(
        medicationTable,
        medication.toMap(),
        where: 'id = ?',
        whereArgs: [medication.id],
      );
      return Success(result);
    } catch (e) {
      return Failure(Exception('Failed to update medication: $e'));
    }
  }

  Future<Result<int>> deleteMedication(int id) async {
    try {
      Database db = await database;
      final result = await db.delete(
        medicationTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      return Success(result);
    } catch (e) {
      return Failure(Exception('Failed to delete medication: $e'));
    }
  }
}
