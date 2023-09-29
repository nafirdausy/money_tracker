export 'DBHelper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/transaksi.dart';
import '../models/user.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE login(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
  CREATE TABLE transaksi(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tanggal TEXT,
    keterangan TEXT,
    jenis TEXT,
    jumlah REAL
  )
''');
        await db.insert("login", {'username': 'user', 'password': 'user'});
      },
    );
  }

  // Register user
  Future<void> register(String username, String password) async {
    final db = await database;

    // Check if the username already exists in the "login" table
    final existingUser = await db.query(
      'login',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (existingUser.isEmpty) {
      // C
      await db.insert(
        'login',
        {
          'username': username,
          'password': password,
        },
      );
    } else {
      throw Exception('Username already exists');
    }
  }

  // Login user
  Future<bool> login(String username, String password) async {
    final db = await database;

    // tabel "login" untuk memeriksa apakah nama pengguna dan kata sandi yang diberikan cocok
    final result = await db.query(
      'login',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return result.isNotEmpty;
  }

  // Change user password
  Future<int> changePassword(String username, String password) async {
    Database db = await database;

    int result = await db.rawUpdate(
        'UPDATE login SET password = ? WHERE username = ?',
        [password, username]);
    return result;
  }

  // Mengambil pengguna berdasarkan username
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'login',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    } else {
      return null;
    }
  }

  // Menambahkan transaksi (baik pemasukan maupun pengeluaran)
  Future<void> addTransaksi(Map<String, dynamic> transaksi) async {
    final db = await database;
    await db.insert('transaksi', transaksi);
  }

  // }
  // Mendapatkan daftar transaksi dari tabel 'transaksi'
  Future<List<Transaksi>> getTransaksiList() async {
    final db = await database;
    final transaksiListMap = await db.query('transaksi');

    // Konversi daftar transaksi dalam bentuk Map menjadi List<Transaksi>
    return transaksiListMap
        .map((transaksiMap) => Transaksi.fromMap(transaksiMap))
        .toList();
  }

  // Memperbarui transaksi (baik pemasukan maupun pengeluaran)
  Future<void> updateTransaksi(Map<String, dynamic> transaksi) async {
    final db = await database;
    await db.update(
      'transaksi',
      transaksi,
      where: 'id = ?',
      whereArgs: [transaksi['id']],
    );
  }

  // Menghapus transaksi (baik pemasukan maupun pengeluaran)
  Future<void> deleteTransaksi(int id) async {
    final db = await database;
    await db.delete(
      'transaksi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
