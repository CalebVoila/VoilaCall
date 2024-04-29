import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:call_log/call_log.dart';

class DatabaseHelper {
  static Database? _database;
  static const String customersTableName = 'customers';

  // Define column names
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colPhoneNumber = 'phone_number';
  static const String colDate = 'date';
  static const String colLead = 'lead';
  static const String colCallType = 'call_type';
  static const String colCallTag = 'call_tag';
  static const String colDuration = 'duration'; // Updated for call duration
  static const String colComment = 'comment';

  // Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'customers_database.db'),
      onCreate: (db, version) {
        return db.execute(
          '''CREATE TABLE $customersTableName (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colName TEXT,
            $colPhoneNumber TEXT,
            $colDate TEXT,
            $colLead TEXT,
            $colCallType TEXT,
            $colCallTag TEXT,
            $colDuration INTEGER,
            $colComment TEXT
          )''',
        );
      },
      version: 1,
    );
  }

  // Insert a customer
  // Insert a customer
  Future<int> insertCustomer(Map<String, dynamic> customer) async {
    try {
      final int callDurationInSeconds = customer[DatabaseHelper.colDuration] ?? 0;

      // Calculate hours, minutes, and remaining seconds
      int hours = callDurationInSeconds ~/ 3600;
      int remainingSeconds = callDurationInSeconds % 3600;
      int minutes = remainingSeconds ~/ 60;
      int seconds = remainingSeconds % 60;

      final String callDuration = '$hours:$minutes:$seconds'; // Format as HH:MM:SS

      final Map<String, dynamic> customerWithCallDuration = {
        ...customer,
        DatabaseHelper.colDuration: callDuration,
      };

      final db = await database;
      return db.insert(customersTableName, customerWithCallDuration);
    } catch (e) {
      print('Error inserting customer: $e');
      return -1; // Return -1 if there's an error
    }
  }



  // Retrieve all customers
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await database;
    return db.query(customersTableName);
  }

  // Update a customer
  Future<int> updateCustomer(Map<String, dynamic> customer) async {
    final db = await database;
    return db.update(
      customersTableName,
      customer,
      where: '$colId = ?',
      whereArgs: [customer[colId]],
    );
  }

  // Delete a customer
  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return db.delete(
      customersTableName,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // Get count of leads
  static Future<int> getLeadCount(String leadType) async {
    final Database db = await _database!;
    final List<Map<String, dynamic>> result = await db.query(
      customersTableName,
      where: '$colLead = ?',
      whereArgs: [leadType],
    );
    return result.length;
  }

  // Get total count of customers
  static Future<int> getTotalCustomersCount() async {
    final Database db = await _database!;
    final List<Map<String, dynamic>> result =
    await db.query(customersTableName);
    return result.length;
  }

  // Method to retrieve call duration from call log
  // Method to retrieve call duration from call log
  static Future<int> getCallDuration() async {
    try {
      // Fetch call logs
      Iterable<CallLogEntry> callLogs = await CallLog.get();
      // Calculate total duration
      int totalDuration = 0;
      for (var call in callLogs) {
        totalDuration += call.duration ?? 0;
      }
      // Convert duration to minutes
      int totalDurationInMinutes = totalDuration ~/ 60;
      return totalDurationInMinutes;
    } catch (e) {
      print('Error fetching call duration: $e');
      return 0; // Return 0 if there's an error
    }
  }

}
