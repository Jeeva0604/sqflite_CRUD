import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE user(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      age INTEGER NOT NULL,
      email TEXT UNIQUE NOT NULL
    )
    ''');
  }

  // CREATE
  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert('user', user.toMap());
  }

  // READ (Get All)
  Future<List<User>> getUsers() async {
    final db = await instance.database;
    final result = await db.query('user');
    return result.map((map) => User.fromMap(map)).toList();
  }

  // UPDATE
  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      'user',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // DELETE
  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete('user', where: 'id = ?', whereArgs: [id]);
  }
}
