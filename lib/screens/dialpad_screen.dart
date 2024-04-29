import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:call_log/call_log.dart';
import 'package:voila_call_dummy/widgets/custom_dialpad.dart';
import 'package:voila_call_dummy/screens/voila_call_screen.dart';
import 'package:voila_call_dummy/screens/contact_details_screen.dart'; // Import the ContactDetailsScreen
import 'package:voila_call_dummy/services/call_service.dart'; // Assuming this service includes call-related functionalities
import 'package:voila_call_dummy/auth/dashboard_screen.dart';
class DialpadScreen extends StatefulWidget {
  final Function(int) setActiveTabIndex;

  DialpadScreen({required this.setActiveTabIndex});

  @override
  _DialpadScreenState createState() => _DialpadScreenState();
}

class _DialpadScreenState extends State<DialpadScreen> {
  List<CallLogEntry> _callLogs = [];
  List<String> _enteredDigits = [];

  @override
  void initState() {
    super.initState();
    _fetchCallLogs();
  }

  Future<void> _fetchCallLogs() async {
    List<CallLogEntry> callLogs = await CallLogService.getCallLogs();
    setState(() {
      _callLogs = callLogs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen(username : '')),
        );
        return false; // Return false to prevent default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dialpad'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _callLogs.length,
                itemBuilder: (context, index) {
                  CallLogEntry log = _callLogs[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(log.name ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.number ?? 'Unknown'),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Last Called: ${_formatTimestamp(log.timestamp)}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_note),
                            onPressed: () {
                              _openCallStatusForm(context, log);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.call),
                            onPressed: () {
                              _makeCallToContact(log.number ?? '');
                            },
                            color: Colors.green, // Set the color to green
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to ContactDetailsScreen when tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactDetailsScreen(log),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            CustomDialpad(
              onDigitPressed: _handleDigitPressed,
              onClearPressed: _handleClearPressed,
              onCallPressed: _makeCall,
              enteredDigits: _enteredDigits,
            ),
          ],
        ),
      ),
    );
  }

  String? _formatTimestamp(int? timestamp) {
    if (timestamp == null) return null;
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final String hours = '${dateTime.hour}'.padLeft(2, '0');
    final String minutes = '${dateTime.minute}'.padLeft(2, '0');
    final String seconds = '${dateTime.second}'.padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _handleDigitPressed(String digit) {
    setState(() {
      _enteredDigits.add(digit);
    });
  }

  void _handleClearPressed() {
    setState(() {
      if (_enteredDigits.isNotEmpty) {
        _enteredDigits.removeLast();
      }
    });
  }

  void _makeCall() async {
    String phoneNumber = _enteredDigits.join();

    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (!res!) {
      // Handle error if call couldn't be initiated
      print('Error making call');
      return;
    }

    // Once the call is made, navigate to the VoilaCallScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoilaCallScreen(phoneNumber: phoneNumber, callDuration: 0),
      ),
    );
  }

  void _makeCallToContact(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (!res!) {
      // Handle error if call couldn't be initiated
      print('Error making call');
      return;
    }

    // Once the call is made, navigate to the VoilaCallScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoilaCallScreen(phoneNumber: phoneNumber, callDuration: 0),
      ),
    );
  }

  void _openCallStatusForm(BuildContext context, CallLogEntry call) {
    // Navigate to VoilaCallScreen to fill out call status form
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoilaCallScreen(
          phoneNumber: call.number ?? '',
          callDuration: 0, // You can pass the call duration here if available
        ),
      ),
    );
  }
}