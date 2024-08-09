import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inmateschedular_pro/services/auth_service.dart';
import 'package:inmateschedular_pro/services/navigator_service.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:inmateschedular_pro/services/user_service.dart';
import 'package:inmateschedular_pro/util/aboutDialog.dart';
import 'package:inmateschedular_pro/util/const.dart';
import 'package:inmateschedular_pro/util/routes.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  final UserService _userService = UserService();
  User? _currentUser;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _currentUser = _userService.user; // Access the current user
    if (_currentUser != null) {
      _fetchUserData(_currentUser!.uid);
    }
  }

  Future<void> _fetchUserData(String userId) async {
    UserModel? userModel = await _userService.getUser(userId);
    setState(() {
      _userModel = userModel;
    });
  }

  void _checkAuthState() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.checkAuthState().then((_) {
      if (authService.isAuthenticated) {
        Provider.of<NavigatorService>(context, listen: false).navigateTo(Routes.adminDashboard);
      } else {
        Provider.of<NavigatorService>(context, listen: false).navigateTo(Routes.loginScreen);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.0),
                  bottomRight: Radius.circular(50.0),
                )
              ),
            ),
            const Positioned(
              top: 200.0,
              left: 100.0,
              right: 100.0,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50, 
                    backgroundImage: AssetImage('logo/logo1.jpeg'), 
                  ),
                  Text(
                    'InmateScheduler Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
        
              ),
            ),
            const Positioned(
              bottom: 170.0,
              left: 50.0,
              right: 50.0,
              child: Column(
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Automated Scheduling, Intuitive User Interface, Facility Resource Management, Conflict Detection and Resolution, Reporting and Analytics, ',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height-130,
              left: 100.0,
              right: 100.0,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _checkAuthState();
                    },
                    icon: const Icon(Icons.keyboard_arrow_right),
                    label: Text('Start',
                    style: GoogleFonts.bebasNeue().copyWith(fontSize: 30, color: Colors.blue),
                    ),
                    
                  ),
                  const SizedBox(height: 20.0,),
                  TextButton.icon(
                    label: const Text('About'),
                    icon: const Icon(Icons.info),
                    onPressed: (){
                      AboutDialogHelper.show(context);
                    },
                  ),

                ],
              ),
        
              /*
              GestureDetector(
                onTap: _checkAuthState,
                child: Container(
                  width: 150.0,
                  height: 55.0,
                  padding: const EdgeInsets.only(left: 80),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Start',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 28.0,),
                    ]
                  ),
                ),
              )
              */
            )
          ],
        ),
      ),


    );
  }
}