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
  int _totalCustomers = 0;

  @override
  void initState() {
    super.initState();
    _fetchLeadsCount();
  }

  Future<void> _fetchLeadsCount() async {
    try {
      int hotLeads = await DatabaseHelper.getLeadCount('hot lead');
      int coldLeads = await DatabaseHelper.getLeadCount('cold lead');
      int openLeads = await DatabaseHelper.getLeadCount('open lead');
      int warmLeads = await DatabaseHelper.getLeadCount('warm lead');
      int totalCustomers = await DatabaseHelper.getTotalCustomersCount();

      print('Hot Leads: $hotLeads');
      print('Cold Leads: $coldLeads');
      print('Open Leads: $openLeads');
      print('Warm Leads: $warmLeads');
      print('Total Customers: $totalCustomers');

      setState(() {
        _hotLeadsCount = hotLeads;
        _coldLeadsCount = coldLeads;
        _openLeadsCount = openLeads;
        _warmLeadsCount = warmLeads;
        _totalCustomers = totalCustomers;
      });
    } catch (e) {
      print('Error fetching leads count: $e');
      // Handle errors here, you can set default values or show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads Information'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLeadTile('Hot Leads', _hotLeadsCount),
          _buildLeadTile('Cold Leads', _coldLeadsCount),
          _buildLeadTile('Open Leads', _openLeadsCount),
          _buildLeadTile('Warm Leads', _warmLeadsCount),
          _buildLeadTile('Total Customers', _totalCustomers),
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
