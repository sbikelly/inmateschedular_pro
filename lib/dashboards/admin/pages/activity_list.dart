import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/my_widgets.dart';
import 'package:inmateschedular_pro/services/activity_service.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

class ActivityList extends StatefulWidget {
  final String userId;
  final bool isSidebarCollapsed;
  final VoidCallback onToggleSidebar;

  ActivityList({
    Key? key,
    required this.userId,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
  }) : super(key: key);

  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  late final ActivityService _activityServices;
  List<ActivityModel> _activities = [];
  List<ActivityModel> _filteredActivities = [];
  String _searchQuery = '';
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _activityServices = Provider.of<ActivityService>(context, listen: false);

    _activityServices.getActivities().listen((activities) {
      setState(() {
        _activities = activities;
        _filteredActivities = activities;
      });
    });
  }

  void _filterActivities(String query) {
    setState(() {
      _searchQuery = query;
      _filteredActivities = _activities.where((activity) {
        return activity.title!.toLowerCase().contains(query.toLowerCase()) ||
               activity.description!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _showActivityDialog({ActivityModel? activity}) async {
  final titleController = TextEditingController(text: activity?.title);
  final descriptionController = TextEditingController(text: activity?.description);
  final locationController = TextEditingController(text: activity?.location);
  final durationController = TextEditingController(text: activity?.duration?.inMinutes.toString());
  String? photoUrl = activity?.photoUrl;
  XFile? pickedPhoto;

  final isEditing = activity != null;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    pickedPhoto = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedPhoto == null) {
      if (kDebugMode) {
        print('No image selected');
      }
    }
  }

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isEditing ? 'Edit Activity' : 'Add Activity'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                enableSuggestions: true,
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Describe the Activity'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'Educational Activities', child: Text('Educational Activities')),
                  DropdownMenuItem(value: 'Recreational Activities', child: Text('Recreational Activities')),
                  DropdownMenuItem(value: 'Rehabilitation Activities', child: Text('Rehabilitation Activities')),
                  DropdownMenuItem(value: 'Religious Activities', child: Text('Religious Activities')),
                  DropdownMenuItem(value: 'Family and Community Activities', child: Text('Family and Community Activities')),
                  DropdownMenuItem(value: 'Societal Re-integration Activities', child: Text('Societal Re-integration Activities')),
                  DropdownMenuItem(value: 'Hobby and Interest Groups Activities', child: Text('Hobby and Interest Groups Activities')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Select Activity Type'),
                icon: const Icon(Icons.person),
              ),
              TextField(
                controller: locationController,
                enableSuggestions: true,
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Enter Location'),
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(hintText: 'Enter Duration in Minutes'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: pickedPhoto != null
                      ? FileImage(File(pickedPhoto!.path))
                      : (photoUrl != null
                          ? NetworkImage(photoUrl!)
                          : const AssetImage('images/avatar.png')) as ImageProvider,
                ),
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
              if (pickedPhoto != null) {
                photoUrl = await _activityServices.uploadImage(pickedPhoto!.path);
              }

              final newActivity = ActivityModel(
                id: isEditing ? activity.id : null,
                title: titleController.text,
                description: descriptionController.text,
                location: locationController.text,
                type: _selectedType,
                photoUrl: photoUrl,
                duration: Duration(minutes: int.parse(durationController.text)),
              );

              if (isEditing) {
                await _activityServices.updateActivity(newActivity);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Activity Updated Succesfully!")),
                );
              } else {
                await _activityServices.addActivity(newActivity);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("New Activity Added Succesfully!")),
                );
              }

              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  void _viewActivity(ActivityModel activity) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(activity.title ?? 'No Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Description: ${activity.description ?? 'No Description'}'),
                Text('Location: ${activity.location ?? 'No Location Specified'}'),
                Text('Type: ${activity.type ?? 'Not Specified'}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        pageBar(context, widget.onToggleSidebar, 'List of Activities'),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (query) => _filterActivities(query),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _showActivityDialog(),
          child: const Text('Add Activity'),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return DynamicHeightGridView(
                itemCount: _filteredActivities.length,
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                builder: (context, index) {
                  final activity = _filteredActivities[index];

                  String getImageForTitle(String title) {
                    switch (title) {
                      case 'Games':
                        return 'images/games.png';
                      case 'Visitations':
                        return 'images/family.png';
                      case 'Worship Services':
                        return 'images/prayer.png';
                      case 'Farming And Gardening':
                        return 'images/farming.png';
                      case 'FootBall':
                        return 'images/football.png';
                      default:
                        return 'images/default_activity.png'; // Optional: set a default image if no case matches
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            height: constraints.maxHeight * 0.5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: activity.photoUrl != null
                                  ? Image.network(activity.photoUrl!, fit: BoxFit.cover)
                                  : Image.asset(getImageForTitle(activity.title ?? ''), fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activity.title ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(activity.description ?? ''),
                              Text('Location: ${activity.location ?? 'No Location Specified'}'),
                              Text('Type: ${activity.type ?? 'Not Specified'}'),
                              Text('Duration: ${activity.duration != null ? '${activity.duration!.inMinutes} minutes' : 'Not Specified'}'),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showActivityDialog(activity: activity),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: (){
                                _activityServices.deleteActivity(activity.id ?? '');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Activity Deleted Succesfully!")),
                                );
                              }
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}