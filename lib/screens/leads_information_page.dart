import 'package:flutter/material.dart';
import 'package:voila_call_dummy/widgets/database_helper.dart';

class LeadsInformationPage extends StatefulWidget {
  @override
  _LeadsInformationPageState createState() => _LeadsInformationPageState();
}

class _LeadsInformationPageState extends State<LeadsInformationPage> {
  int _hotLeadsCount = 0;
  int _coldLeadsCount = 0;
  int _openLeadsCount = 0;
  int _warmLeadsCount = 0;
  int _totalInteractions = 0;

  @override
  void initState() {
    super.initState();
    _fetchLeadsCount();
  }

  Future<void> _fetchLeadsCount() async {
    try {
      // Fetch lead counts for different types
      _hotLeadsCount = await DatabaseHelper.getLeadCount('hot');
      _coldLeadsCount = await DatabaseHelper.getLeadCount('cold');
      _openLeadsCount = await DatabaseHelper.getLeadCount('open');
      _warmLeadsCount = await DatabaseHelper.getLeadCount('warm');

      // Fetch total interactions count
      _totalInteractions = await DatabaseHelper.getTotalInteractionsCount();

      // Update the UI with the fetched counts
      setState(() {});
    } catch (e) {
      print('Error fetching leads count: $e');
      // Handle errors here, set default values or show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads Information'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLeadTile('Hot Leads', _hotLeadsCount),
          _buildLeadTile('Cold Leads', _coldLeadsCount),
          _buildLeadTile('Open Leads', _openLeadsCount),
          _buildLeadTile('Warm Leads', _warmLeadsCount),
          _buildLeadTile('Total Interactions', _totalInteractions),
        ],
      ),
    );
  }

  Widget _buildLeadTile(String title, int count) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Text('$title: $count'),
    );
  }
}
