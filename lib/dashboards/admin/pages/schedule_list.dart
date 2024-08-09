import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/multi_select_dialog.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/my_widgets.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/schedule_report.dart';
import 'package:inmateschedular_pro/services/inmate_services.dart';
import 'package:inmateschedular_pro/services/officer_services.dart';
import 'package:inmateschedular_pro/services/schedule_services.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:inmateschedular_pro/util/responsive.dart';
import 'package:provider/provider.dart';

class ScheduleList extends StatefulWidget {
  final String userId;
  final bool isSidebarCollapsed;
  final VoidCallback onToggleSidebar;

  ScheduleList({
    Key? key,
    required this.userId,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
  }) : super(key: key);

  @override
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  late ScheduleService _scheduleService;
  late InmateService _inmateService;
  late OfficerService _officerService;
  List<ScheduleModel> _schedules = [];
  List<ScheduleModel> _filteredSchedules = [];
  List<InmateModel> _allInmates = [];
  List<OfficerModel> _allOfficers = [];
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  String? _sortOption = 'Status';

  String? _selectedActivityType;
  String? _selectedActivity;
  List<String> _activities = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scheduleService = Provider.of<ScheduleService>(context, listen: false);
    _inmateService = Provider.of<InmateService>(context, listen: false);
    _officerService = Provider.of<OfficerService>(context, listen: false);

    _scheduleService.getSchedules().listen((schedules) {
      setState(() {
        _schedules = schedules;
        _filteredSchedules = schedules;
        _sortSchedules();
      });
    });

    _fetchAllInmates();
    _fetchAllOfficers();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterSchedules(_searchController.text);
    });
  }
  
  void _sortSchedules() {
    setState(() {
      _filteredSchedules.sort((a, b) {
        int statusComparison = _getStatusPriority(a).compareTo(_getStatusPriority(b));
        if (statusComparison != 0) return statusComparison;
        return (a.activity ?? '').compareTo(b.activity ?? '');
      });
    });
  }

  int _getStatusPriority(ScheduleModel schedule) {
    final now = DateTime.now();
    if (schedule.startTime == null || schedule.endTime == null) return 3;
    if (now.isBefore(schedule.startTime!)) return 2;
    if (now.isAfter(schedule.endTime!)) return 1;
    return 0;
  }

  void _onSortOptionChanged(String? newValue) {
    setState(() {
      _sortOption = newValue;
      _sortSchedules();
    });
  }
    
  Future<void> _fetchAllInmates() async {
    try {
      _allInmates = await _inmateService.fetchInmates(limit: 100);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching inmates: $e');
      }
    }
  }

  Future<void> _fetchAllOfficers() async {
    try {
      _allOfficers = await _officerService.fetchOfficers(limit: 100);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching officers: $e');
      }
    }
  }

  void _filterSchedules(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSchedules = _schedules;
      } else {
        _filteredSchedules = _schedules.where((schedule) {
          final activityMatch = schedule.activity?.toLowerCase().contains(query.toLowerCase()) ?? false;
          return activityMatch;
        }).toList();
      }
      _sortSchedules();
    });
  }

  void _updateActivities(String? activityType) {
    setState(() {
      _selectedActivityType = activityType;
      _activities = listActivities[activityType!] ?? [];
      _selectedActivity = null;
    });
  }

  Future<void> _showScheduleDialog({ScheduleModel? schedule}) async {
    List<String> inmatesSelectedIds = schedule?.inmates ?? [];
    List<String> selectedOfficerIds = schedule?.supervisors ?? [];
    DateTime? startTime = schedule?.startTime;
    DateTime? endTime = schedule?.endTime;

    final isEditing = schedule != null;

    if (isEditing) {
      try {
        _selectedActivityType = activityTypes.firstWhere(
          (type) => listActivities[type]?.contains(schedule.activity) ?? false,
          orElse: () => '', // Return an empty string instead of null
        );
        _selectedActivity = schedule.activity;
        _activities = listActivities[_selectedActivityType] ?? [];
      } catch (e) {
        debugPrint('error getting Selected activity === $e');
      }
    }

    return showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Schedule' : 'Add Schedule'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      hint: const Text('Select Activity Type'),
                      value: _selectedActivityType,
                      onChanged: (String? newValue) {
                        setState(() {
                          _updateActivities(newValue);
                        });
                      },
                      items: activityTypes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      hint: const Text('Select Activity'),
                      value: _selectedActivity,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedActivity = newValue;
                        });
                      },
                      items: _activities.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        try {
                          final selectedInmates = await showDialog<List<InmateModel>>(
                            context: context,
                            builder: (context) {
                              return MultiSelectDialog<InmateModel>(
                                items: _allInmates,
                                selectedItems: _allInmates.where((inmate) => inmatesSelectedIds.contains(inmate.id)).toList(),
                                title: 'Select Inmates',
                                itemToString: (inmate) => '${inmate.firstName} ${inmate.otherNames}',
                                itemToId: (inmate) => inmate.id!,
                              );
                            },
                          );

                          if (selectedInmates != null) {
                            setState(() {
                              inmatesSelectedIds = selectedInmates.map((inmate) => inmate.id!).toList();
                            });
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error selecting inmates: $e')),
                          );
                        }
                      },
                      child: inmatesSelectedIds.isEmpty
                          ? const Text('Select Inmates')
                          : Text.rich(
                              TextSpan(
                                children: _allInmates
                                    .where((inmate) => inmatesSelectedIds.contains(inmate.id))
                                    .map((inmate) {
                                      return TextSpan(
                                        text: '${inmate.firstName} ${inmate.otherNames}, ',
                                        style: const TextStyle(fontSize: 16.0),
                                      );
                                    }).toList(),
                              ),
                              overflow: TextOverflow.visible,
                            ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        try {
                          final selectedOfficers = await showDialog<List<OfficerModel>>(
                            context: context,
                            builder: (context) {
                              return MultiSelectDialog<OfficerModel>(
                                items: _allOfficers,
                                selectedItems: _allOfficers.where((officer) => selectedOfficerIds.contains(officer.id)).toList(),
                                title: 'Select Officers',
                                itemToString: (officer) => officer.name!,
                                itemToId: (officer) => officer.id!,
                              );
                            },
                          );

                          if (selectedOfficers != null) {
                            setState(() {
                              selectedOfficerIds = selectedOfficers.map((officer) => officer.id!).toList();
                            });
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error selecting officers: $e')),
                          );
                        }
                      },
                      child: selectedOfficerIds.isEmpty
                          ? const Text('Select Officers')
                          : Text.rich(
                              TextSpan(
                                children: _allOfficers
                                    .where((officer) => selectedOfficerIds.contains(officer.id))
                                    .map((officer) {
                                      return TextSpan(
                                        text: '${officer.name}, ',
                                        style: const TextStyle(fontSize: 16.0),
                                      );
                                    }).toList(),
                              ),
                              overflow: TextOverflow.visible,
                            ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        try {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: startTime ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(startTime ?? DateTime.now()),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                startTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                              });
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error selecting start time: $e')),
                          );
                        }
                      },
                      child: Text(startTime != null
                          ? 'Start Time: ${DateFormat('yyyy-MM-dd HH:mm').format(startTime!)}'
                          : 'Select Start Time'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        try {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: endTime ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(endTime ?? DateTime.now()),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                endTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                              });
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error selecting end time: $e')),
                          );
                        }
                      },
                      child: Text(endTime != null
                          ? 'End Time: ${DateFormat('yyyy-MM-dd HH:mm').format(endTime!)}'
                          : 'Select End Time'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(isEditing ? 'Save' : 'Add'),
                  onPressed: () async {
                    try {
                      if (_selectedActivity != null && startTime != null && endTime != null) {
                        final newSchedule = ScheduleModel(
                          id: schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          activity: _selectedActivity,
                          startTime: startTime,
                          endTime: endTime,
                          inmates: inmatesSelectedIds,
                          supervisors: selectedOfficerIds,
                        );
                        if (isEditing) {
                          await _scheduleService.updateSchedule(newSchedule);
                        } else {
                          await _scheduleService.addSchedule(newSchedule);
                        }
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isEditing ? 'Schedule Updated Successfully' : 'Schedule Added Successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all the required fields')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving schedule: $e')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _viewScheduleDialog(ScheduleModel schedule) async {
    try {
      List<String> supervisorNames = schedule.supervisors?.map((id) {
        var officer = _allOfficers.firstWhere((officer) => officer.id == id, orElse: () => OfficerModel(name: 'Unknown'));
        return officer.name ?? 'Unknown';
      }).toList() ?? [];

      List<String> inmateNames = schedule.inmates?.map((id) {
        var inmate = _allInmates.firstWhere((inmate) => inmate.id == id, orElse: () => InmateModel(firstName: 'Unknown', otherNames: ''));
        return '${inmate.firstName} ${inmate.otherNames}';
      }).toList() ?? [];

      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Schedule Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  ListTile(
                    title: const Text(
                      'Activity',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    subtitle: Text(
                      schedule.activity ?? 'No activity',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Start Time',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    subtitle: Text(
                      schedule.startTime != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(schedule.startTime!)
                          : 'Not set',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'End Time',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    subtitle: Text(
                      schedule.endTime != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(schedule.endTime!)
                          : 'Not set',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Supervisors',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    subtitle: Text.rich(
                      TextSpan(
                        children: supervisorNames.map((name) {
                          return TextSpan(
                            text: name,
                            style: const TextStyle(fontSize: 18.0),
                            children: [const TextSpan(text: ', ', style: TextStyle(color: Colors.transparent))],
                          );
                        }).toList(),
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Inmates',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    subtitle: Text.rich(
                      TextSpan(
                        children: inmateNames.map((name) {
                          return TextSpan(
                            text: name,
                            style: const TextStyle(fontSize: 18.0),
                            children: [const TextSpan(text: ', ', style: TextStyle(color: Colors.transparent))],
                          );
                        }).toList(),
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('Error displaying schedule details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error displaying schedule details.'),
        ),
      );
    }
  }
  
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export PDF Report'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add options to select parameters for PDF generation if needed
              // For simplicity, this example doesn't include any parameters
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _generatePdfReport();
              },
              child: const Text('Generate Report'),
            ),
          ],
        );
      },
    );
  }

  void _generatePdfReport() {
    final pdfGenerator = SchedulePdfReport(
      schedules: _filteredSchedules,
        officers: _allOfficers,
      context: context,
      appLogoPath: 'logo/logo1.jpeg',
      appName: 'InmateScheduler Pro'
      );

    pdfGenerator.generatePdf();
  }

  void _showPdfPreview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SchedulePdfPreview(
        schedules: _filteredSchedules,
        officers: _allOfficers,
        context: context,
        appLogoPath: 'logo/logo1.jpeg',
        appName: 'InmateScheduler Pro',
        ),
      ),
    );
  }

  void _deleteSchedule(String id) {
    showDeleteDialog(
      context: context,
      id: id,
      deleteFunction: _scheduleService.deleteSchedule,
    );
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          pageBar(context, widget.onToggleSidebar, 'List Of Schedules'),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.isMobile(context) ? 15 : 18),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                height: MediaQuery.of(context).size.height - 250,
                color: Colors.grey[200],
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => _showScheduleDialog(),
                          child: Responsive.isMobile(context)
                              ? const Icon(Icons.add)
                              : const Row(
                                  children: [
                                    Text(
                                      'New Schedule',
                                    ),
                                    Icon(Icons.add),
                                  ],
                                ),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _showExportDialog,
                              child: Responsive.isMobile(context)
                                  ? const Icon(Icons.download)
                                  : const Row(
                                      children: [
                                        Text('Import'),
                                        Icon(Icons.download),
                                      ],
                                    ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _showPdfPreview,
                              child: Responsive.isMobile(context)
                                  ? const Icon(Icons.upload)
                                  : const Row(
                                      children: [
                                        Text('Export'),
                                        Icon(Icons.upload),
                                      ],
                                    ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Divider(),
                    SizedBox(height: Responsive.isMobile(context) ? 5 : 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: _sortOption,
                          onChanged: _onSortOptionChanged,
                          items: <String>['Status', 'Activity']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Search',
                              suffixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.isMobile(context) ? 5 : 10),

                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredSchedules.length,
                        itemBuilder: (context, index) {
                          final schedule = _filteredSchedules[index];
                          
                          return _buildSchedule(schedule);
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule(ScheduleModel schedule) {
  try {
    
    bool isAllOfficers = schedule.supervisors?.length == _allOfficers.length;
    bool isAllInmates = schedule.inmates?.length == _allInmates.length;

    
    List<String> supervisorNames = schedule.supervisors?.map((id) {
      var officer = _allOfficers.firstWhere((officer) => officer.id == id, orElse: () => OfficerModel(name: 'Unknown'));
      return officer.name ?? 'Unknown';
    }).toList() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 30.0),
      child: GestureDetector(
        onTap: () => _viewScheduleDialog(schedule),
        child: Row(
          children: [
            Container(
              height: 130.0,
              width: 15.0,
              decoration: BoxDecoration(
                color: _getScheduleStatusColor(schedule),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                height: 130.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          schedule.activity ?? 'No activity',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          _getScheduleStatus(schedule),
                          style: TextStyle(
                            color: _getScheduleStatusColor(schedule),
                          ),
                        ),
                        if (schedule.startTime != null)
                          Row(
                            children: [
                              const Text(
                                'Start Time: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(DateFormat('yyyy-MM-dd HH:mm').format(schedule.startTime!))
                            ],
                          ),
                        if (schedule.endTime != null)
                          Row(
                            children: [
                              const Text(
                                'End Time: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(DateFormat('yyyy-MM-dd HH:mm').format(schedule.endTime!)),
                            ],
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Supervisors',
                              style: TextStyle(fontWeight: FontWeight.bold,),
                            ),
                            if (isAllOfficers)
                              const Text(
                                'All Officers',
                                style: TextStyle(fontSize: 18.0),
                              )
                            else
                              SizedBox(
                                height: 30.0,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: supervisorNames.map((name) => Text(
                                      name,
                                    )).toList(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5.0),
                        Row(
                          children: [
                            const Text(
                              'Inmates: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(isAllInmates ? 'All Inmates' : '${schedule.inmates?.length ?? 'Not Listed'}'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showScheduleDialog(schedule: schedule),
                ),
                const SizedBox(height: 5.0),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteSchedule(schedule.id!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      print('error building schedule === $e');
    }
    return const Text('An error occurred.');
  }
}
  
  String _getScheduleStatus(ScheduleModel schedule) {
    final now = DateTime.now();
    if (schedule.startTime == null || schedule.endTime == null) return 'Unknown';
    if (now.isBefore(schedule.startTime!)) return 'Upcoming';
    if (now.isAfter(schedule.endTime!)) return 'Completed';
    return 'Ongoing';
  }

  Color _getScheduleStatusColor(ScheduleModel schedule) {
    final now = DateTime.now();
    if (schedule.startTime == null || schedule.endTime == null) return Colors.grey;
    if (now.isBefore(schedule.startTime!)) return Colors.blue;
    if (now.isAfter(schedule.endTime!)) return Colors.orange;
    return Colors.green;
  }

}

