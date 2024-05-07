import 'package:flutter/material.dart';
import 'package:voila_call_dummy/widgets/database_helper.dart';
import 'package:call_log/call_log.dart';

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
  TextEditingController nameController = TextEditingController();
  TextEditingController callerNameController = TextEditingController();
  TextEditingController callerNumberController = TextEditingController();
  TextEditingController callDurationController = TextEditingController();
  int duration = 0;

  @override
  void initState() {
    super.initState();
    fetchCallerInfo(widget.phoneNumber);
    fetchCallDuration();
  }

  Future<void> fetchCallerInfo(String phoneNumber) async {
    try {
      final callerInfo = await fetchCallerInfoFromAPI(phoneNumber);
      callerNameController.text = callerInfo['name'] ?? '';
      callerNumberController.text = callerInfo['number'] ?? '';
    } catch (e) {
      print('Error fetching caller info: $e');
      callerNameController.text = 'Unknown';
      callerNumberController.text = 'Unknown';
    }
  }

  Future<void> fetchCallDuration() async {
    try {
      Iterable<CallLogEntry> callLogs = await CallLog.query(
        dateFrom: DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch,
        dateTo: DateTime.now().millisecondsSinceEpoch,
      );
      if (callLogs.isNotEmpty) {
        CallLogEntry latestCall = callLogs.first;
        duration = latestCall.duration ?? 0;
        callDurationController.text = '$duration seconds';
      } else {
        callDurationController.text = '0 seconds';
      }
    } catch (e) {
      print('Error fetching call duration: $e');
      callDurationController.text = '0 seconds';
    }
  }

  Future<Map<String, String>> fetchCallerInfoFromAPI(String phoneNumber) async {
    // Placeholder for actual API call implementation
    return {
      'name': 'John Doe',
      'number': '+1 (555) 1234567',
    };
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
                labelText: 'Caller Number',
                hintText: widget.phoneNumber,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: callDurationController,
              decoration: InputDecoration(
                labelText: 'Call Duration',
                hintText: '$duration seconds',
              ),
            ),
            SizedBox(height: 20),
            Text('Select Lead:', style: TextStyle(fontSize: 18)),
            Column(
              children: [
                RadioListTile(
                  title: Text('Not Responding'),
                  value: 'not responding',
                  groupValue: selectedLead,
                  onChanged: (value) {
                    setState(() {
                      selectedLead = value.toString();
                    });
                  },
                ),
                // Add more RadioListTile widgets for other lead types
              ],
            ),
            SizedBox(height: 20),
            Text('Select Call Type:', style: TextStyle(fontSize: 18)),
            Column(
              children: [
                RadioListTile(
                  title: Text('Incoming'),
                  value: 'incoming',
                  groupValue: selectedCallType,
                  onChanged: (value) {
                    setState(() {
                      selectedCallType = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Outgoing'),
                  value: 'outgoing',
                  groupValue: selectedCallType,
                  onChanged: (value) {
                    setState(() {
                      selectedCallType = value.toString();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Select Call Tag:', style: TextStyle(fontSize: 18)),
            Column(
              children: [
                RadioListTile(
                  title: Text('Answered'),
                  value: 'answered',
                  groupValue: selectedCallTag,
                  onChanged: (value) {
                    setState(() {
                      selectedCallTag = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Unanswered'),
                  value: 'unanswered',
                  groupValue: selectedCallTag,
                  onChanged: (value) {
                    setState(() {
                      selectedCallTag = value.toString();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text;
                String callerName = callerNameController.text;
                String callerNumber = callerNumberController.text.isNotEmpty
                    ? callerNumberController.text
                    : widget.phoneNumber;
                String callDuration = callDurationController.text;

                Map<String, dynamic> interaction = {
                  'client_slug': selectedLead,
                  'name': name,
                  'caller_name': callerName,
                  'phone': callerNumber,
                  'interaction_date': DateTime.now().toString(),
                  'interaction_type': selectedCallType,
                  'interaction_tag': selectedCallTag,
                  'duration_hours': duration ~/ 3600,
                  'duration_minutes': (duration % 3600) ~/ 60,
                  'duration_seconds': duration % 60,
                };

                await DatabaseHelper.insertInteraction(interaction);

                nameController.clear();
                callerNameController.clear();
                callerNumberController.clear();
                callDurationController.clear();
                setState(() {
                  selectedLead = 'not responding';
                  selectedCallType = 'incoming';
                  selectedCallTag = 'unanswered';
                });

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