import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "PetCareDB.db";
  static final _databaseVersion = 1;
  static final _tableName = "pet_data";
  static final _tipTableName = "dog_tips";
  static final _illnessTableName = "illness_symptoms";

  static Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) {
        db.execute(
          """
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY,
            name TEXT,
            foodPeriod INTEGER,
            waterPeriod INTEGER,
            playPeriod INTEGER,
            walkPeriod INTEGER,
            foodLeft INTEGER,
            image TEXT
          )
          """
        );
        db.execute(
          """
          CREATE TABLE $_tipTableName(
            tip_id INTEGER PRIMARY KEY,
            tip_content TEXT
          )
          """
        );
        db.execute(
          """
          CREATE TABLE $_illnessTableName(
            illness_name TEXT,
            symptom TEXT
          )
          """
        );
        _insertDogTips(db);
        _insertIllnessSymptoms(db);
      },
      version: _databaseVersion,
    );
  }

  static Future<void> _insertDogTips(Database db) async {
    List<String> dogTips = [
      'Make sure your dog gets regular exercise.',
      'Feed your dog high-quality dog food.',
      'Always have fresh water available for your dog.',
      'Brush your dog\'s teeth to maintain oral health.',
     ];

    for (int i = 0; i < dogTips.length; i++) {
      await db.insert(_tipTableName, {
        'tip_id': i + 1,
        'tip_content': dogTips[i],
      });
    }
  }

  static Future<void> _insertIllnessSymptoms(Database db) async {
    List<Map<String, String>> illnessSymptoms = [
      {'illness_name': 'Kennel Cough', 'symptom': 'Coughing'},
      {'illness_name': 'Heartworm Disease', 'symptom': 'Coughing'},
      {'illness_name': 'Parvovirus', 'symptom': 'Vomiting'},
      {'illness_name': 'Gastroenteritis', 'symptom': 'Vomiting'},
      {'illness_name': 'Allergies', 'symptom': 'Itching'},
      {'illness_name': 'Fleas', 'symptom': 'Itching'},
      {'illness_name': 'Skin Allergies', 'symptom': 'Itching'},
      {'illness_name': 'Cold', 'symptom': 'Fever'},
    ];

    for (var illness in illnessSymptoms) {
      await db.insert(_illnessTableName, illness);
    }
  }

  static Future<String> getRandomDogTip() async {
    final db = await _getDatabase();
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tipTableName')
    );

    if (count != null && count > 0) {
      final randomId = Random().nextInt(count) + 1;
      final result = await db.query(
        _tipTableName,
        where: 'tip_id = ?',
        whereArgs: [randomId],
      );
      if (result.isNotEmpty) {
        return result.first['tip_content'] as String;
      }
    }
    return 'No tips available.';
  }

  static Future<List<String>> getIllnessesBySymptoms(List<String> symptoms) async {
    final db = await _getDatabase();
    List<String> matchingIllnesses = [];

    for (String symptom in symptoms) {
      final result = await db.query(
        _illnessTableName,
        where: 'symptom = ?',
        whereArgs: [symptom],
      );

      for (var row in result) {
        if (!matchingIllnesses.contains(row['illness_name'])) {
          matchingIllnesses.add(row['illness_name'] as String);
        }
      }
    }

    return matchingIllnesses;
  }

 static Future<void> insertOrUpdatePetData(Map<String, dynamic> data) async {
  final db = await _getDatabase();
   final existingData = await db.query(_tableName, where: 'id = ?', whereArgs: [data['id']]);
  
  if (existingData.isNotEmpty) {
     await db.update(_tableName, data, where: 'id = ?', whereArgs: [data['id']]);
  } else {
     await db.insert(_tableName, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}


  static Future<Map<String, dynamic>?> getPetData() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(_tableName, limit: 1);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  static Future<void> updatePetData(Map<String, dynamic> data) async {
    final db = await _getDatabase();
    await db.update(_tableName, data, where: 'id = ?', whereArgs: [data['id']]);
  }

  static Future<void> deletePetData() async {
    final db = await _getDatabase();
    await db.delete(_tableName);
  }
}
