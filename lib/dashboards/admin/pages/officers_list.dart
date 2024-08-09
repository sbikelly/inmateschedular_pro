import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/my_widgets.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/officer_dialog.dart';
import 'package:inmateschedular_pro/services/officer_services.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:inmateschedular_pro/util/responsive.dart';

class OfficersList extends StatefulWidget {
  final String userId;
  final bool isSidebarCollapsed;
  final VoidCallback onToggleSidebar;

  OfficersList({
    Key? key,
    required this.userId,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
  }) : super(key: key);

  @override
  _OfficersListState createState() => _OfficersListState();
}

class _OfficersListState extends State<OfficersList> {
  final TextEditingController _searchController = TextEditingController();
  final OfficerService _officerService = OfficerService();
  List<OfficerModel> _allOfficers = [];
  List<OfficerModel> _filteredOfficers = [];
  bool _isLoading = false;
  Timer? _debounce;
  int _rowsPerPage = 5;
  final int _rowsPerPageOptions = 5;

  @override
  void initState() {
    super.initState();
    _fetchAllOfficers();
    _searchController.addListener(_onSearchChanged);
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
      _filterOfficers(_searchController.text);
    });
  }

  Future<void> _fetchAllOfficers() async {
    setState(() => _isLoading = true);
    try {
      _allOfficers = await _officerService.fetchOfficers();
      _filteredOfficers = _allOfficers;
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Officers: $e');
      }
    }
    setState(() => _isLoading = false);
  }

  void _filterOfficers(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredOfficers = _allOfficers;
      } else {
        _filteredOfficers = _allOfficers.where((officer) {
          return officer.name!.toLowerCase().contains(searchText.toLowerCase()) ||
              officer.officerID!.toLowerCase().contains(searchText.toLowerCase());
        }).toList();
      }
    });
  }

  void _confirmDeleteOfficer(BuildContext context, OfficerModel officer) async {
    final bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this Officer?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      _deleteOfficer(officer);
    }
  }

  void _deleteOfficer(OfficerModel officer) async {
    setState(() => _isLoading = true);
    try {
      await _officerService.deleteOfficer(officer.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted successfully')),
      );
      _fetchAllOfficers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting Record: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  void _showOfficerDialog(BuildContext context, OfficerModel? officer, String dialogType) {
    showDialog(
      context: context,
      builder: (context) {
        return OfficerDialog(officer: officer ?? OfficerModel(), dialogType: dialogType);
      },
    ).then((value) => _fetchAllOfficers());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        pageBar(context, widget.onToggleSidebar, 'Officers List'),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.isMobile(context) ? 15 : 18),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // card header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => _showOfficerDialog(context, null, 'add'),
                            child: Responsive.isMobile(context)
                                ? const Icon(Icons.add)
                                : const Row(
                                    children: [
                                      Text(
                                        'Register',
                                      ),
                                      Icon(Icons.add),
                                    ],
                                  ),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
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
                                onPressed: () {},
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
                      SizedBox(height: Responsive.isMobile(context) ? 2 : 3),
                      _buildSearchBar(),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildDataTable(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Officers', style: TextStyle(fontSize: 22),),
        SizedBox(
          width: 300.0,
          child: TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Officers',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: PaginatedDataTable(
              header: Text('Officers'),
              columns: const [
                DataColumn(label: Text('S/N', style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('Officer ID', style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('DOB', style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('State', style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('L.G.A', style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold),)),
              ],
              source: OfficerDataTableSource(context, _filteredOfficers, _showOfficerDialog, _confirmDeleteOfficer),
              rowsPerPage: _rowsPerPage,
              availableRowsPerPage: [_rowsPerPageOptions, _rowsPerPageOptions * 2, _rowsPerPageOptions * 3],
              onRowsPerPageChanged: (rowsPerPage) {
                setState(() {
                  _rowsPerPage = rowsPerPage ?? _rowsPerPageOptions;
                });
              },
              onPageChanged: (pageIndex) {
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }
}

class OfficerDataTableSource extends DataTableSource {
  BuildContext context;
  final List<OfficerModel> officers;
  final Function(BuildContext, OfficerModel?, String) onEdit;
  final Function(BuildContext, OfficerModel) onDelete;

  OfficerDataTableSource(this.context, this.officers, this.onEdit, this.onDelete);

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= officers.length) return null;
    final OfficerModel officer = officers[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(officer.officerID!)),
        DataCell(Text(officer.name!)),
        DataCell(Text(officer.gender??"")),
        DataCell(Text(officer.dob.toString())),
        DataCell(Text(officer.rank??"")),
        DataCell(Text(officer.phone??"")),
        DataCell(Text(officer.email??"")),
        DataCell(Text(officer.state??"")),
        DataCell(Text(officer.lga??"")),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEdit(context, officer, 'edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(context, officer),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => officers.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
