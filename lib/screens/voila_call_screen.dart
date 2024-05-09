import 'dart:async';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:voila_call_dummy/widgets/database_helper.dart';

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
  TextEditingController interactionDateController = TextEditingController();
  int duration = 0;

  @override
  void initState() {
    super.initState();
    // Start updating call duration immediately and every second
    Timer.periodic(Duration(seconds: 1), (Timer t) => fetchCallDuration());
    // Set interaction date
    setInteractionDate();
    // Fetch caller information
    fetchCallerInfo(widget.phoneNumber);
  }

  void setInteractionDate() {
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
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
              readOnly: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: '$duration seconds'),
              decoration: InputDecoration(labelText: 'Call Duration'),
              readOnly: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text;
                String callerName = callerNameController.text;
                String callerNumber = callerNumberController.text.isNotEmpty
                    ? callerNumberController.text
                    : widget.phoneNumber;

                // Calculate total duration in seconds directly
                int totalDurationSeconds = duration;

                Map<String, dynamic> interaction = {
                  'client_slug': selectedLead,
                  'name': name,
                  'caller_name': callerName,
                  'phone': callerNumber,
                  'interaction_date': interactionDateController.text,
                  'interaction_type': selectedCallType,
                  'interaction_tag': selectedCallTag,
                  'status': selectedStatus,
                  'duration_seconds': totalDurationSeconds, // Store duration in seconds
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
