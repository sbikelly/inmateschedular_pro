import 'package:flutter/material.dart';

class AboutDialogHelper {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AboutDialog(
          applicationName: 'InmateScheduler Pro',
          applicationVersion: 'Version: 1.0.0',
          applicationIcon: CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('logo/logo1.jpeg'),
          ),
          applicationLegalese: '© 2024 All Rights Reserved',
          children: <Widget>[
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Wrap(
                    children: [
                      Text(
                        'Welcome to InmateScheduler Pro, an innovative solution designed to streamline and optimize scheduling processes in correctional facilities. This application is built to address the inefficiencies and challenges associated with traditional manual scheduling methods, providing a modern, automated approach to inmate and staff management.',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'The Inmate Scheduling System leverages the power of Flutter for an intuitive and responsive user interface and Firebase for robust and secure backend services. Our goal is to improve the operational efficiency of correctional facilities, ensuring that resources are utilized effectively, and administrative tasks are simplified.',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Our team is committed to continuously enhancing the system, incorporating feedback from users, and integrating the latest technological advancements to better serve the needs of correctional facilities.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Key Features',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    leading: Icon(Icons.schedule),
                    title: Text('Automated Scheduling'),
                  ),
                  ListTile(
                    leading: Icon(Icons.update),
                    title: Text('Real-Time Updates'),
                  ),
                  ListTile(
                    leading: Icon(Icons.warning),
                    title: Text('Conflict Detection'),
                  ),
                  ListTile(
                    leading: Icon(Icons.security),
                    title: Text('User Authentication and Roles'),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone_android),
                    title: Text('Intuitive User Interface'),
                  ),
                  ListTile(
                    leading: Icon(Icons.stacked_bar_chart),
                    title: Text('Resource Management'),
                  ),
                  ListTile(
                    leading: Icon(Icons.analytics),
                    title: Text('Reporting and Analytics'),
                  ),
                  ListTile(
                    leading: Icon(Icons.expand),
                    title: Text('Scalability'),
                  ),
                  ListTile(
                    leading: Icon(Icons.integration_instructions),
                    title: Text('Integration Capabilities'),
                  ),
                  ListTile(
                    leading: Icon(Icons.mobile_friendly),
                    title: Text('Mobile Accessibility'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Developer:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'KEVIN BUTRIT MOSES (UJ/2020/FCEP/CS/0217)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '+2348064723727',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'kevinbutrit@gmail.com',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
