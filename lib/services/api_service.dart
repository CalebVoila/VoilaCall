// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:sqflite/sqflite.dart';
// import '../widgets/database_helper.dart';
//
// Future<void> sendInteractionsToAPI() async {
//   final Database db = await DatabaseHelper.database;
//   final List<Map<String, dynamic>> interactions = await db.query(DatabaseHelper.interactionsTableName);
//
//   // Ensure all required fields are populated
//   final List<Map<String, dynamic>> interactionsWithFormattedDates = interactions.map((interaction) {
//     return {
//       'client_slug': interaction['client_slug'] ?? '',
//       'name': interaction['name'] ?? '',
//       'phone': interaction['phone'] ?? '',
//       'interaction_date': interaction['interaction_date'] ?? '',
//       'interaction_type': interaction['interaction_type'] ?? '',
//       'interaction_tag': interaction['interaction_tag'] ?? '',
//       'duration': interaction['duration'] ?? 0,
//       'caller_name': interaction['caller_name'] ?? '',
//       'caller_phone': interaction['caller_phone'] ?? '',
//       'status': interaction['status'] ?? '',
//       'data': interaction['data'] ?? '',
//     };
//   }).toList();
//
//   final url = Uri.parse('https://api.voilacode.com/api/interaction');
//   final client = http.Client();
//
//   try {
//     final response = await client.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(interactionsWithFormattedDates),
//     );
//
//     if (response.statusCode == 200) {
//       print('Interactions posted successfully');
//     } else if (response.statusCode == 302) {
//       print('Received a 302 redirect. Attempting to follow the redirect...');
//       final redirectUrl = response.headers['location'];
//       if (redirectUrl != null) {
//         final redirectedResponse = await client.get(
//           Uri.parse(redirectUrl),
//           headers: {
//             'Content-Type': 'application/json',
//           },
//         );
//         if (redirectedResponse.statusCode == 200) {
//           print('Interactions posted successfully after following the redirect');
//         } else {
//           print('Failed to post interactions after following the redirect. Status code: ${redirectedResponse.statusCode}');
//           print('Response body: ${redirectedResponse.body}');
//         }
//       } else {
//         print('Redirect URL not found in the response headers');
//       }
//     } else if (response.statusCode == 401) {
//       print('Unauthorized access. Please check your authorization credentials.');
//     } else {
//       print('Failed to post interactions. Status code: ${response.statusCode}');
//       print('Response body: ${response.body}');
//     }
//   } catch (e) {
//     print('Error posting interactions: $e');
//   } finally {
//     client.close();
//   }
// }
