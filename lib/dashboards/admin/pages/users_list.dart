import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/my_widgets.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/users_dialog.dart';
import 'package:inmateschedular_pro/services/auth_service.dart';
import 'package:inmateschedular_pro/services/firestore_service.dart'; // Import the generic service
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:inmateschedular_pro/util/responsive.dart';
import 'package:provider/provider.dart';

class UsersList extends StatefulWidget {
  final String userId;
  final bool isSidebarCollapsed;
  final VoidCallback onToggleSidebar;

  const UsersList({
    super.key,
    required this.userId,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
  });

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  late FirestoreService<UserModel> _userService; // Use the generic service
  late AuthService _authService;
  Future<List<UserModel>>? _userListFuture;
  List<UserModel>? _users;
  List<UserModel>? _filteredUsers;
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = 5;
  final int _rowsPerPageOptions = 5;

  @override
  void initState() {
    super.initState();
    _userService = FirestoreService<UserModel>(
      collectionName: 'users',
      fromSnapshot: (snapshot) => UserModel.fromSnapshot(snapshot),
      toJson: (user) => user.toJson(),
    );
    _authService = Provider.of<AuthService>(context, listen: false);
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _fetchUsers() async {
    _userListFuture = _userService.getAll().first;
    _userListFuture!.then((users) {
      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    }).catchError((e) {
      debugPrint('Error fetching users: $e');
    });
  }

  void _filterUsers() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users?.where((user) {
        return user.firstName!.toLowerCase().contains(searchTerm) ||
            user.otherNames!.toLowerCase().contains(searchTerm) ||
            user.email!.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  void _openUserFormDialog(UserModel? user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserFormDialog(
          user: user,
          onSave: (UserModel updatedUser) async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => LoadingDialog(msg: user == null ? 'Adding User' : 'Updating User'),
            );
            if (user == null) {
              User? newUser = await _authService.signUp(updatedUser.email!, '123456');
              if (newUser != null) {
                updatedUser.id = newUser.uid;
                await _userService.add(updatedUser);
              }
            } else {
              await _userService.update(updatedUser.id!, updatedUser);
            }
            _fetchUsers();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(user == null ? 'User Added Successfully' : 'User Updated Successfully')),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(msg: 'Deleting User'),
    );
    try {
      await _userService.delete(user.id!);
      await _authService.deleteUser(user.email!);
      _fetchUsers();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      debugPrint('Error deleting user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        pageBar(context, widget.onToggleSidebar, 'Users'),
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
                            onPressed: () => _openUserFormDialog(null),
                            child: Responsive.isMobile(context)
                                ? const Icon(Icons.add)
                                : const Row(
                                    children: [
                                      Text(
                                        'Add User',
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
                      SizedBox(height: Responsive.isMobile(context) ? 5 : 10),
                      const Divider(),
                      SizedBox(height: Responsive.isMobile(context) ? 5 : 10),
                      _buildDataTable(),
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
        const Text('Users'),
        SizedBox(
          width: 300.0,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Users',
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
    return FutureBuilder<List<UserModel>>(
        future: _userListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred while fetching users'),
            );
          } else {
            _users = snapshot.data;
            _filteredUsers = _filteredUsers ?? _users;
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth - 10),
                    child: PaginatedDataTable(
                      header: _buildSearchBar(),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'S/N',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'First Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Other Names',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Email',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Phone',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Actions',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: UserDataTableSource(_filteredUsers!, _openUserFormDialog, _deleteUser),
                      rowsPerPage: _rowsPerPage,
                      availableRowsPerPage: [
                        _rowsPerPageOptions,
                        _rowsPerPageOptions * 2,
                        _rowsPerPageOptions * 3
                      ],
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
        });
  }
}

class UserDataTableSource extends DataTableSource {
  final List<UserModel> users;
  final Function(UserModel?) onEdit;
  final Function(UserModel) onDelete;

  UserDataTableSource(this.users, this.onEdit, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final UserModel user = users[index];
    return DataRow(
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(user.firstName ?? '')),
        DataCell(Text(user.otherNames ?? '')),
        DataCell(Text(user.email ?? '')),
        DataCell(Text(user.phone ?? '')),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onEdit(user),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onDelete(user),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => users.length;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get selectedRowCount => 0;
}
