import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/dashboards/admin/pages/activity_list.dart';
import 'package:inmateschedular_pro/dashboards/admin/pages/admin_home.dart';
import 'package:inmateschedular_pro/dashboards/admin/pages/cells_list.dart';
import 'package:inmateschedular_pro/dashboards/admin/pages/inmates_list.dart';
import 'package:inmateschedular_pro/dashboards/admin/pages/officers_list.dart';
import 'package:inmateschedular_pro/dashboards/admin/pages/schedule_list.dart';
import 'package:inmateschedular_pro/dashboards/admin/pages/users_list.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/change_password.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/nav.dart';
import 'package:inmateschedular_pro/screens/user_profile.dart';
import 'package:inmateschedular_pro/services/auth_service.dart';
import 'package:inmateschedular_pro/services/navigator_service.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:inmateschedular_pro/services/user_service.dart';
import 'package:inmateschedular_pro/util/const.dart';
import 'package:inmateschedular_pro/util/responsive.dart';
import 'package:inmateschedular_pro/util/routes.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final UserService _userService = UserService();
  User? _currentUser;
  UserModel? userModel;
  bool _isSidebarCollapsed = false;
  String _currentRoute = 'dashboard';

  @override
  void initState() {
    super.initState();
    _currentUser = _userService.user; // Access the current user
    if (_currentUser != null) {
      _fetchUserData(_currentUser!.uid);
    }
  }


  Future<void> _fetchUserData(String userId) async {
    try {
      userModel = await _userService.getUser(userId);
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }
  }

  void _onRouteSelected(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  Widget _getSelectedPage() {
    try {
      switch (_currentRoute) {
        case 'inmatesList':
          return InmatesList(
            userId: _currentUser!.uid,
            isSidebarCollapsed: _isSidebarCollapsed,
            onToggleSidebar: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          );
        case 'officersList':
          return OfficersList(
            userId: _currentUser!.uid,
            isSidebarCollapsed: _isSidebarCollapsed,
            onToggleSidebar: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          );
        case 'activityList':
          return ActivityList(
            userId: _currentUser!.uid,
            isSidebarCollapsed: _isSidebarCollapsed,
            onToggleSidebar: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          );
        case 'cellList':
          return CellList(
            userId: _currentUser!.uid,
            isSidebarCollapsed: _isSidebarCollapsed,
            onToggleSidebar: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          );
        case 'schedules':
          return ScheduleList(
            userId: _currentUser!.uid,
            isSidebarCollapsed: _isSidebarCollapsed,
            onToggleSidebar: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          );
        case 'users':
          return UsersList(
            userId: _currentUser!.uid,
            isSidebarCollapsed: _isSidebarCollapsed,
            onToggleSidebar: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          );
        case 'user':
          return UserProfileScreen(
            userId: _currentUser!.uid,
            isSidebarCollapsed: _isSidebarCollapsed,
            onToggleSidebar: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          );
        case 'dashboard':
        default:
          return AdminHome(
            userId: _currentUser!.uid,
            isSidebarCollapsed: _isSidebarCollapsed,
            onToggleSidebar: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          );
      }
    } catch (e) {
      if (kDebugMode) {
        print('error getting selected page === $e');
      }
      return const Text('error getting selected page');
    }
  }

  
  @override
  Widget build(BuildContext context) {
    Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      key: _scaffoldKey,
      drawer: !Responsive.isDesktop(context) ? _buildDrawer() : null,
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Row(
                    children: [
                      if (Responsive.isDesktop(context))
                        SideNav(
                          isSidebarCollapsed: _isSidebarCollapsed,
                          currentRoute: _currentRoute,
                          onToggleSidebar: () {
                            setState(() {
                              _isSidebarCollapsed = !_isSidebarCollapsed;
                            });
                          },
                          onRouteSelected: _onRouteSelected,
                        ),
                      Expanded(
                        child: _getSelectedPage(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SideNav(
        isSidebarCollapsed: _isSidebarCollapsed,
        currentRoute: _currentRoute,
        onToggleSidebar: () {
          setState(() {
            _isSidebarCollapsed = !_isSidebarCollapsed;
          });
        },
        onRouteSelected: _onRouteSelected,
      ),
    );
  }

  Widget _buildTopBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 2,
      backgroundColor: mainColor,
      title: Row(
        children: [
          CircleAvatar(child: Image.asset('logo/logo1.jpeg')),
          const SizedBox(width: 10),
          const Text('InmateScheduler Pro'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // Handle notifications
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'profile':
                setState(() {
                  _currentRoute = 'user';
                });
                break;
              case 'change_password':
                showDialog(
                  context: context,
                  builder: (context) => ChangePasswordDialog(),
                );
                break;
              case 'logout':
                Provider.of<AuthService>(context, listen: false).signOut();
                Provider.of<NavigatorService>(context, listen: false).navigateTo(Routes.loginScreen);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'change_password',
              child: Row(
                children: [
                  Icon(Icons.lock),
                  SizedBox(width: 8),
                  Text('Change Password'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          child: Row(
            children: [
              Text(userModel?.firstName ?? 'No name'),
              const SizedBox(width: 5),
              CircleAvatar(
                backgroundImage: userModel?.photo != null ? NetworkImage(userModel!.photo.toString()) as ImageProvider : const AssetImage('images/avatar.png'),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
      leading: Responsive.isMobile(context)
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            )
          : null,
    );
  }
}
