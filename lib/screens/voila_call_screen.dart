import 'package:flutter/material.dart';
import 'package:voila_call_dummy/widgets/database_helper.dart';

class VoilaCallScreen extends StatefulWidget {
  final String phoneNumber;
  final int callDuration;

  VoilaCallScreen({
    required this.phoneNumber,
    required this.callDuration,
  });

  @override
  _VoilaCallScreenState createState() => _VoilaCallScreenState();
}

class _VoilaCallScreenState extends State<VoilaCallScreen> {
  String selectedLead = 'not responding';
  String selectedCallType = 'incoming';
  String selectedCallTag = 'unanswered';
  TextEditingController nameController = TextEditingController();

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
            Text('Select Lead:', style: TextStyle(fontSize: 18)),
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
                // Add more RadioListTile widgets for other lead types
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text;
                String phoneNumber = widget.phoneNumber;

                // Prepare interaction data
                Map<String, dynamic> interaction = {
                  'client_slug': selectedLead,
                  'name': name,
                  'phone': phoneNumber,
                  'interaction_date': DateTime.now().toString(),
                  'interaction_type': selectedCallType,
                  'interaction_tag': selectedCallTag,
                  'duration_hours': widget.callDuration ~/ 3600,
                  'duration_minutes': (widget.callDuration % 3600) ~/ 60,
                  'duration_seconds': widget.callDuration % 60,
                };

                // Insert interaction into database
                await DatabaseHelper.insertInteraction(interaction);

                // Clear form fields
                nameController.clear();
                setState(() {
                  selectedLead = 'not responding';
                  selectedCallType = 'incoming';
                  selectedCallTag = 'unanswered';
                });

                // Show success message
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
