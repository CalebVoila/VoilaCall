import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:call_log/call_log.dart';

class DatabaseHelper {
  static Database? _database;
  static const String usersTableName = 'users';
  static const String customersTableName = 'customers';

  // Define column names for users table
  static const String usersColUsername = 'username';
  static const String usersColEmail = 'email';
  static const String usersColPassword = 'password';

  // Define column names for customers table
  static const String customersColId = 'id';
  static const String customersColName = 'name';
  static const String customersColPhoneNumber = 'phone_number';
  static const String customersColDate = 'date';
  static const String customersColLead = 'lead';
  static const String customersColCallType = 'call_type';
  static const String customersColCallTag = 'call_tag';
  static const String customersColDuration = 'duration'; // Updated for call duration
  static const String customersColComment = 'comment';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'combined_database.db');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        // Create users table
        await db.execute(
          "CREATE TABLE $usersTableName($usersColUsername TEXT PRIMARY KEY, $usersColEmail TEXT UNIQUE, $usersColPassword TEXT)",
        );

        // Create customers table
        await db.execute(
          '''CREATE TABLE $customersTableName (
            $customersColId INTEGER PRIMARY KEY AUTOINCREMENT,
            $customersColName TEXT,
            $customersColPhoneNumber TEXT,
            $customersColDate TEXT,
            $customersColLead TEXT,
            $customersColCallType TEXT,
            $customersColCallTag TEXT,
            $customersColDuration INTEGER,
            $customersColComment TEXT
          )''',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertUser(Map<String, dynamic> user) async {
    final Database db = await database;
    await db.insert(usersTableName, user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> insertCustomer(Map<String, dynamic> customer) async {
    try {
      final int callDurationInSeconds = customer[customersColDuration] ?? 0;
      int hours = callDurationInSeconds ~/ 3600;
      int remainingSeconds = callDurationInSeconds % 3600;
      int minutes = remainingSeconds ~/ 60;
      int seconds = remainingSeconds % 60;
      final String callDuration = '$hours:$minutes:$seconds';

      final Map<String, dynamic> customerWithCallDuration = {
        ...customer,
        customersColDuration: callDuration,
      };

      final db = await database;
      await db.insert(customersTableName, customerWithCallDuration);
    } catch (e) {
      print('Error inserting customer: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final Database db = await database;
    return db.query(usersTableName);
  }

  static Future<List<Map<String, dynamic>>> getCustomers() async {
    final Database db = await database;
    return db.query(customersTableName);
  }

  static Future<int> updateCustomer(Map<String, dynamic> customer) async {
    final Database db = await database;
    return db.update(
      customersTableName,
      customer,
      where: '$customersColId = ?',
      whereArgs: [customer[customersColId]],
    );
  }

  static Future<int> deleteCustomer(int id) async {
    final Database db = await database;
    return db.delete(
      customersTableName,
      where: '$customersColId = ?',
      whereArgs: [id],
    );
  }

  static Future<int> getLeadCount(String leadType) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      customersTableName,
      where: '$customersColLead = ?',
      whereArgs: [leadType],
    );
    return result.length;
  }

  static Future<int> getTotalCustomersCount() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(customersTableName);
    return result.length;
  }

  static Future<int> getCallDuration() async {
    try {
      Iterable<CallLogEntry> callLogs = await CallLog.get();
      int totalDuration = 0;
      for (var call in callLogs) {
        totalDuration += call.duration ?? 0;
      }
      int totalDurationInMinutes = totalDuration ~/ 60;
      return totalDurationInMinutes;
    } catch (e) {
      print('Error fetching call duration: $e');
      return 0;
    }
  }
}