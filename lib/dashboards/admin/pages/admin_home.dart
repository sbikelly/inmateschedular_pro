import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/charts.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/my_widgets.dart';
import 'package:inmateschedular_pro/services/inmate_services.dart';
import 'package:inmateschedular_pro/services/officer_services.dart';
import 'package:inmateschedular_pro/services/schedule_services.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:inmateschedular_pro/services/user_service.dart';
import 'package:inmateschedular_pro/util/responsive.dart';

class AdminHome extends StatefulWidget {
  final String userId;
  final bool isSidebarCollapsed;
  final VoidCallback onToggleSidebar;

  AdminHome({
    Key? key,
    required this.userId,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
  }) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final UserService _userService = UserService();
  final ScheduleService _scheduleService = ScheduleService();
  List<ScheduleModel> _filteredSchedules = [];
  final OfficerService _officerService = OfficerService();
  List<OfficerModel> _allOfficers = [];
  final InmateService _inmateService = InmateService();
  List<InmateModel> _allInmates = [];
  late Future<UserModel?> userModelFuture;
  late Future<Map<String, int>> statsFuture;
  late Stream<List<ScheduleModel>> scheduleStream;

  @override
  void initState() {
    super.initState();
    userModelFuture = _fetchUserData(widget.userId);
    statsFuture = _fetchStats();
    scheduleStream = _scheduleService.getSchedules();
    _scheduleService.getSchedules().listen((schedules) {
      setState(() {
        _filteredSchedules = schedules;
      });
    });
    _fetchAllInmates();
    _fetchAllOfficers();
  }

  Future<UserModel?> _fetchUserData(String userId) async {
    try {
      UserModel? user = await _userService.getUser(userId);
      return user;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  Future<Map<String, int>> _fetchStats() async {
    try {
      return await _userService.fetchStats();
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
      return {};
    }
  }

  Future<void> _fetchAllInmates() async {
    try {
      _allInmates = await _inmateService.fetchInmates(limit: 100);
    } catch (e) {
      debugPrint('Error fetching inmates: $e');
      throw('Error fetching inmates: $e');
    }
  }

  Future<void> _fetchAllOfficers() async {
    try {
      _allOfficers = await _officerService.fetchOfficers();
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching Officers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: userModelFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading user data: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No user data available'));
        } else {
          final userModel = snapshot.data!;
          return _buildContent(userModel);
        }
      },
    );
  }

  Widget _buildContent(UserModel userModel) {
    return FutureBuilder<Map<String, int>>(
      future: statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading statistics: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No statistics available'));
        } else {
          final stats = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                pageBar(context, widget.onToggleSidebar, 'Dashboard'),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.isMobile(context) ? 15 : 18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoCard(
                            title: 'Inmates',
                            data: stats['inmates'].toString(),
                            color: Colors.blue,
                            icon: Icons.people,
                          ),
                          _buildInfoCard(
                            title: 'Officers',
                            data: stats['officers'].toString(),
                            color: Colors.green,
                            icon: Icons.security,
                          ),
                          _buildInfoCard(
                            title: 'Activities',
                            data: stats['activities'].toString(),
                            color: Colors.orange,
                            icon: Icons.access_time,
                          ),
                          _buildInfoCard(
                            title: 'Schedules',
                            data: stats['schedules'].toString(),
                            color: const Color(0xFF63CF93),
                            icon: Icons.schedule,
                          ),
                          _buildInfoCard(
                            title: 'Users',
                            data: stats['users'].toString(),
                            color: Colors.purple,
                            icon: Icons.person,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildScheduleChart(),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                _buildInmatesChartCard(),
                                const SizedBox(height: 10),
                                _buildStaffChartCard(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String data,
    required Color color,
    required IconData icon,
  }) {
    final Color itemColor = Colors.white;
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        color: color.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: itemColor, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: itemColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: itemColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInmatesChartCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inmates',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: _buildInmatesChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffChartCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Officers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: _buildStaffChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildInmatesChart() {
    final maleInmates = _allInmates.where((inmate) => inmate.gender == 'Male').length;
    final femaleInmates = _allInmates.where((inmate) => inmate.gender == 'Female').length;

    // Calculate the percentage of male and female inmates
    final malePercentage = double.parse(((maleInmates / _allInmates.length) * 100).toStringAsFixed(1));
    final femalePercentage = double.parse(((femaleInmates / _allInmates.length) * 100).toStringAsFixed(1));

    return PieChartSample2(
      items: [
        PieChartItem(color: Colors.blue, value: malePercentage, title: 'Male'),
        PieChartItem(color: Colors.green, value: femalePercentage, title: 'Female'),
      ],
    );
  }

  Widget _buildStaffChart() {
    final maleStaff = _allOfficers.where((officer) => officer.gender == 'Male').length;
    final femaleStaff = _allOfficers.where((officer) => officer.gender == 'Female').length;

    // Calculate the percentage of male and female staff
    final malePercentage = double.parse(((maleStaff / _allOfficers.length) * 100).toStringAsFixed(1));
    final femalePercentage = double.parse(((femaleStaff / _allOfficers.length) * 100).toStringAsFixed(1));

    return PieChartSample2(
      items: [
        PieChartItem(color: Colors.blue, value: malePercentage, title: 'Male'),
        PieChartItem(color: Colors.green, value: femalePercentage, title: 'Female'),
      ],
    );
  }

  Widget _buildScheduleChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Chart',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 500,
            child: LineChartSample(schedules: _filteredSchedules),
          ),
        ],
      ),
    );
  }


}
