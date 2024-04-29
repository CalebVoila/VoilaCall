import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/services.dart';
import 'contact_details_screen.dart'; // Import the ContactDetailsScreen
import 'voila_call_screen.dart'; // Import the VoilaCallScreen
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class CallLogScreen extends StatefulWidget {
  @override
  _CallLogScreenState createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  Stream<List<CallLogEntry>>? _filteredCallLogsStream;

  @override
  void initState() {
    super.initState();
    _filteredCallLogsStream = _fetchFilteredCallLogsStream(DateTime.now(), DateTime.now());
  }

  Stream<List<CallLogEntry>> _fetchFilteredCallLogsStream(DateTime startDate, DateTime endDate) async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1)); // Adjust the delay time as needed
      Iterable<CallLogEntry> callLogs = await CallLog.get();
      yield _filterCallLogs(callLogs, startDate, endDate);
    }
  }

  List<CallLogEntry> _filterCallLogs(Iterable<CallLogEntry> callLogs, DateTime startDate, DateTime endDate) {
    return callLogs.where((call) {
      final DateTime callDateTime = DateTime.fromMillisecondsSinceEpoch(call.timestamp ?? 0);
      return callDateTime.isAfter(startDate.subtract(Duration(days: 1))) && callDateTime.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Minimize the app instead of popping when back button is pressed
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Call Log'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.edit_calendar_outlined),
              onPressed: () => _showFilterDateRangePicker(),
            ),
          ],
        ),
        body: StreamBuilder<List<CallLogEntry>>(
          stream: _filteredCallLogsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final callLogs = snapshot.data ?? [];
              return ListView.builder(
                itemCount: callLogs.length,
                itemBuilder: (context, index) {
                  final call = callLogs[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(call.name ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            call.number ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatTimestamp(call.timestamp),
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_note),
                            onPressed: () {
                              _openCallStatusForm(context, call);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.call),
                            color: Colors.green,
                            onPressed: () {
                              _makeCall(call.number ?? '');
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to ContactDetailsScreen when tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactDetailsScreen(call),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) {
      return 'Last called: Unknown';
    }
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return 'Last called:\n${_formatDate(dateTime)} | ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')} ${_getMonth(dateTime.month)} ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) {
        hour -= 12;
      }
    }
    if (hour == 0) {
      hour = 12;
    }
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  void _makeCall(String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      // After the call ends, navigate to the status of call page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoilaCallScreen(phoneNumber: phoneNumber, callDuration: 0),
        ),
      );
    } catch (e) {
      // Handle error if call cannot be launched
      print('Error launching call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not make a call'),
        ),
      );
    }
  }

  Future<void> _showFilterDateRangePicker() async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedStartDate != null) {
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: _endDate ?? pickedStartDate,
        firstDate: pickedStartDate,
        lastDate: DateTime.now(),
      );
      if (pickedEndDate != null) {
        setState(() {
          _startDate = pickedStartDate;
          _endDate = pickedEndDate;
          _filteredCallLogsStream = _fetchFilteredCallLogsStream(pickedStartDate, pickedEndDate);
        });
      }
    }
  }

  void _showCallStatus(CallLogEntry call) {
    // Implement logic to show call status
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Call Status'),
          content: Text('Status: ${call.callType}'), // You can customize this message as needed
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
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
