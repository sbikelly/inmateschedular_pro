import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/my_widgets.dart';
import 'package:inmateschedular_pro/services/cell_services.dart';
import 'package:provider/provider.dart';

class CellList extends StatefulWidget {
  final String userId;
  final bool isSidebarCollapsed;
  final VoidCallback onToggleSidebar;

  CellList({
    Key? key,
    required this.userId,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
  }) : super(key: key);

  @override
  _CellListState createState() => _CellListState();
}

class _CellListState extends State<CellList> {
  late final CellService _cellService;
  List<CellModel> _cells = [];
  List<CellModel> _filteredCells = [];
  String _searchQuery = '';
  String? _selectedType;
  int? _selectedCapacity;

  @override
  void initState() {
    super.initState();
    _cellService = Provider.of<CellService>(context, listen: false);

    _cellService.getCells().listen((cells) {
      setState(() {
        _cells = cells;
        _filteredCells = cells;
      });
    });
  }

  void _filterCells(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCells = _cells.where((cell) {
        return cell.name!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _showCellDialog({CellModel? cell}) async {
    final nameController = TextEditingController(text: cell?.name);
    final typeController = TextEditingController(text: cell?.type);
    final capacityController = TextEditingController(text: cell?.capacity?.toString());
    List<String> occupants = cell?.occupants ?? [];
    
    if (cell != null) {
      _selectedType = cell.type;
      _selectedCapacity = cell.capacity;
    }

    final isEditing = cell != null;

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Cell' : 'Add Cell'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: cellTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedType = value;
                      _selectedCapacity = null; // Reset capacity when type changes
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Select Cell Type'),
                ),
                DropdownButtonFormField<int>(
                  value: _selectedCapacity,
                  items: _selectedType != null
                      ? cellCapacities[_selectedType]!.map((int capacity) {
                          return DropdownMenuItem<int>(
                            value: capacity,
                            child: Text(capacity.toString()),
                          );
                        }).toList()
                      : [],
                  onChanged: (int? value) {
                    setState(() {
                      _selectedCapacity = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Select Cell Capacity'),
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
                final newCell = CellModel(
                  id: isEditing ? cell!.id : null,
                  name: nameController.text,
                  type: _selectedType,
                  capacity: _selectedCapacity,
                  occupants: occupants,
                );

                if (isEditing) {
                  await _cellService.updateCell(newCell);
                } else {
                  await _cellService.addCell(newCell);
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _viewCell(CellModel cell) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(cell.name ?? 'No Name'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Type: ${cell.type ?? 'No Type'}'),
                Text('Capacity: ${cell.capacity ?? 'No Capacity'}'),
                Text('Occupants: ${cell.occupants?.join(', ') ?? 'No Occupants'}'),
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
        pageBar(context, widget.onToggleSidebar, 'List of Cells'),
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
            onChanged: (query) => _filterCells(query),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _showCellDialog(),
          child: const Text('Add Cell'),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return DynamicHeightGridView(
                itemCount: _filteredCells.length,
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                builder: (context, index) {
                  final cell = _filteredCells[index];
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
                          offset: Offset(0, 3),
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
                              child: Image.asset('images/cell.jpeg', fit: BoxFit.cover), // Placeholder image
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cell.name ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('Type: ${cell.type ?? ''}'),
                              Text('Capacity: ${cell.capacity ?? ''}'),
                              Text('Occupants: ${cell.occupants?.join(', ') ?? 'No Occupants'}'),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showCellDialog(cell: cell),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _cellService.deleteCell(cell.id ?? ''),
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
