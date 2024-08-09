import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/util/aboutDialog.dart';
import 'package:inmateschedular_pro/util/const.dart';

class SideNav extends StatelessWidget {
  final bool isSidebarCollapsed;
  final VoidCallback onToggleSidebar;
  final String currentRoute;
  final void Function(String) onRouteSelected;

  const SideNav({
    Key? key,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
    required this.currentRoute,
    required this.onRouteSelected,
  }) : super(key: key);

  Widget _buildSidebarItem(String title, String route, IconData icon, {BuildContext? context}) {
    final bool isActive = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isActive ? mainColor : Colors.black),
      title: isSidebarCollapsed ? null : Text(title, style: TextStyle(color: isActive ? mainColor : Colors.black)),
      onTap: () {
        if (route == 'about') {
          AboutDialogHelper.show(context!);
        } else {
          onRouteSelected(route);
        }
      },
      tileColor: isActive ? Colors.grey[200] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,  // Adjust the elevation value as needed
      child: AnimatedContainer(
        color: Colors.white,
        duration: const Duration(milliseconds: 300),
        width: isSidebarCollapsed ? 70 : 200,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSidebarItem('Dashboard', 'dashboard', Icons.dashboard),
                  _buildSidebarItem('Officers List', 'officersList', Icons.people_sharp),
                  _buildSidebarItem('Inmates List', 'inmatesList', Icons.people),
                  _buildSidebarItem('Activity List', 'activityList', Icons.book),
                  _buildSidebarItem('Cell List', 'cellList', Icons.room),
                  _buildSidebarItem('Schedules', 'schedules', Icons.task),
                  _buildSidebarItem('Users', 'users', Icons.group),
                  //_buildSidebarItem('Announcements', 'announcements', Icons.announcement),
                  _buildSidebarItem('About', 'about', Icons.info, context: context),
                ],
              ),
            ),
            ListTile(
              leading: Icon(isSidebarCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios),
              onTap: onToggleSidebar,
            ),
          ],
        ),
      ),
    );
  }
}
