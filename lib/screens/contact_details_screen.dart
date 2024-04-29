import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class ContactDetailsScreen extends StatefulWidget {
  final CallLogEntry call;

  ContactDetailsScreen(this.call);

  @override
  _ContactDetailsScreenState createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  late List<CallLogEntry> callLogEntries;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchCallLogEntries();
  }

  Future<void> _fetchCallLogEntries() async {
    Iterable<CallLogEntry> callLogs = await CallLog.get();
    setState(() {
      callLogEntries = callLogs.toList();
    });
  }

  Future<void> _filterCallLogEntriesByDateRange() async {
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
          _filterCallLogsByDateRange(pickedStartDate, pickedEndDate);
        });
      }
    }
  }

  void _filterCallLogsByDateRange(DateTime startDate, DateTime endDate) {
    setState(() {
      callLogEntries = callLogEntries.where((callLog) {
        final DateTime callDateTime = DateTime.fromMillisecondsSinceEpoch(callLog.timestamp ?? 0);
        return callDateTime.isAfter(startDate.subtract(Duration(days: 1))) && callDateTime.isBefore(endDate.add(Duration(days: 1)));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.call.name ?? 'Unknown',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF5E17EB),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_calendar_outlined, color: Colors.white),
            onPressed: () => _filterCallLogEntriesByDateRange(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: callLogEntries.length,
        itemBuilder: (context, index) {
          final callLogEntry = callLogEntries[index];
          return _buildCallHistoryTile(callLogEntry);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _makeCall(widget.call.number ?? '');
        },
        child: Icon(Icons.call,color:Color(0xB80EF626)),
        backgroundColor: Color(0xC5106EEA),
      ),
    );
  }

  Widget _buildCallHistoryTile(CallLogEntry callLogEntry) {
    IconData icon;
    Color iconColor;
    String status;
    if (callLogEntry.callType == CallType.incoming) {
      icon = Icons.call_received_outlined;
      iconColor = Colors.green;
      status = callLogEntry.duration == 0 ? 'Missed' : 'Answered';
    } else {
      icon = Icons.call_made_outlined; // Change to Icons.call_made for outgoing calls
      iconColor = Colors.green;
      status = callLogEntry.duration == 0 ? 'Rejected' : 'Answered';
    }

    return Column(
      children: [
        ListTile(
          title: Text(_formatDateTime(callLogEntry.timestamp ?? 0)),
          subtitle: Text('Duration: ${_formatDuration(callLogEntry.duration)} | Status: $status'),
          trailing: Icon(
            icon,
            color: iconColor,
          ),
        ),
        Divider(
          height: 1,
          color: Colors.grey,
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  String _formatDuration(int? durationInSeconds) {
    if (durationInSeconds == null) {
      return 'Unknown';
    }
    final Duration d = Duration(seconds: durationInSeconds);
    return '${d.inHours.toString().padLeft(2, '0')}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  String _formatDateTime(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${DateFormat('EEEE, MMMM d, y').format(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _makeCall(String number) {
    FlutterPhoneDirectCaller.callNumber(number);
  }
}
