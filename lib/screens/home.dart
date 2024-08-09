import 'package:inmateschedular_pro/services/user_service.dart';
import 'package:inmateschedular_pro/services/navigator_service.dart';
import 'package:inmateschedular_pro/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../util/routes.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('logo/logo.png', height: 40),
            Spacer(),
            TextButton(onPressed: () {}, child: Text("Home")),
            TextButton(onPressed: () {}, child: Text("About Us")),
            TextButton(onPressed: () {}, child: Text("Gallery")),
            TextButton(onPressed: () {}, child: Text("Contact Us")),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                authService.signOut().then((_) {
                  Provider.of<NavigatorService>(context, listen: false)
                      .navigateTo(Routes.loginScreen);
                });
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildEducationalProgramsSection(),
            _buildEventsSection(),
            _buildPhotoGallerySection(),
            _buildVideoSection(),
            _buildFaqSection(),
            _buildFooterSection(authService, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Smarter Learning, Brighter Future",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Empowering students through personalized learning experiences.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalProgramsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Educational Programs for every Stage",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildProgramCard("Pre-primary School"),
              _buildProgramCard("Primary School"),
              _buildProgramCard("Secondary School"),
              _buildProgramCard("Higher Secondary School"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(String title) {
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 50),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Don't Miss the Biggest Events and News of the Year!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          // Add event cards here
        ],
      ),
    );
  }

  Widget _buildPhotoGallerySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Capturing Memories, Building Dreams",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          // Add photo gallery here
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rewind, Replay, Rejoice! Dive into Our Video Vault",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          // Add video thumbnails here
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Got Questions? We have Got Answers! Dive into Our FAQs",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          // Add FAQ here
        ],
      ),
    );
  }

  Widget _buildFooterSection(AuthService authService, BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Empower Everyone: Teachers, Students, Parents - Get the App Now!",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDownloadButton("Student & Parent App", "Android Demo", Icons.android),
              _buildDownloadButton("Teacher App", "iOS Demo", Icons.apple),
            ],
          ),
          // Add more footer links here
          TextButton(
            onPressed: () {
              authService.signOut().then((_) {
                Provider.of<NavigatorService>(context, listen: false)
                    .navigateTo(Routes.loginScreen);
              });
              showToast(message: "Successfully signed out", err: false);
            },
            child: Text("Sign out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon),
        label: Column(
          children: [
            Text(title),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
