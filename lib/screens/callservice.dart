import 'dart:async';
import 'package:call_log/call_log.dart';

import '../services/call_service.dart';

enum CallStatus { none, ended }

class CallService {
  late StreamSubscription<List<CallLogEntry>> _callLogSubscription;
  late List<CallLogEntry> _callLogs;

  CallService() {
    _callLogs = [];
    _initializeCallLogListener();
  }

  Future<void> _initializeCallLogListener() async {
    _callLogs = await CallLogService.getCallLogs();

    _callLogSubscription = CallLogService.getCallLogsStream().listen((callLogs) {
      // Determine if a new call log entry indicates the end of a call
      CallLogEntry latestCallLog = callLogs.first;
      if (_callLogs.isNotEmpty &&
          callLogs.length > _callLogs.length &&
          latestCallLog.duration! > 0) {
        // Notify listeners that the call has ended
        _callLogSubscription.cancel(); // Cancel subscription to prevent multiple notifications
        _callLogs.clear(); // Clear call logs
        _onCallEnd.add(CallStatus.ended);
      }
      _callLogs = callLogs;
    });
  }

  final _onCallEnd = StreamController<CallStatus>.broadcast();

  Stream<CallStatus> get onCallEnd => _onCallEnd.stream;

  Future<void> dispose() async {
    await _callLogSubscription.cancel();
    await _onCallEnd.close();
  }
}