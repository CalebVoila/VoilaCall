import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
            status TEXT,
            duration INTEGER,
            caller_name TEXT,
            created_at TEXT,
            updated_at TEXT,
            call_comment TEXT
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
    final int seconds = interaction['duration'] ?? 0;

    final Map<String, dynamic> interactionWithSeconds = {
      'client_slug': interaction['client_slug'],
      'name': interaction['name'],
      'phone': interaction['phone'],
      'interaction_date': interaction['interaction_date'],
      'interaction_type': interaction['interaction_type'],
      'interaction_tag': interaction['interaction_tag'],
      'status': interaction['status'],
      'duration': seconds,
      'caller_name': interaction['caller_name'],
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'data': interaction['data'] ?? '',
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

  static Future<String> getCallComment(int interactionId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      interactionsTableName,
      where: 'id = ?',
      whereArgs: [interactionId],
    );

    return result.isNotEmpty ? result.first['data'] as String : '';
  }

  static Future<void> updateCallComment(int interactionId, String comment) async {
    final Database db = await database;
    await db.update(
      interactionsTableName,
      {'data': comment},
      where: 'id = ?',
      whereArgs: [interactionId],
    );
  }

  static fetchCallerInfoFromAPI(String phoneNumber) {}
}

class LeadsInformationPage extends StatefulWidget {
  @override
  _LeadsInformationPageState createState() => _LeadsInformationPageState();
}

class _LeadsInformationPageState extends State<LeadsInformationPage> {
  int _hotLeadsCount = 0;
  int _coldLeadsCount = 0;
  int _openLeadsCount = 0;
  int _warmLeadsCount = 0;
  int _totalInteractions = 0;

  String _callComment = '';

  @override
  void initState() {
    super.initState();
    _fetchLeadsCount();
  }

  Future<void> _fetchLeadsCount() async {
    try {
      _hotLeadsCount = await DatabaseHelper.getLeadCount('hot');
      _coldLeadsCount = await DatabaseHelper.getLeadCount('cold');
      _openLeadsCount = await DatabaseHelper.getLeadCount('open');
      _warmLeadsCount = await DatabaseHelper.getLeadCount('warm');
      _totalInteractions = await DatabaseHelper.getTotalInteractionsCount();
      _callComment = await DatabaseHelper.getCallComment(1); // Replace 1 with the actual interaction ID
      setState(() {});
    } catch (e) {
      print('Error fetching leads count: $e');
      // Handle errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads Information'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLeadTile('Hot Leads', _hotLeadsCount),
          _buildLeadTile('Cold Leads', _coldLeadsCount),
          _buildLeadTile('Open Leads', _openLeadsCount),
          _buildLeadTile('Warm Leads', _warmLeadsCount),
          _buildLeadTile('Total Interactions', _totalInteractions),
          _buildCallCommentWidget(),
        ],
      ),
    );
  }

  Widget _buildLeadTile(String title, int count) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Text('$title: $count'),
    );
  }

  Widget _buildCallCommentWidget() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Call Comment:'),
          SizedBox(height: 8.0),
          TextField(
            onChanged: (value) {
              setState(() {
                _callComment = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter call comment',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8.0),
          Text('Current comment: $_callComment'),
          ElevatedButton(
            onPressed: () {
              DatabaseHelper.updateCallComment(1, _callComment); // Replace 1 with the actual interaction ID
            },
            child: Text('Save Comment'),
          ),
        ],
      ),
    );
  }
}
