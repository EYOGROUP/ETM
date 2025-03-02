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
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute(
              ''' CREATE TABLE IF NOT EXISTS categories (id TEXT KEY TEXT ,isUnlocked INTEGER NOT NULL,isPremium INTEGER NOT NULL,,unlockExpiry TEXT NOT NULL) ''');
          // 2. Create a new tracking_sessions table with the foreign key
          await db.execute('''
      CREATE TABLE tracking_sessions_new (
        id TEXT PRIMARY KEY,
        startTime TEXT NOT NULL,
         trackingSessionId TEXT UNIQUE, 
        endTime TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
      breakTimeMinutes INTEGER DEFAULT 0,
       taskDescription TEXT,
       createdAt TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        categoryId TEXT NOT NULL,
        isSplit INTEGER NOT NULL,
        FOREIGN KEY(categoryId) REFERENCES categories(id) ON DELETE SET NULL
      );
    ''');

          // 3. Copy data from the old tracking_sessions table to the new one (only the necessary columns)
          await db.execute('''
      INSERT INTO tracking_sessions_new (id, startTime, trackingSessionId, endTime, isCompleted, categoryId)
      SELECT id, startTime, endTime, isCompleted,isSplit, categoryId FROM tracking_sessions;
    ''');

          // 4. Drop the old tracking_sessions table
          await db.execute('DROP TABLE IF EXISTS tracking_sessions');

          // 5. Rename the new tracking_sessions table to the original name
          await db.execute(
              'ALTER TABLE tracking_sessions_new RENAME TO tracking_sessions');

          ///
          const breakSessionTable =
              ''' CREATE TABLE break_sessions (id TEXT PRIMARY KEY ,trackingSessionId TEXT NOT NULL, startTime TEXT NOT NULL, isCompleted INTEGER NOT NULL, endTime TEXT NOT NULL,durationMinutes INTEGER NOT NULL,reason TEXT,createdAt TEXT NOT NULL, isSplit INTEGER NOT NULL,FOREIGN KEY(trackingSessionId) REFERENCES tracking_sessions(trackingSessionId) ON DELETE CASCADE )''';
          await db.execute(breakSessionTable);
        }
      },
    );
    return database;
  }

  Future<void> _onConfigure(Database database) async {
    await database.execute("PRAGMA foreign_keys = ON");
  }

  _onCreate(Database db, int version) async {
    // When creating the db, create the table
    const categoriesTable =
        ''' CREATE TABLE categories (id TEXT PRIMARY KEY,isUnlocked INTEGER NOT NULL,isPremium INTEGER NOT NULL,unlockExpiry TEXT NOT NULL) ''';

    const trackingSessionTable =
        ''' CREATE TABLE tracking_sessions (id TEXT PRIMARY KEY , startTime TEXT NOT NULL, trackingSessionId TEXT UNIQUE  ,endTime TEXT NOT NULL,durationMinutes INTEGER NOT NULL,
      breakTimeMinutes INTEGER DEFAULT 0, taskDescription TEXT, createdAt TEXT NOT NULL, isCompleted INTEGER NOT NULL,categoryId TEXT NOT NULL,isSplit INTEGER NOT NULL, FOREIGN KEY(categoryId) REFERENCES categories(id) ON DELETE SET NULL )''';
    const breakSessionTable =
        ''' CREATE TABLE break_sessions (id TEXT PRIMARY KEY ,trackingSessionId TEXT NOT NULL, isCompleted INTEGER NOT NULL, startTime TEXT NOT NULL, endTime TEXT NOT NULL,durationMinutes INTEGER NOT NULL,reason TEXT,createdAt TEXT NOT NULL,isSplit INTEGER NOT NULL, FOREIGN KEY(trackingSessionId) REFERENCES tracking_sessions(trackingSessionId) ON DELETE CASCADE )''';
    if (version == 1) {
      await db.execute(trackingSessionTable);
      await db.execute(breakSessionTable);
      await db.execute(categoriesTable);
    }
  }

  Future<bool> doesTableExist(String tableName) async {
    Database? myDB = await db;
    final result = await myDB?.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]);
    return result!.isNotEmpty;
  }

  Future<int> insertData(
      {required String tableName, required Map<String, dynamic> data}) async {
    Database? myDB = await db;
    int response = await myDB!
        .insert(tableName, data, conflictAlgorithm: ConflictAlgorithm.replace);
    await myDB.close();
    return response;
  }

  Future<List<Map<String, Object?>>> readData({required String sql}) async {
    Database? myDB = await db;
    List<Map<String, Object?>> myData = await myDB!.rawQuery(sql);
    return myData;
  }

  Future<void> deleteData({required String sql}) async {
    Database? myDB = await db;
    await myDB?.execute(sql);
  }

  Future<int> updateData(
      {required String tableName,
      required Map<String, dynamic> data,
      final columnId,
      String? id}) async {
    Database? myDB = await db;
    int response = await myDB!.update(
      tableName,
      data,
      where: '$columnId=?',
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
