import 'package:flutter/material.dart';

class SubmitAssignmentScreen extends StatelessWidget {
  final TextEditingController _assignmentDetailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Assignment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _assignmentDetailsController,
              decoration: InputDecoration(labelText: 'Assignment Details'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement submit assignment functionality
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
