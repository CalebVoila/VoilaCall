import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/widgets.dart';

class DatabaseHelper {
  static Database? _database;

  static const String interactionsTableName = 'interactions';
  static const String leadsTableName = 'leads';

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();

    final path = join(await getDatabasesPath(), 'combined_database.db');

    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE $interactionsTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_slug TEXT,
            name TEXT,
            phone TEXT,
            interaction_date TEXT,
            interaction_type TEXT,
            interaction_tag TEXT,
            duration_seconds INTEGER,
            caller_name TEXT,
            caller_phone TEXT,
            status TEXT,
            data TEXT,
            created_at TEXT,
            updated_at TEXT
          )''',
        );

        await db.execute(
          '''CREATE TABLE $leadsTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lead_type TEXT
          )''',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertInteraction(Map<String, dynamic> interaction) async {
    final int hours = interaction['duration_hours'] ?? 0;
    final int minutes = interaction['duration_minutes'] ?? 0;
    final int seconds = interaction['duration_seconds'] ?? 0;

    final int totalDurationSeconds = hours * 3600 + minutes * 60 + seconds;

    final Map<String, dynamic> interactionWithSeconds = {
      ...interaction,
      'duration_seconds': totalDurationSeconds,
    };

    final Database db = await database;
    await db.insert(interactionsTableName, interactionWithSeconds);
  }

  static Future<int> getLeadCount(String leadType) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT COUNT(*) as count FROM $leadsTableName WHERE lead_type = ?''',
      [leadType],
    );
    return result.isNotEmpty ? result.first['count'] as int : 0;
  }

  static Future<int> getTotalInteractionsCount() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT COUNT(*) as count FROM $interactionsTableName''',
    );
    return result.isNotEmpty ? result.first['count'] as int : 0;
  }

  static Future<int> getCallDuration() async {
    try {
      Iterable<CallLogEntry> callLogs = await CallLog.query(
        // Query call logs for a specific duration
        dateFrom: DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch,
      );
      int totalDuration = 0;
      for (var call in callLogs) {
        totalDuration += call.duration ?? 0;
      }
      return totalDuration; // Return total duration in seconds
    } catch (e) {
      print('Error fetching call duration: $e');
      return 0;
    }
  }
}
