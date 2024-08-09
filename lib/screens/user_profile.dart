import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:inmateschedular_pro/services/user_service.dart';
import 'package:inmateschedular_pro/util/const.dart';
import 'package:inmateschedular_pro/util/toast.dart';
import 'package:inmateschedular_pro/util/util_functions.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final bool isSidebarCollapsed;
  final VoidCallback onToggleSidebar;

  const UserProfileScreen({
    super.key, 
    required this.userId, 
    required this.isSidebarCollapsed, 
    required this.onToggleSidebar,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _role;
  String? _photoUrl;
  String? _gender;

  bool _isEditing = false;
  String? _errorMessage;

  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      UserModel? user = await _userService.getUser(widget.userId);
      if (user != null) {
        setState(() {
          _userModel = user;
          _firstNameController.text = user.firstName ?? '';
          _otherNameController.text = user.otherNames ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = user.phone ?? '';
          _dobController.text = user.dob ?? '';
          _addressController.text = user.address ?? '';
          _gender = user.gender ?? '';
          _role = user.role ?? '';
          _photoUrl = user.photo ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _otherNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _updateUserProfile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Updating User ...'),
          ],
        ),
      ),
    );

    UserModel updatedUser = UserModel(
      id: widget.userId,
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

    try {
      await _userService.updateUser(updatedUser, );
      Navigator.of(context).pop(); // Close the loading dialog
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating user data';
      });
      Navigator.of(context).pop(); // Close the loading dialog
      throw ('Error updating user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _userModel == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              margin: const EdgeInsets.only(top: 50.0),
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      // left panel
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.99),
                            borderRadius: _isEditing ? const BorderRadius.only(
                                topLeft: Radius.circular(50.0),
                                bottomLeft: Radius.circular(50.0),
                              )
                              : BorderRadius.circular(50.0),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -75,
                                left: _isEditing ? 200 : constraints.maxWidth / 2 - 80,
                                child: GestureDetector(
                                  onTap: () async {
                                    try {
                                      await Utils.selectPhoto((selectedPhotoUrl) {
                                        if (selectedPhotoUrl != null) {
                                          setState(() {
                                            _photoUrl = selectedPhotoUrl;
                                          });
                                        } else {
                                          showToast(message: 'Failed to select photo or file size exceeds limit of 1048487 ', err: true);
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
                                  child: Container(
                                    width: 150.0, // Width of the container
                                    height: 150.0, // Height of the container
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white, // Border color
                                        width: 5.0, // Border width
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 75,
                                      backgroundImage: _photoUrl == null
                                          ? const AssetImage('images/avatar.png') as ImageProvider
                                          : NetworkImage(_photoUrl!) as ImageProvider,
                                      child: _isEditing ? const Icon(Icons.camera_alt, size: 20, color: Colors.white) : const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 50), // for the avatar overlap
                                        Text(
                                          '${_firstNameController.text} ${_otherNameController.text}',
                                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.person, size: 18, color: Colors.white),
                                            Text(
                                              _gender ?? "",
                                              style: const TextStyle(color: Colors.white, fontSize: 18),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.calendar_month, size: 18, color: Colors.white),
                                            Text(
                                              _dobController.text,
                                              style: const TextStyle(color: Colors.white, fontSize: 18),
                                            ),
                                          ]
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.email, size: 18, color: Colors.white),
                                            Text(
                                              _emailController.text,
                                              style: const TextStyle(color: Colors.white, fontSize: 18),
                                            ),
                                          ]
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.phone, size: 18, color: Colors.white),
                                            Text(
                                              _phoneController.text,
                                              style: const TextStyle(color: Colors.white, fontSize: 18),
                                            ),
                                          ]
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Role: $_role',
                                          style: const TextStyle(color: Colors.white, fontSize: 18),
                                        ),
                                        const SizedBox(height: 20),
                                        if (!_isEditing)
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 30, color: Colors.white), 
                                            onPressed: () {
                                              setState(() {
                                                _isEditing = true;
                                              });
                                            },
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                       // right panel
                      if (_isEditing)
                      Expanded(
                        flex: 1,
                        child: Form(
                          key: _formKey,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.99),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(50.0),
                                bottomRight: Radius.circular(50.0),
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _firstNameController,
                                    decoration: InputDecoration(
                                      labelText: 'First Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your first name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _otherNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Other Names',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your other names';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _addressController,
                                    decoration: InputDecoration(
                                      labelText: 'Address',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _dobController,
                                    decoration: InputDecoration(
                                      labelText: 'Date of Birth',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    readOnly: true,
                                    onTap: () {
                                      Utils.selectDate(context, (selectedDate) {
                                        setState(() {
                                          _dobController.text = selectedDate ?? '';
                                        });
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select your date of birth';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  DropdownButtonFormField<String>(
                                    value: _gender,
                                    items: ['Male', 'Female', 'Other'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _gender = newValue;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Gender',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select your gender';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  DropdownButtonFormField<String>(
                                    value: _role,
                                    items: ['Admin', 'User', 'Guest'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _role = newValue;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Role',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
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
                                  const SizedBox(height: 20),
                                  if (_isEditing)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            if (_formKey.currentState!.validate()) {
                                              _updateUserProfile();
                                            }
                                          },
                                          label: const Text('Update Profile'),
                                          icon: const Icon(Icons.update, color: mainColor),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            setState((){
                                              _isEditing = false;
                                            });
                                          },
                                          label: const Text('Cancel'),
                                          icon: const Icon(Icons.cancel, color: Colors.orange,),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 20.0,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
