
import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:inmateschedular_pro/util/util_functions.dart';
import 'package:inmateschedular_pro/util/toast.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? user;
  final Function(UserModel) onSave;
  const UserFormDialog({super.key, this.user, required this.onSave});

  @override
  _UserFormDialogState createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _firstNameController.text = widget.user!.firstName ?? '';
      _otherNameController.text = widget.user!.otherNames ?? '';
      _emailController.text = widget.user!.email ?? '';
      _phoneController.text = widget.user!.phone ?? '';
      _addressController.text = widget.user!.address ?? '';
      _dobController.text = widget.user!.dob ?? '';
      _role = widget.user!.role;
      _photoUrl = widget.user!.photo;
      _gender = widget.user!.gender;
    }
  }

  void _resetForm() {
    _firstNameController.clear();
    _otherNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _dobController.clear();
    _role = null;
    _gender = null;
    _photoUrl = null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user != null ? 'Edit User' : 'Add User'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
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
                    child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  ),
                ),
              ),
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
                  } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Please enter a valid email';
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
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              UserModel user = UserModel(
                id: widget.user?.id ?? '',
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
              widget.onSave(user);
              //Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
