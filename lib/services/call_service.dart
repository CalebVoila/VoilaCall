import 'dart:async';
import 'package:call_log/call_log.dart';

class CallLogService {
  static Future<List<CallLogEntry>> getCallLogs() async {
    try {
      Iterable<CallLogEntry> callLogs = await CallLog.get();
      return callLogs.toList();
    } catch (e) {
      print('Error fetching call logs: $e');
      return [];
    }
  }

  static Stream<List<CallLogEntry>> getCallLogsStream() {
    StreamController<List<CallLogEntry>> controller = StreamController<List<CallLogEntry>>();
    Duration refreshRate = Duration(seconds: 10); // Set the refresh rate

    void fetchCallLogsPeriodically() {
      getCallLogs().then((callLogs) {
        controller.add(callLogs); // Emit call logs to the stream
      });
    }

    fetchCallLogsPeriodically(); // Fetch call logs immediately

    // Start a timer to fetch call logs periodically
    Timer.periodic(refreshRate, (timer) {
      fetchCallLogsPeriodically();
    });

    return controller.stream;
  }
}
