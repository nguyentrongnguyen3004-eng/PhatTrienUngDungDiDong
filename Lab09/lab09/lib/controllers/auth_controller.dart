import '../models/user.dart';
import '../utils/database_helper.dart';

class AuthController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<bool> isEmailExist(String email) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    return maps.isNotEmpty;
  }

  Future<int> register(String email, String password) async {
    final db = await _dbHelper.database;
    final user = User(
      email: email.trim().toLowerCase(),
      password: password,
    );
    return await db.insert('users', user.toMap());
  }

  Future<User?> login(String email, String password) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((e) => User.fromMap(e)).toList();
  }
}
