import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/services/user_service.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/navigator_service.dart';
import '../services/user_model.dart';
import '../util/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progressValue = 0.0;
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
    _simulateLoading();
  }

  Future<void> _fetchUserData(String userId) async {
    //UserModel? userModel = await _userService.getUsers(userId);
    setState(() {
      //_userModel = userModel;
    });
  }

  void _simulateLoading() async {
    const int totalSteps = 10;
    for (int i = 1; i <= totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _progressValue = i / totalSteps;
        });
      });
    }
    _checkAuthState();
  }

  void _checkAuthState() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.checkAuthState().then((_) {
      if (authService.isAuthenticated) {
        if (_userModel != null && _userModel!.role != null) {
            Provider.of<NavigatorService>(context, listen: false).navigateTo(Routes.adminDashboard);
        } else {
          Provider.of<NavigatorService>(context, listen: false).navigateTo(Routes.loginScreen);
        }
      } else {
        Provider.of<NavigatorService>(context, listen: false)
            .navigateTo(Routes.loginScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LinearProgressIndicator(value: _progressValue),
              SizedBox(height: 20),
              Text('${(_progressValue * 100).round()}%'),
            ],
          ),
        ),
      ),
    );
  }
}
