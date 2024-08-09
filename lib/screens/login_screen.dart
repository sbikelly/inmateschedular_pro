import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/navigator_service.dart';
import '../util/const.dart';
import '../util/form_container_widget.dart';
import '../util/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigning = false;
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();
  late Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initializeFuture = _initialize();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/hq.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: FutureBuilder(
          future: _initializeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      _buildLeftPanel(),
                      _buildRightPanel(),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: mainColor.withOpacity(0.99),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50.0),
            bottomLeft: Radius.circular(50.0),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('logo/logo1.jpeg'),
              ),
              SizedBox(height: 50),
              Text(
                "InmateScheduler Pro",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Automated Scheduling, Intuitive User Interface, Facility Resource Management, Conflict Detection and Resolution, Reporting and Analytics, ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.99),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(50.0),
            bottomRight: Radius.circular(50.0),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('icon/login.png', height: 200),
                    const SizedBox(height: 20),
                    FormContainerWidget(
                      controller: _emailController,
                      hintText: "Enter your Email/Staff ID",
                      isPasswordField: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FormContainerWidget(
                      controller: _passwordController,
                      hintText: "Password",
                      isPasswordField: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(value: false, onChanged: (bool? value) {}),
                        const Text('Remember me'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 10),
                    _buildSignInButton(),
                    const SizedBox(height: 20),
                    _buildRegisterLink(),
                    const SizedBox(height: 10),
                    _buildForgotPasswordLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

    
  Widget _buildSignInButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            _signIn();
          }
        },
        child: Container(
          width: double.infinity,
          height: 45,
          decoration: BoxDecoration(
            color: mainColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _isSigning
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Provider.of<NavigatorService>(context, listen: false)
              .navigateTo(Routes.signupScreen);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?"),
            const SizedBox(width: 5),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.transparent,
                ),
                child: Text(
                  "Register",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Uncomment and implement navigation to reset password screen
          // Provider.of<NavigatorService>(context, listen: false)
          //     .navigateTo(Routes.resetPasswordScreen);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.transparent,
            ),
            child: const Text(
              "I forgot my password",
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
      _errorMessage = null;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      User? user = await Provider.of<AuthService>(context, listen: false).signIn(email, password);

      setState(() {
        _isSigning = false;
      });

      if (user != null) {
        Provider.of<NavigatorService>(context, listen: false).navigateTo(Routes.adminDashboard);
      }
    } catch (e) {
      setState(() {
        _isSigning = false;
        _errorMessage = "Invalid Username/Password";
      });
      if (kDebugMode) {
        print("Sign in Error: $e");
      }
      Provider.of<NavigatorService>(context, listen: false).navigateTo(Routes.loginScreen);
    }
  }

}
