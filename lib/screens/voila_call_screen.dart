import 'dart:async';
import 'package:flutter/material.dart';
import 'package:voila_call_dummy/widgets/database_helper.dart';
import 'package:call_log/call_log.dart';

class VoilaCallScreen extends StatefulWidget {
  final String phoneNumber;

  VoilaCallScreen({
    required this.phoneNumber, required int callDuration,
  });

  @override
  _VoilaCallScreenState createState() => _VoilaCallScreenState();
}

class _VoilaCallScreenState extends State<VoilaCallScreen> {
  String selectedLead = 'not responding';
  String selectedCallType = 'incoming';
  String selectedCallTag = 'unanswered';
  String selectedStatus = 'incoming';
  TextEditingController nameController = TextEditingController();
  TextEditingController callerNameController = TextEditingController();
  TextEditingController callerNumberController = TextEditingController();
  TextEditingController interactionDateController = TextEditingController(); // New controller for interaction date
  int duration = 0;

  @override
  void initState() {
    super.initState();
    fetchCallerInfo(widget.phoneNumber);
    // Start updating duration immediately and every second
    Timer.periodic(Duration(seconds: 1), (Timer t) => fetchCallDuration());
    // Fetch and display interaction date
    setInteractionDate();
  }

  void setInteractionDate() {
    // Get current date and time
    DateTime now = DateTime.now();
    // Format it as desired
    String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    // Set it to the controller
    interactionDateController.text = formattedDate;
  }

  Future<void> fetchCallerInfo(String phoneNumber) async {
    try {
      final callerInfo = await fetchCallerInfoFromAPI(phoneNumber);
      setState(() {
        callerNameController.text = callerInfo['name'] ?? '';
        callerNumberController.text = callerInfo['number'] ?? '';
      });
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
        CallLogEntry latestCall = callLogs.firstWhere((log) =>
        log.callType == CallType.incoming || log.callType == CallType.outgoing);
        setState(() {
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

  Future<void> fetchLastDialedNumber() async {
    try {
      Iterable<CallLogEntry> callLogs = await CallLog.query(
        dateFrom: DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch,
        dateTo: DateTime.now().millisecondsSinceEpoch,
      );
      if (callLogs.isNotEmpty) {
        CallLogEntry lastDialedCall =
        callLogs.firstWhere((log) => log.callType == CallType.outgoing);
        callerNumberController.text = lastDialedCall.number ?? '';
      }
    } catch (e) {
      print('Error fetching last dialed number: $e');
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
                labelText: 'Number',
                hintText: widget.phoneNumber,
              ),
              readOnly: true, // Make it not editable
            ),
            SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: '$duration seconds'),
              decoration: InputDecoration(
                labelText: 'Call Duration',
              ),
              readOnly: true, // Make it not editable
            ),
            SizedBox(height: 20),
            TextField(
              controller: interactionDateController, // Use the controller for interaction date
              decoration: InputDecoration(
                labelText: 'Interaction Date',
              ),
              readOnly: true, // Make it not editable
            ),
            SizedBox(height: 20),
            Text('Select Lead:', style: TextStyle(fontSize: 18)),
            Column(
              children: [
                // RadioListTile Widgets for selecting lead
              ],
            ),
            SizedBox(height: 20),
            Text('Select Call Type:', style: TextStyle(fontSize: 18)),
            Column(
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'incoming',
                      groupValue: selectedCallType,
                      onChanged: (String? value) {
                        setState(() {
                          selectedCallType = value!;
                        });
                      },
                    ),
                    Text('Incoming'),
                    SizedBox(width: 20),
                    Radio<String>(
                      value: 'outgoing',
                      groupValue: selectedCallType,
                      onChanged: (String? value) {
                        setState(() {
                          selectedCallType = value!;
                        });
                      },
                    ),
                    Text('Outgoing'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Select Call Tag:', style: TextStyle(fontSize: 18)),
            Column(
              children: [
                // RadioListTile Widgets for selecting call tag
              ],
            ),
            SizedBox(height: 20),
            Text('Select Call Status:', style: TextStyle(fontSize: 18)),
            Column(
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'incoming',
                      groupValue: selectedStatus,
                      onChanged: (String? value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    Text('Incoming'),
                    SizedBox(width: 20),
                    Radio<String>(
                      value: 'outgoing',
                      groupValue: selectedStatus,
                      onChanged: (String? value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    Text('Outgoing'),
                  ],
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

                Map<String, dynamic> interaction = {
                  'client_slug': selectedLead,
                  'name': name,
                  'caller_name': callerName,
                  'phone': callerNumber,
                  'interaction_date': interactionDateController.text, // Use interaction date from controller
                  'interaction_type': selectedCallType,
                  'interaction_tag': selectedCallTag,
                  'status': selectedStatus,
                  'duration_hours': duration ~/ 3600,
                  'duration_minutes': (duration % 3600) ~/ 60,
                  'duration_seconds': duration % 60,
                };

                await DatabaseHelper.insertInteraction(interaction);

                nameController.clear();
                callerNameController.clear();
                callerNumberController.clear();
                setState(() {
                  selectedLead = 'not responding';
                  selectedCallType = 'incoming';
                  selectedCallTag = 'unanswered';
                  selectedStatus = 'incoming';
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
