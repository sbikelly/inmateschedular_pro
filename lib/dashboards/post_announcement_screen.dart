import 'package:flutter/material.dart';

class PostAnnouncementScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Announcement/Assignment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(labelText: 'Details'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement post announcement/assignment functionality
              },
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
