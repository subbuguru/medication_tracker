import 'package:medication_tracker/database/model/medication_model.dart';
import 'package:medication_tracker/database/model/user_profile_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// DatabaseException class for handling errors
class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => "Database Exception: $message";
}

class DatabaseHelper {
  static const _databaseName = "MedicationDatabase.db";
  static const _databaseVersion = 3;
  static const medicationTable = 'medication_table';
  static const profileTable = 'profile_table';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // Open the database and create the table
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade); // Handle upgrades
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $profileTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        pcp TEXT,
        healthConditions TEXT,
        pharmacy TEXT
      );
      CREATE TABLE $medicationTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        additionalInfo TEXT NOT NULL,
        imageUrl TEXT 
        profileId INTEGER NOT NULL, 
        FOREIGN KEY (profileId) REFERENCES $profileTable (id)
      ); 
    '''); //ensure that profileId is provided for all medications to assign them a profile
  }

  // Handle database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add imageUrl column and change id type in existing tables
      await db.execute('ALTER TABLE medication_table ADD COLUMN imageUrl TEXT');
    }
  }

  // Helper methods //

  // Profile Table Methods
  // Insert a Profile object into the database with error handling
  Future<int> insertProfile(UserProfile profile) async {
    Database db = await instance.database;
    try {
      return await db.insert(profileTable, profile.toMap());
    } catch (e) {
      throw DatabaseException('Failed to insert profile: $e');
    }
  }

  // Get a Profile object from the database with error handling
  Future<UserProfile> getProfile(int id) async {
    Database db = await instance.database;
    try {
      List<Map> maps =
          await db.query(profileTable, where: 'id = ?', whereArgs: [id]);

      return UserProfile.fromMap(maps.first as Map<String, dynamic>);
    } catch (e) {
      throw DatabaseException('Failed to load profile: $e');
    }
  }

  // Update a Profile object in the database with error handling
  Future<int> updateProfile(UserProfile profile) async {
    Database db = await instance.database;
    try {
      return await db.update(profileTable, profile.toMap(),
          where: 'id = ?', whereArgs: [profile.id]);
    } catch (e) {
      throw DatabaseException('Failed to update profile: $e');
    }
  }

  // Delete a Profile object from the database with error handling
  Future<int> deleteProfile(int id) async {
    Database db = await instance.database;
    try {
      return await db.delete(profileTable, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatabaseException('Failed to delete profile: $e');
    }
  }

  //Medication Table Methods
  // Insert a Medication object into the database with error handling
  Future<int> insertMedication(Medication medication) async {
    Database db = await instance.database;
    try {
      return await db.insert(medicationTable, medication.toMap());
    } catch (e) {
      throw DatabaseException('Failed to insert medication: $e');
    }
  }

  // Update a Medication object in the database with error handling
  Future<int> updateMedication(Medication medication) async {
    Database db = await instance.database;
    try {
      return await db.update(medicationTable, medication.toMap(),
          where: 'id = ?', whereArgs: [medication.id]);
    } catch (e) {
      throw DatabaseException('Failed to update medication: $e');
    }
  }

  // Delete a Medication object from the database with error handling
  Future<int> deleteMedication(int id) async {
    Database db = await instance.database;
    try {
      return await db.delete(medicationTable, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatabaseException('Failed to delete medication: $e');
    }
  }

  // Retrieve all Medications from a certain profileID from the database with error handling
  Future<List<Medication>> queryByProfile(int profileId) async {
    Database db = await instance.database;
    try {
      var res = await db.query(medicationTable,
          where: 'profile_id = ?', whereArgs: [profileId]);
      return res.map((c) => Medication.fromMap(c)).toList();
    } catch (e) {
      throw DatabaseException('Failed to retrieve medications: $e');
    }
  }
}
