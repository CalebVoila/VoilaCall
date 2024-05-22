import 'dart:async';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import '../widgets/database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoilaCallScreen extends StatefulWidget {
  final String phoneNumber;
  final int callDuration;

  VoilaCallScreen({
    required this.phoneNumber,
    required this.callDuration,
  });

  @override
  _VoilaCallScreenState createState() => _VoilaCallScreenState();
}

class _VoilaCallScreenState extends State<VoilaCallScreen> {
  String selectedLead = 'not responding';
  String selectedCallType = 'incoming';
  String selectedCallTag = 'unanswered';
  List<String> callLeads = ['not responding', 'open lead', 'cold lead', 'hot lead', 'warm lead', 'customer'];
  String? selectedLeadValue;
  TextEditingController clientSlugController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController callerNameController = TextEditingController();
  TextEditingController callerNumberController = TextEditingController();
  TextEditingController interactionDateController = TextEditingController();
  TextEditingController dataController = TextEditingController();
  int duration = 0;
  String callComment = '';

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer t) => fetchCallDuration());
    setInteractionDate();
    fetchCallerInfo(widget.phoneNumber);
  }

  void setInteractionDate() {
    DateTime now = DateTime.now();
    String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    interactionDateController.text = formattedDate;
  }

  Future<void> fetchCallerInfo(String phoneNumber) async {
    try {
      final callerInfo = await DatabaseHelper.fetchCallerInfoFromAPI(phoneNumber);
      setState(() {
        callerNameController.text = callerInfo['name'] ?? 'Unknown';
        callerNumberController.text = callerInfo['number'] ?? phoneNumber;
      });
    } catch (e) {
      print('Error fetching caller info: $e');
      callerNameController.text = 'Unknown';
      callerNumberController.text = phoneNumber;
    }
  }

  Future<void> fetchCallDuration() async {
    try {
      Iterable<CallLogEntry> callLogs = await CallLog.query(
        dateFrom: DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch,
        dateTo: DateTime.now().millisecondsSinceEpoch,
      );
      if (callLogs.isNotEmpty) {
        CallLogEntry latestCall = callLogs.firstWhere((log) =>
        log.callType == CallType.incoming || log.callType == CallType.outgoing);

        String interactionType = latestCall.callType == CallType.incoming ? 'incoming' : 'outgoing';
        String interactionTag = latestCall.duration != 0 ? 'answered' : 'unanswered';

        setState(() {
          selectedCallType = interactionType;
          selectedCallTag = interactionTag;
          duration = latestCall.duration ?? 0;
        });
      } else {
        setState(() {
          duration = 0;
        });
      }
    } catch (e) {
      print('Error fetching call duration: $e');
    }
  }

  Future<void> sendInteractionToAPI(Map<String, dynamic> interaction) async {
    final url = Uri.parse('https://api.voilacode.com/api/interaction');
    final client = http.Client();

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(interaction),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Interaction posted successfully');
      } else {
        print('Failed to post interaction. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting interaction: $e');
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Interaction Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: clientSlugController,
              decoration: InputDecoration(labelText: 'Client Slug'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: callerNameController,
              decoration: InputDecoration(labelText: 'Caller Name'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: callerNumberController,
              decoration: InputDecoration(
                labelText: 'Number',
                hintText: widget.phoneNumber,
              ),
              readOnly: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: '$duration seconds'),
              decoration: InputDecoration(labelText: 'Call Duration'),
              readOnly: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: interactionDateController,
              decoration: InputDecoration(labelText: 'Interaction Date'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: selectedCallType),
              decoration: InputDecoration(labelText: 'Interaction Type'),
              readOnly: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: selectedCallTag),
              decoration: InputDecoration(labelText: 'Interaction Tag'),
              readOnly: true,
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Call Lead'),
                SizedBox(height: 8),
                for (String lead in callLeads)
                  RadioListTile<String>(
                    title: Text(lead),
                    value: lead,
                    groupValue: selectedLeadValue,
                    onChanged: (value) {
                      setState(() {
                        selectedLeadValue = value;
                      });
                    },
                  ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  callComment = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Call Comment',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String clientSlug = clientSlugController.text;
                String name = nameController.text;
                String callerName = callerNameController.text;
                String callerNumber = callerNumberController.text.isNotEmpty ? callerNumberController.text : widget.phoneNumber;
                String totalDurationSeconds = duration.toString();  // Convert duration to string for API

                Map<String, dynamic> interaction = {
                  'client_slug': clientSlug.isNotEmpty ? clientSlug : null,
                  'name': name,
                  'caller_name': callerName,
                  'caller_phone': callerNumber,
                  'phone': callerNumber,
                  'interaction_date': interactionDateController.text,
                  'interaction_type': selectedCallType,
                  'interaction_tag': selectedCallTag,
                  'status': selectedLeadValue ?? 'not responding',
                  'duration': duration,  // Keep duration as int for database
                  'data': callComment,
                };

                if (name.isEmpty || callerName.isEmpty || callerNumber.isEmpty || interactionDateController.text.isEmpty || selectedCallType.isEmpty || selectedCallTag.isEmpty || selectedLeadValue == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all the required fields'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                await DatabaseHelper.insertInteraction(interaction);

                interaction['duration'] = totalDurationSeconds;  // Convert duration to string for API

                nameController.clear();
                callerNameController.clear();
                callerNumberController.clear();
                clientSlugController.clear();
                interactionDateController.clear();
                dataController.clear();
                setState(() {
                  selectedLeadValue = 'not responding';
                  selectedCallType = 'incoming';
                  selectedCallTag = 'unanswered';
                  duration = 0;
                  callComment = '';
                });
                await sendInteractionToAPI(interaction);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Interaction saved successfully'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
