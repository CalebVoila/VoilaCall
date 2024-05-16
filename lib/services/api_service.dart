import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../widgets/database_helper.dart';

Future<void> sendInteractionsToAPI() async {
  final Database db = await DatabaseHelper.database;
  final List<Map<String, dynamic>> interactions = await db.query(DatabaseHelper.interactionsTableName);

  final List<Map<String, dynamic>> interactionsWithFormattedDates = interactions.map((interaction) {
    return {
      'client_slug': interaction['client_slug'],
      'name': interaction['name'],
      'phone': interaction['phone'],
      'interaction_date': interaction['interaction_date'],
      'interaction_type': interaction['interaction_type'],
      'interaction_tag': interaction['interaction_tag'],
      'duration': interaction['duration'],
      'caller_name': interaction['caller_name'],
      'caller_phone':interaction['caller_phone'],
      'status': interaction['status'],
      'data':interaction['data']
    };
  }).toList();

  final url = Uri.parse('https://api.voilacode.com/api/interaction');
  final client = http.Client();

  try {
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(interactionsWithFormattedDates),
    );

    if (response.statusCode == 200) {
      print('Interactions posted successfully');
    } else if (response.statusCode == 401) {
      print('Unauthorized access. Please check your authorization credentials.');
    } else {
      print('Failed to post interactions. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } finally {
    client.close();
  }

}
