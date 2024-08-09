import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/inmate_dialog.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/my_widgets.dart';
import 'package:inmateschedular_pro/services/inmate_services.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:inmateschedular_pro/util/responsive.dart';

class InmatesList extends StatefulWidget {
  final String userId;
  final bool isSidebarCollapsed;
  final VoidCallback onToggleSidebar;

  InmatesList({
    Key? key,
    required this.userId,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
  }) : super(key: key);

  @override
  _InmatesListState createState() => _InmatesListState();
}

class _InmatesListState extends State<InmatesList> {
  final TextEditingController _searchController = TextEditingController();
  final InmateService _inmateService = InmateService();
  Future<List<InmateModel>>? _inmateListFuture;
  List<InmateModel>? _allInmates;
  List<InmateModel>? _filteredInmates;
  int _rowsPerPage = 5;
  final int _rowsPerPageOptions = 5;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchAllInmates();
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
      _filterInmates(_searchController.text);
    });
  }

  Future<void> _fetchAllInmates() async {
    _inmateListFuture = _inmateService.fetchInmates(limit: 100);
    _inmateListFuture!.then((inmates) {
      setState(() {
        _allInmates = inmates;
        _filteredInmates = inmates;
      });
    }).catchError((e) {
      debugPrint('Error fetching inmates: $e');
    });
  }

  void _filterInmates(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredInmates = _allInmates;
      } else {
        _filteredInmates = _allInmates?.where((inmate) {
          return inmate.firstName!.toLowerCase().contains(searchText.toLowerCase()) ||
              inmate.otherNames!.toLowerCase().contains(searchText.toLowerCase());
        }).toList();
      }
    });
  }

  void _showInmateDialog(InmateModel? inmate) {
    showDialog(
      context: context,
      builder: (context) {
        return InmateDialog(inmate: inmate ?? InmateModel());
      },
    ).then((value) => _fetchAllInmates());
  }

  Future<void> _deleteInmate(InmateModel inmate) async {
    try {
      await _inmateService.deleteInmate(inmate.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inmate deleted successfully')),
      );
      _fetchAllInmates();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting inmate: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        pageBar(context, widget.onToggleSidebar, 'Inmates List'),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.isMobile(context) ? 15 : 18),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => _showInmateDialog(null),
                          child: Responsive.isMobile(context)
                              ? const Icon(Icons.add)
                              : const Row(
                                  children: [
                                    Text('Register New Inmate'),
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
                        ),
                      ],
                    ),
                    const Divider(),
                    SizedBox(height: Responsive.isMobile(context) ? 2 : 3),
                    _buildSearchBar(),
                    Expanded(
                      child: _buildDataTable(),
                    ),
                  ],
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
        const Text('Inmates', style: TextStyle(fontSize: 22),),
        SizedBox(
          width: 300.0,
          child: TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Inmates',
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
    return FutureBuilder<List<InmateModel>>(
      future: _inmateListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred while fetching inmates'),
          );
        } else {
          _allInmates = snapshot.data;
          _filteredInmates = _filteredInmates ?? _allInmates;
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth - 10),
                  child: PaginatedDataTable(
                    //header: _buildSearchBar(),
                    columns: const [
                      DataColumn(label: Text('S/N', style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text('Inmate ID', style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text('First Name', style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text('Other Names', style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text('DOB', style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text('State', style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text('L.G.A', style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text('Cell Number', style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold),)),
                    ],
                    source: InmateDataTableSource(_filteredInmates!, _showInmateDialog, _deleteInmate),
                    rowsPerPage: _rowsPerPage,
                    availableRowsPerPage: [_rowsPerPageOptions, _rowsPerPageOptions * 2, _rowsPerPageOptions * 3],
                    onRowsPerPageChanged: (rowsPerPage) {
                      setState(() {
                        _rowsPerPage = rowsPerPage ?? _rowsPerPageOptions;
                      });
                    },
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class InmateDataTableSource extends DataTableSource {
  final List<InmateModel> inmates;
  final Function(InmateModel?) onEdit;
  final Function(InmateModel) onDelete;

  InmateDataTableSource(this.inmates, this.onEdit, this.onDelete);

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= inmates.length) {
      return null;
    }
    final InmateModel inmate = inmates[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(inmate.inmateID ?? "")),
        DataCell(Text(inmate.firstName!)),
        DataCell(Text(inmate.otherNames!)),
        DataCell(Text(inmate.gender?? "")),
        DataCell(Text(inmate.dob?? "")),
        DataCell(Text(inmate.state?? "")),
        DataCell(Text(inmate.lga?? "")),
        DataCell(Text(inmate.cellNo?? "")),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEdit(inmate),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(inmate),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => inmates.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
