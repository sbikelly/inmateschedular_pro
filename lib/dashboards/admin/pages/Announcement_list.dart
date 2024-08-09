import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';
import 'package:inmateschedular_pro/services/announcement_services.dart';

class AnnouncementList extends StatefulWidget {
  final String userId;
  final bool isSidebarCollapsed;
  final VoidCallback onToggleSidebar;

  AnnouncementList({
    Key? key,
    required this.userId,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
  }) : super(key: key);

  @override
  _AnnouncementListState createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  final AnnouncementServices _announcementServices = AnnouncementServices();
  List<AnnouncementModel> _announcements = [];
  List<AnnouncementModel> _filteredAnnouncements = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _announcementServices.getAnnouncements().listen((announcements) {
      setState(() {
        _announcements = announcements;
        _filteredAnnouncements = announcements;
      });
    });
  }

  void _filterAnnouncements(String query) {
    setState(() {
      _searchQuery = query;
      _filteredAnnouncements = _announcements.where((announcement) {
        return announcement.title!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _showAnnouncementDialog({AnnouncementModel? announcement}) async {
    final TextEditingController titleController = TextEditingController(text: announcement?.title);
    final TextEditingController descriptionController = TextEditingController(text: announcement?.description);
    final TextEditingController dateController = TextEditingController(
      text: announcement != null ? DateFormat('yyyy-MM-dd').format(announcement.date!) : '',
    );

    final isEditing = announcement != null;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Announcement' : 'Add Announcement'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    enableSuggestions: true,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    enableSuggestions: true,
                    maxLines: null,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      hintText: 'yyyy-MM-dd',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the date';
                      }
                      return null;
                    },
                    readOnly: true,
                    onTap: () => _selectDate(context, dateController),
                  ),
                ],
              ),
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
                if (_formKey.currentState!.validate()) {
                  final newAnnouncement = AnnouncementModel(
                    id: isEditing ? announcement!.id : null,
                    title: titleController.text,
                    description: descriptionController.text,
                    date: DateFormat('yyyy-MM-dd').parse(dateController.text),
                  );

                  if (isEditing) {
                    await _announcementServices.updateAnnouncement(newAnnouncement);
                  } else {
                    await _announcementServices.addAnnouncement(newAnnouncement);
                  }

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _viewAnnouncement(AnnouncementModel announcement) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(announcement.title ?? 'No Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Description: ${announcement.description ?? 'No Description'}'),
                Text('Date: ${announcement.date != null ? DateFormat('yyyy-MM-dd').format(announcement.date!) : 'No Date'}'),
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
            onChanged: (query) => _filterAnnouncements(query),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _showAnnouncementDialog(),
          child: const Text('Add Announcement'),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: StreamBuilder<List<AnnouncementModel>>(
              stream: _announcementServices.getAnnouncements(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No announcements available'));
                } else {
                  _announcements = snapshot.data!;
                  _filteredAnnouncements = _searchQuery.isNotEmpty
                      ? _announcements.where((announcement) {
                          return announcement.title!.toLowerCase().contains(_searchQuery.toLowerCase());
                        }).toList()
                      : _announcements;

                  return ListView.builder(
                    itemCount: _filteredAnnouncements.length,
                    itemBuilder: (context, index) {
                      final announcement = _filteredAnnouncements[index];
                      return Row(
                        children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 30.0),
                                height: 130.0,
                                width: 15.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).disabledColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                  )
                                ),
                              ),
                              
                          Container(
                            margin: const EdgeInsets.only(bottom: 30.0),
                                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                                height: 130.0,
                                width: 326.0,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFA9DFD8),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12.0),
                                    bottomRight: Radius.circular(12.0),
                                  )
                                ),
                            child: ListTile(
                              title: Text(announcement.title ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Description: ${announcement.description ?? ''}'),
                                  Text('Date: ${announcement.date != null ? DateFormat('yyyy-MM-dd').format(announcement.date!) : ''}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showAnnouncementDialog(announcement: announcement),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _announcementServices.deleteAnnouncement(announcement.id ?? ''),
                                  ),
                                ],
                              ),
                              onTap: () => _viewAnnouncement(announcement),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
