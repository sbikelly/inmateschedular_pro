import 'package:flutter/material.dart';

class MultiSelectDialog<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String title;
  final String Function(T) itemToString;
  final String Function(T) itemToId;

  const MultiSelectDialog({
    Key? key,
    required this.items,
    required this.selectedItems,
    required this.title,
    required this.itemToString,
    required this.itemToId,
  }) : super(key: key);

  @override
  _MultiSelectDialogState<T> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<MultiSelectDialog<T>> {
  late List<T> _tempSelectedItems;
  late List<T> _filteredItems;
  bool _selectAll = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelectedItems = List.from(widget.selectedItems);
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    try {
      setState(() {
        _filteredItems = widget.items.where((item) {
          final itemString = widget.itemToString(item).toLowerCase();
          return itemString.contains(_searchController.text.toLowerCase());
        }).toList();
      });
    } catch (e) {
      debugPrint('Error filtering items: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search',
              suffixIcon: Icon(Icons.search),
            ),
          ),
          CheckboxListTile(
            value: _selectAll,
            title: const Text('Select All'),
            onChanged: (isChecked) {
              try {
                setState(() {
                  _selectAll = isChecked!;
                  if (_selectAll) {
                    _tempSelectedItems = List.from(_filteredItems);
                  } else {
                    _tempSelectedItems.clear();
                  }
                });
              } catch (e) {
                debugPrint('Error toggling select all: $e');
              }
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListBody(
                children: _filteredItems.map((item) {
                  return CheckboxListTile(
                    value: _tempSelectedItems.contains(item),
                    title: Text(widget.itemToString(item)),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) {
                      try {
                        setState(() {
                          if (isChecked!) {
                            _tempSelectedItems.add(item);
                          } else {
                            _tempSelectedItems.remove(item);
                          }
                        });
                      } catch (e) {
                        debugPrint('Error selecting item: $e');
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(_tempSelectedItems);
          },
        ),
      ],
    );
  }
}
