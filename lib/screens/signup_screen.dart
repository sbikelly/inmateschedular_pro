import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/util/toast.dart';
import 'package:inmateschedular_pro/util/util_functions.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/navigator_service.dart';
import '../services/user_model.dart';
import '../services/user_service.dart';
import '../util/const.dart';
import '../util/routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _role;
  String? _photoUrl;
  String? _gender;

  bool _isSigningUp = false;
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();

  final Map<String, bool> _hovering = {
    'photo': false,
    'signUp': false,
    'login': false,
  };

  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
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
          future: _initFuture,
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
                    Image.asset('icon/signup.png', height: 200),
                    const SizedBox(height: 20),
                    _buildPhotoSelector(),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _firstNameController,
                      labelText: 'First Name',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _otherNameController,
                      labelText: 'Other Names',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your other names';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      //controller: _confirmPasswordController,
                      labelText: 'Re-enter Password',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please re-enter your password';
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        } else if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _addressController,
                      labelText: 'Address',
                      keyboardType: TextInputType.streetAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDatePicker(),
                    const SizedBox(height: 20),
                    _buildDropdownButtonFormField(
                      value: _gender,
                      items: ['Male', 'Female', 'Other'],
                      labelText: 'Gender',
                      onChanged: (newValue) {
                        setState(() {
                          _gender = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your gender';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownButtonFormField(
                      value: _role,
                      items: ['Admin', 'User', 'Guest'],
                      labelText: 'Role',
                      onChanged: (newValue) {
                        setState(() {
                          _role = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your role';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 10),
                    _buildSignUpButton(),
                    const SizedBox(height: 20),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSelector() {
    return InkWell(
      onTap: () async {
        try {
          await Utils.selectPhoto((selectedPhotoUrl) {
            if (selectedPhotoUrl != null) {
              setState(() {
                _photoUrl = selectedPhotoUrl;
              });
            } else {
              showToast(
                message: 'Failed to select photo or file size exceeds limit of 1048487',
                err: true,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('file size exceeds limit')),
              );
            }
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('An error occurred while selecting the photo')),
          );
        }
      },
      onHover: (hovering) {
        setState(() {
          _hovering['photo'] = hovering;
        });
      },
      child: Container(
        width: 150.0,
        height: 150.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _hovering['photo']! ? Colors.white : mainColor,
            width: 5.0,
          ),
        ),
        child: CircleAvatar(
          radius: 75,
          backgroundImage: _photoUrl == null
              ? const AssetImage('images/avatar.png') as ImageProvider
              : NetworkImage(_photoUrl!) as ImageProvider,
          child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    TextEditingController? controller,
    required String labelText,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dobController,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      readOnly: true,
      onTap: () {
        Utils.selectDate(context, (selectedDate) {
          if (selectedDate != null) {
            setState(() {
              _dobController.text = selectedDate;
            });
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your date of birth';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownButtonFormField({
    required String? value,
    required List<String> items,
    required String labelText,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSignUpButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _isSigningUp = true;
            _errorMessage = null;
          });
          try {
            UserModel newUser = await _signUp();
            await UserService().addUser(newUser);
            if (!mounted) return;
            setState(() {
              _isSigningUp = false;
            });
            Provider.of<NavigatorService>(context, listen: false).navigateTo(Routes.adminDashboard);
          } catch (e) {
            if (!mounted) return;
            setState(() {
              _isSigningUp = false;
              _errorMessage = e.toString();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
        }
      },
      onHover: (hovering) {
        setState(() {
          _hovering['signUp'] = hovering;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: _hovering['signUp']! ? mainColor.withOpacity(0.8) : mainColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _hovering['signUp']!
              ? [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)]
              : [],
        ),
        child: Center(
          child: _isSigningUp
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        const SizedBox(width: 5),
        MouseRegion(
          onEnter: (_) => setState(() {
            _hovering['login'] = true;
          }),
          onExit: (_) => setState(() {
            _hovering['login'] = false;
          }),
          child: GestureDetector(
            onTap: () {
              Provider.of<NavigatorService>(context, listen: false).navigateTo(Routes.loginScreen);
            },
            child: Text(
              "Login",
              style: TextStyle(
                color: _hovering['login']! ? const Color.fromARGB(255, 152, 236, 190) : mainColor,
                fontWeight: FontWeight.bold,
                decoration: _hovering['login']! ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<UserModel> _signUp() async {
    UserModel nUser = UserModel(
      firstName: _firstNameController.text,
      otherNames: _otherNameController.text,
      gender: _gender,
      dob: _dobController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      role: _role,
      photo: _photoUrl,
    );
    String password = _passwordController.text;
    try {
      User? user = await Provider.of<AuthService>(context, listen: false).signUp(nUser.email.toString(), password);
    
      if (user != null) {
        debugPrint('existing n user id = ${nUser.id}');
        nUser.id = user.uid;
        debugPrint('user id = ${user.uid}');
        debugPrint('n user id = ${nUser.id}');
        return nUser;
      } else {
        throw Exception("User registration failed");
      }
    } catch (e) {
      setState(() {
        _isSigningUp = false;
        _errorMessage = "Sign up Error: $e";
      });
      return Future.error(e);
    }
  }

}

