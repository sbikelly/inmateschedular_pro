import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/services/firestore_service.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:inmateschedular_pro/util/toast.dart';
import 'package:inmateschedular_pro/util/util_functions.dart';
import 'package:intl/intl.dart';

class OfficerDialog extends StatefulWidget {
  final OfficerModel? officer;
  final String dialogType;

  const OfficerDialog({super.key, required this.officer, required this.dialogType});

  @override
  _OfficerDialogState createState() => _OfficerDialogState();
}

class _OfficerDialogState extends State<OfficerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _officerIDController;
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _rankController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _photoUrl;
  String? _gender;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedLga;
  late final String _type = widget.dialogType;

  final FirestoreService<OfficerModel> officerService = FirestoreService<OfficerModel>(
    collectionName: 'officers',
    fromSnapshot: (snapshot) => OfficerModel.fromSnapshot(snapshot),
    toJson: (model) => model.toJson(),
  );
  
  @override
  void initState() {
    super.initState();
    _officerIDController = TextEditingController(text: widget.officer?.officerID);
    _nameController = TextEditingController(text: widget.officer?.name);
    _rankController = TextEditingController(text: widget.officer?.rank);
    _dobController = TextEditingController(text: widget.officer?.dob);
    _emailController = TextEditingController(text: widget.officer?.email);
    _phoneController = TextEditingController(text: widget.officer?.phone);
    _gender = widget.officer?.gender;
    _selectedCountry = widget.officer?.nationality;
    _selectedState = widget.officer?.state;
    _selectedLga = widget.officer?.lga;
  }

  @override
  void dispose() {
    _officerIDController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rankController.dispose();
    _dobController.dispose();
    super.dispose();
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveOfficer() async {
    if (_formKey.currentState!.validate()) {
      OfficerModel newOfficer = OfficerModel(
        officerID: _officerIDController.text,
        name: _nameController.text,
        rank: _rankController.text,
        dob: _dobController.text,
        gender: _gender!,
        nationality: _selectedCountry!,
        state: _selectedState!,
        lga: _selectedLga!,
        email: _emailController.text,
        phone: _phoneController.text,
        photo: _photoUrl != null ? _photoUrl.toString() : null,
      );

      try {
        await officerService.add(newOfficer);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Officer created successfully')),
        );
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding officer')),
        );
        if (kDebugMode) {
          print('Error adding officer: $e');
        }
      }
    }
  }

  void _updateOfficer() async {
    if (_formKey.currentState!.validate()) {
      OfficerModel updatedOfficer = OfficerModel(
        id: widget.officer?.id,
        officerID: _officerIDController.text,
        name: _nameController.text,
        rank: _rankController.text,
        dob: _dobController.text,
        gender: _gender!,
        nationality: _selectedCountry!,
        state: _selectedState!,
        lga: _selectedLga!,
        email: _emailController.text,
        phone: _phoneController.text,
        photo: _photoUrl != null ? _photoUrl.toString() : widget.officer?.photo,
      );

      try {
        if (widget.officer != null) {
          await officerService.update(widget.officer!.id!, updatedOfficer);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Officer updated successfully')),
          );
        } else {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error updating officer. Officer ID not found')),
          );
        }
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating officer')),
        );
        if (kDebugMode) {
          print('Error updating officer: $e');
        }
      }
    }
  }

  void _deleteOfficer() async {
    try {
      await officerService.delete(widget.officer!.id!);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Officer deleted successfully')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting officer')),
      );
      if (kDebugMode) {
        print('Error deleting officer: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
          child: _type == 'update'
              ? const Text('Update Officer')
              : const Text('Add New Officer')),
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
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
                ),const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _officerIDController,
                  decoration:
                      const InputDecoration(labelText: "Officer's ID"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter officer's ID";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: const [
                    DropdownMenuItem(
                      enabled: false,
                      child: Text('Gender'),
                    ),
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Select Gender'),
                  icon: const Icon(Icons.person),
                ),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'yyyy-MM-dd',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the date of birth';
                    }
                    return null;
                  },
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 10),
                _type == "update"
                    ? const SizedBox.shrink()
                    : CSCPicker(
                        showStates: true,
                        showCities: true,
                        flagState: CountryFlag.DISABLE,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade400, width: 2),
                        ),
                        disabledDropdownDecoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey.shade300,
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        countrySearchPlaceholder: "Country/Nationality",
                        stateSearchPlaceholder: "State of Origin",
                        citySearchPlaceholder: "Local Government Area/City",
                        countryDropdownLabel: "Select Nationality",
                        stateDropdownLabel: "*State of Origin/Residence",
                        cityDropdownLabel: "*Local Govt. Area/City",
                        selectedItemStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        dropdownHeadingStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                        dropdownItemStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        dropdownDialogRadius: 10.0,
                        searchBarRadius: 10.0,
                        onCountryChanged: (value) {
                          setState(() {
                            _selectedCountry = value;
                          });
                        },
                        onStateChanged: (value) {
                          setState(() {
                            _selectedState = value;
                          });
                        },
                        onCityChanged: (value) {
                          setState(() {
                            _selectedLga = value;
                          });
                        },
                      ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _rankController,
                  decoration: const InputDecoration(labelText: 'Rank'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the rank';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (_type == 'update')
          TextButton(
            onPressed: _deleteOfficer,
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_type == 'update') {
              _updateOfficer();
            } else {
              _saveOfficer();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
