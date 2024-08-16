import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/services/firestore_service.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:inmateschedular_pro/util/toast.dart';
import 'package:inmateschedular_pro/util/util_functions.dart';
import 'package:intl/intl.dart';

class InmateDialog extends StatefulWidget {
  final InmateModel? inmate;
  final String? dialogType;

  const InmateDialog({Key? key, required this.inmate, this.dialogType}) : super(key: key);

  @override
  _InmateDialogState createState() => _InmateDialogState();
}

class _InmateDialogState extends State<InmateDialog> {

  
  late FirestoreService<UserModel> _userService; // Use the generic service
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _inmateIDController;
  late TextEditingController _firstNameController;
  late TextEditingController _otherNamesController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cellNoController;
  late TextEditingController _dobController;
  String? _photo;
  String? _gender;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedLga;
  late final String? _type = widget.dialogType;

  //InmateService inmateService = InmateService();

  @override
  void initState() {
    super.initState();
    _inmateIDController = TextEditingController(text: widget.inmate?.inmateID);
    _firstNameController = TextEditingController(text: widget.inmate?.firstName);
    _otherNamesController = TextEditingController(text: widget.inmate?.otherNames);
    _emailController = TextEditingController(text: widget.inmate?.email);
    _phoneController = TextEditingController(text: widget.inmate?.phone);
    _otherNamesController = TextEditingController(text: widget.inmate?.otherNames);
    _cellNoController = TextEditingController(text: widget.inmate?.cellNo);
    _dobController = TextEditingController(
        text: widget.inmate?.dob != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.inmate!.dob.toString()))
            : '');
    _gender = widget.inmate?.gender;
    _selectedCountry = widget.inmate?.country;
    _selectedState = widget.inmate?.state;
    _selectedLga = widget.inmate?.lga;
  }

  @override
  void dispose() {
    _inmateIDController.dispose();
    _firstNameController.dispose();
    _otherNamesController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cellNoController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  final FirestoreService<InmateModel> inmateService = FirestoreService<InmateModel>(
    collectionName: 'inmates',
    fromSnapshot: (snapshot) => InmateModel.fromSnapshot(snapshot),
    toJson: (model) => model.toJson(),
  );
  

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

  void _saveInmate() async {
    if (_formKey.currentState!.validate()) {
      InmateModel newInmate = InmateModel(
        inmateID: _inmateIDController.text,
        firstName: _firstNameController.text,
        otherNames: _otherNamesController.text,
        cellNo: _cellNoController.text,
        dob: _dobController.text,
        gender: _gender!,
        country: _selectedCountry!,
        state: _selectedState!,
        lga: _selectedLga!,
        photo: widget.inmate?.photo,
      );

      try {
        await inmateService.add(newInmate);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inmate created successfully')),
        );
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding inmate')),
        );
        if (kDebugMode) {
          print('Error adding inmate: $e');
        }
      }
    }
  }

  void _updateInmate() async {
    if (_formKey.currentState!.validate()) {
      InmateModel updatedInmate = InmateModel(
        id: widget.inmate?.id,
        inmateID: _inmateIDController.text,
        firstName: _firstNameController.text,
        otherNames: _otherNamesController.text,
        cellNo: _cellNoController.text,
        dob: _dobController.text,
        gender: _gender!,
        country: _selectedCountry!,
        state: _selectedState!,
        lga: _selectedLga!,
        photo: widget.inmate?.photo,
      );

      try {
        if (widget.inmate != null && widget.inmate!.id != null) {
          await inmateService.update(widget.inmate!.id!, updatedInmate);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inmate updated successfully')),
          );
        } else {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error updating Inmate. Inmate id not found')),
          );
        }
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating Inmate')),
        );
        if (kDebugMode) {
          print('Error updating Inmate: $e');
        }
      }
    }
  }

void _deleteInmate() async {
  try {
    if (widget.inmate != null && widget.inmate!.id != null) {
      await inmateService.delete(widget.inmate!.id!);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inmate deleted successfully')),
      );
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting Inmate. Inmate id not found')),
      );
    }
  } on Exception catch (e) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error deleting Inmate')),
    );
    if (kDebugMode) {
      print('Error deleting Inmate: $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
          child: _type == 'update'
              ? const Text('Update Inmate')
              : const Text('Add New Inmate')),
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _type == 'update'
                    ? const SizedBox.shrink()
                      : GestureDetector(
                    onTap: () async {
                    try {
                      await Utils.selectPhoto((selectedPhotoUrl) {
                        if (selectedPhotoUrl != null) {
                          setState(() {
                            _photo = selectedPhotoUrl;
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
                      backgroundImage: _photo == null
                          ? const AssetImage('images/avatar.png') as ImageProvider
                          : NetworkImage(_photo!) as ImageProvider,
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ),
                ),
              
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _inmateIDController,
                  decoration:
                      const InputDecoration(labelText: "Inmate's Number"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Inmate's Number";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the first name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _otherNamesController,
                  decoration: const InputDecoration(labelText: 'Other Names'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the other names';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: [
                    const DropdownMenuItem(child: Text('Gender'), enabled: false,),
                    const DropdownMenuItem(value: 'Male', child: Text('Male')),
                    const DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Select Gender'),
                  icon: Icon(Icons.person),

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
                SizedBox(height: 10,),
                _type == "update"?const SizedBox.shrink()
                : CSCPicker(
                  showStates: true,
                  showCities: true,
                  flagState: CountryFlag.DISABLE,

                  dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border:
                      Border.all(color: Colors.grey.shade400, width: 2)),

                  disabledDropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey.shade300,
                      border:
                      Border.all(color: Colors.grey.shade300, width: 2)),

                  ///placeholders for dropdown search field
                  countrySearchPlaceholder: "Country/Nationality",
                  stateSearchPlaceholder: "State of Origin",
                  citySearchPlaceholder: "Local Government Area/City",

                  ///labels for dropdown
                  countryDropdownLabel: "Select Nationality",
                  stateDropdownLabel: "*State of Origin/Residence",
                  cityDropdownLabel: "*Local Govt Area/City",

                  ///Default Country
                  defaultCountry: CscCountry.Nigeria,

                  ///Disable country dropdown (Note: use it with default country)
                  //disableCountry: true,

                  ///Country Filter [OPTIONAL PARAMETER]
                  //countryFilter: [CscCountry.India,CscCountry.United_States,CscCountry.Canada],

                  ///selected item style [OPTIONAL PARAMETER]
                  selectedItemStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),

                  ///DropdownDialog Heading style [OPTIONAL PARAMETER]
                  dropdownHeadingStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),

                  ///DropdownDialog Item style [OPTIONAL PARAMETER]
                  dropdownItemStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),

                  ///Dialog box radius [OPTIONAL PARAMETER]
                  dropdownDialogRadius: 10.0,

                  ///Search bar radius [OPTIONAL PARAMETER]
                  searchBarRadius: 10.0,

                  ///triggers once country selected in dropdown
                  onCountryChanged: (country) {
                    setState(() {
                      _selectedCountry = country;
                      _selectedState = null;
                      _selectedLga = null;
                    });
                  },
                  onStateChanged: (state) {
                    setState(() {
                      _selectedState = state;
                      _selectedLga = null;
                    });
                  },
                  onCityChanged: (lga) {
                    setState(() {
                      _selectedLga = lga;
                    });
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
                TextFormField(
                  controller: _cellNoController,
                  decoration: const InputDecoration(labelText: 'Cell Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the Inmates Cell Number';
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
        _type == 'update'
            ? ElevatedButton.icon(
                onPressed: _updateInmate,
                label: const Text('Update'),
                icon: const Icon(Icons.update_sharp),
              )
            : ElevatedButton.icon(
                onPressed: _saveInmate,
                label: const Text('Save'),
                icon: const Icon(Icons.save_sharp),
              ),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          label: const Text('Cancel'),
          icon: const Icon(Icons.cancel),
        ),
      ],
    );
  }
}
