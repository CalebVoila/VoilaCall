import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:pie_chart/pie_chart.dart';
import 'leads_information_page.dart';
import 'package:voila_call_dummy/auth/dashboard_screen.dart';
class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<CallLogEntry> _callLogs = [];
  int _totalDialedCalls = 0;
  int _totalConnectedCalls = 0;
  int _totalNotConnectedCalls = 0;
  int _totalTalkTime = 0;
  double _averageTalkTime = 0;

  String _selectedFilter = 'last_7_days';
  final List<String> _filterOptions = ['one_day', 'last_7_days', 'last_30_days', 'custom_range'];

  @override
  void initState() {
    super.initState();
    _fetchCallLogs();
  }

  Future<void> _fetchCallLogs() async {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    switch (_selectedFilter) {
      case 'one_day':
        startDate = now.subtract(Duration(days: 1));
        endDate = now;
        break;
      case 'last_7_days':
        startDate = now.subtract(Duration(days: 7));
        endDate = now;
        break;
      case 'last_30_days':
        startDate = now.subtract(Duration(days: 30));
        endDate = now;
        break;
      case 'custom_range':
      // Show a dialog to let the user pick custom start and end dates
        final selectedDates = await showDialog(
          context: context,
          builder: (context) => CustomDateRangePickerDialog(),
        );

        if (selectedDates != null && selectedDates.length == 2) {
          startDate = selectedDates[0];
          endDate = selectedDates[1];
        }
        break;
    }

    Iterable<CallLogEntry> callLogs = await CallLog.query(
      dateFrom: startDate.millisecondsSinceEpoch,
      dateTo: endDate.millisecondsSinceEpoch,
    );

    setState(() {
      _callLogs = callLogs.toList();
      _computeStatistics();
    });
  }

  void _computeStatistics() {
    _totalDialedCalls = _callLogs.length;
    _totalConnectedCalls = _callLogs.where((call) => (call.duration ?? 0) > 0).length;
    _totalNotConnectedCalls = _callLogs.where((call) => (call.duration ?? 0) == 0).length;

    _totalTalkTime = _callLogs.fold(0, (total, call) => total + (call.duration ?? 0));
    if (_totalDialedCalls > 0) {
      _averageTalkTime = _totalTalkTime / _totalDialedCalls;
    } else {
      _averageTalkTime = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // Navigate to the DashboardScreen when back button is pressed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(username: '')),
      );
      return false; // Return false to prevent default back button behavior
    },

      child: DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Statistics'),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Connected Calls'),
              Tab(text: 'Incoming/Outgoing Calls'),
              Tab(text: 'View Leads Information'), // Added "View Leads Information" tab
            ],
          ),
          actions: [
            DropdownButton<String>(
              value: _selectedFilter,
              items: _filterOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFilter = newValue;
                  });
                  _fetchCallLogs();
                }
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildConnectedCallsTab(),
            _buildInOutCallsTab(),
            LeadsInformationPage(), // Directly add LeadsInformationPage
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildConnectedCallsTab() {
    Map<String, double> connectedCallsData = {
      'Connected': _totalConnectedCalls.toDouble(),
      'Not Connected': _totalNotConnectedCalls.toDouble(),
    };
    List<Color> colorList = [
      Colors.green,
      Colors.red,
    ];

    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: PieChart(
            dataMap: connectedCallsData,
            animationDuration: Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 2,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 32,
            centerText: "CALL STATUS",
            legendOptions: LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.bottom,
              showLegends: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            chartValuesOptions: ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: false,
              showChartValuesOutside: false,
              decimalPlaces: 0,
            ),
            colorList: colorList,
          ),
        ),
        _buildCommonStatistics(),
      ],
    );
  }

  Widget _buildInOutCallsTab() {
    int totalIncomingCalls = _callLogs.where((call) => call.callType == CallType.incoming).length;
    int totalOutgoingCalls = _callLogs.where((call) => call.callType == CallType.outgoing).length;

    Map<String, double> inOutCallsData = {
      'Incoming': totalIncomingCalls.toDouble(),
      'Outgoing': totalOutgoingCalls.toDouble(),
    };
    List<Color> colorList = [
      Colors.blue,
      Colors.green,
    ];
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: PieChart(
            dataMap: inOutCallsData,
            animationDuration: Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 2,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 32,
            centerText: "CALL TYPE",
            legendOptions: LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.bottom,
              showLegends: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            chartValuesOptions: ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: false,
              showChartValuesOutside: false,
              decimalPlaces: 0,
            ),
            colorList: colorList,
          ),
        ),
        _buildCommonStatistics(),
      ],
    );
  }

  Widget _buildCommonStatistics() {
    return SingleChildScrollView(
        child: Padding(
        padding: EdgeInsets.all(16.0),
    child: Column(          crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 10),
        _buildStatisticTile(Icons.phone, 'Total Dialed Calls', _totalDialedCalls),
        _buildStatisticTile(Icons.av_timer, 'Average Talk Time', _averageTalkTime),
        _buildStatisticTile(Icons.check_circle, 'Connected Calls', _totalConnectedCalls),
        _buildStatisticTile(Icons.cancel, 'Not Connected Calls', _totalNotConnectedCalls),
        _buildStatisticTile(Icons.timer, 'Total Talk Time', _totalTalkTime),
      ],
    ),
        ),
    );
  }

  Widget _buildStatisticTile(IconData icon, String title, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 10),
          Text(
            '$title: $value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDateRangePickerDialog extends StatefulWidget {
  @override
  _CustomDateRangePickerDialogState createState() =>
      _CustomDateRangePickerDialogState();
}

class _CustomDateRangePickerDialogState
    extends State<CustomDateRangePickerDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Initialize start and end dates with current date
    _startDate = DateTime.now();
    _endDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Custom Date Range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Start Date:'),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectStartDate(context),
            child: Text(
              '${_formatDate(_startDate)}',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text('End Date:'),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectEndDate(context),
            child: Text(
              '${_formatDate(_endDate)}',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop([_startDate, _endDate]),
          child: Text('OK'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _startDate) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _endDate) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_addLeadingZero(date.month)}-${_addLeadingZero(date.day)}';
  }

  String _addLeadingZero(int value) {
    return value < 10 ? '0$value' : '$value';
  }
}

