import 'package:flutter/material.dart';
import 'package:voila_call_dummy/widgets/database_helper.dart';
import 'package:voila_call_dummy/auth/dashboard_screen.dart';

class VoilaCallScreen extends StatefulWidget {
  final String phoneNumber;
  final int callDuration;

  VoilaCallScreen({required this.phoneNumber, required this.callDuration});

  @override
  _VoilaCallScreenState createState() => _VoilaCallScreenState();
}

class _VoilaCallScreenState extends State<VoilaCallScreen> {
  String selectedLead = 'not responding';
  String selectedCallType = 'incoming'; // Default to incoming call
  String selectedCallTag = 'unanswered'; // Default to unanswered
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    phoneNumberController.text = widget.phoneNumber;
  }

  void submitData() async {
    String name = nameController.text;
    String phoneNumber = phoneNumberController.text;

    // Check if name and phone number are not empty
    if (name.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name and Phone Number are required'),
          duration: Duration(seconds: 3),
        ),
      );
      return; // Stop further execution
    }

    String comment = commentController.text;
    String callType = selectedCallType;
    String callTag = selectedCallTag;
    int callDuration = widget.callDuration;
    // Get current date and time
    DateTime now = DateTime.now();
    String callDate = now.toString();
    print(
        'Data inserted into SQLite database: Name: $name, Lead: $selectedLead, Phone Number: $phoneNumber, Comment: $comment, Call Type: $callType, Call Tag: $callTag, Call Date: $callDate');
    await DatabaseHelper().insertCustomer({
      DatabaseHelper.colName: name,
      DatabaseHelper.colPhoneNumber: phoneNumber,
      DatabaseHelper.colComment: comment,
      DatabaseHelper.colCallType: callType,
      DatabaseHelper.colCallTag: callTag,
      DatabaseHelper.colDate: callDate,
      DatabaseHelper.colLead: selectedLead,
      DatabaseHelper.colDuration: callDuration,
    }); // Store customer data in the database
    nameController.clear();
    phoneNumberController.clear();
    commentController.clear();
    setState(() {
      selectedLead = 'not responding';
      selectedCallType = 'incoming';
      selectedCallTag = 'unanswered';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved Successfully'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status of Call'),
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
    onWillPop: () async {
    // Navigate to the DashboardScreen when back button is pressed
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => DashboardScreen(username : '')),
    );
    return false; // Return false to prevent default back button behavior
    },

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Name:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  ' *', // Red star indicating mandatory field
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Phone Number:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  ' *', // Red star indicating mandatory field
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Comment:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select Lead:',
              style: TextStyle(fontSize: 18),
            ),
            Column(
              children: [
                RadioListTile(
                  title: Text('Not Responding'),
                  value: 'not responding',
                  groupValue: selectedLead,
                  onChanged: (value) {
                    setState(() {
                      selectedLead = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Open Lead'),
                  value: 'open lead',
                  groupValue: selectedLead,
                  onChanged: (value) {
                    setState(() {
                      selectedLead = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Warm Lead'),
                  value: 'warm lead',
                  groupValue: selectedLead,
                  onChanged: (value) {
                    setState(() {
                      selectedLead = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Cold Lead'),
                  value: 'cold lead',
                  groupValue: selectedLead,
                  onChanged: (value) {
                    setState(() {
                      selectedLead = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Hot Lead'),
                  value: 'hot lead',
                  groupValue: selectedLead,
                  onChanged: (value) {
                    setState(() {
                      selectedLead = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Customer'),
                  value: 'customer',
                  groupValue: selectedLead,
                  onChanged: (value) {
                    setState(() {
                      selectedLead = value.toString();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Select Call Type:',
              style: TextStyle(fontSize: 18),
            ),
            Column(
              children: [
                RadioListTile(
                  title: Text('Incoming'),
                  value: 'incoming',
                  groupValue: selectedCallType,
                  onChanged: (value) {
                    setState(() {
                      selectedCallType = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Outgoing'),
                  value: 'outgoing',
                  groupValue: selectedCallType,
                  onChanged: (value) {
                    setState(() {
                      selectedCallType = value.toString();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Select Call Tag:',
              style: TextStyle(fontSize: 18),
            ),
            Column(
              children: [
                RadioListTile(
                  title: Text('Answered'),
                  value: 'answered',
                  groupValue: selectedCallTag,
                  onChanged: (value) {
                    setState(() {
                      selectedCallTag = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Unanswered'),
                  value: 'unanswered',
                  groupValue: selectedCallTag,
                  onChanged: (value) {
                    setState(() {
                      selectedCallTag = value.toString();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitData,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}