import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

class TrackingDB {
  static Database? _db;
  Future<Database?> get db async {
    _db = await initDB();
    return _db;
  }

  initDB() async {
    // Get a location user getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'tracking.db');
    Database database = await openDatabase(
      path,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      version: 1,
    );
    return database;
  }

  Future<void> _onConfigure(Database database) async {
    await database.execute("PRAGMA foreign_keys = ON");
  }

  _onCreate(Database db, int version) async {
    // When creating the db, create the table
    const workSessionTable =
        '''CREATE TABLE work_sessions (id INTEGER PRIMARY KEY AUTOINCREMENT , startTime TEXT NOT NULL, endTime TEXT NOT NULL, isCompleted INTEGER NOT NULL)''';
    const breakSessionTable =
        '''CREATE TABLE break_sessions (id INTEGER PRIMARY KEY AUTOINCREMENT ,workSessionId, breakStartTime TEXT NOT NULL, breakEndTime TEXT NOT NULL, FOREIGN KEY(workSessionId) REFERENCES work_sessions(id) ON DELETE CASCADE )''';
    await db.execute(workSessionTable);
    await db.execute(breakSessionTable);
  }

  Future<int> insertData(
      {required String tableName, required Map<String, dynamic> data}) async {
    Database? myDB = await db;
    int response = await myDB!
        .insert(tableName, data, conflictAlgorithm: ConflictAlgorithm.replace);
    await myDB.close();
    return response;
  }

  Future<List<Map>> readData({required String sql}) async {
    Database? myDB = await db;
    List<Map> myData = await myDB!.rawQuery(sql);
    return myData;
  }

  Future<int> updateData(
      {required String tableName,
      required Map<String, dynamic> data,
      final rowId,
      int? id}) async {
    Database? myDB = await db;
    int response = await myDB!.update(
      tableName,
      data,
      where: '$rowId=?',
      whereArgs: [id],
    );
    await myDB.close();
    return response;
  }

  deleteDB() async {
    Database? myDB = await db;
    deleteDatabase(myDB!.path);
  }
}
