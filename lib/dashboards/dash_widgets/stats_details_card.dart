import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/card.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/my_widgets.dart';
import 'package:inmateschedular_pro/services/user_service.dart';
import 'package:inmateschedular_pro/util/responsive.dart';

class StatsDetailsCards extends StatelessWidget {
  StatsDetailsCards({super.key});

  final UserService _userService = UserService();

  final List<StatsModel> statsCardDetails = const [
    StatsModel(icon: Icon(Icons.local_police, color: Colors.white), bgColor: Colors.blue, title: "Officers", value: ''),
    StatsModel(icon: Icon(Icons.people, color: Colors.white), bgColor: Colors.green, title: "Inmates", value: ''),
    StatsModel(icon: Icon(Icons.event_note, color: Colors.white), bgColor: Colors.cyan, title: "Activities", value: ''),
    StatsModel(icon: Icon(Icons.vpn_key, color: Colors.white), bgColor: Colors.amber, title: "Cells", value: ''),
  ];


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _userService.fetchStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GridView.builder(
            itemCount: statsCardDetails.length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
              crossAxisSpacing: !Responsive.isMobile(context) ? 15 : 12,
              mainAxisSpacing: 12.0,
            ),
            itemBuilder: (context, i) {
              return MyCard(
                color: Colors.white,
                child: LoadingCard(
                title: statsCardDetails[i].title, 
                icon: statsCardDetails[i].icon, 
                bgColor: statsCardDetails[i].title
              ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching statistics'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return GridView.builder(
            itemCount: statsCardDetails.length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
              crossAxisSpacing: !Responsive.isMobile(context) ? 15 : 12,
              mainAxisSpacing: 12.0,
            ),
            itemBuilder: (context, i) {
              return MyCard(
                child: emptyCard(
                  title: statsCardDetails[i].title, 
                  icon: statsCardDetails[i].icon, 
                  bgColor: statsCardDetails[i].bgColor
                )
              );
            },
          );
          
        }

        final statsData = snapshot.data!;
        final updatedDetails = [
          StatsModel(icon: Icon(Icons.local_police, color: Colors.white), bgColor: Colors.blue, title: "Officers", value: statsData['officers'].toString()),
          StatsModel(icon: Icon(Icons.people, color: Colors.white), bgColor: Colors.green, title: "Inmates", value: statsData['inmates'].toString()),
          StatsModel(icon: Icon(Icons.event_note, color: Colors.white), bgColor: Colors.cyan, title: "Activities", value: statsData['activities'].toString()),
          StatsModel(icon: Icon(Icons.vpn_key, color: Colors.white), bgColor: Colors.amber, title: "Cells", value: statsData['cells'].toString()),
        ];

        return GridView.builder(
          itemCount: updatedDetails.length,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
            crossAxisSpacing: !Responsive.isMobile(context) ? 15 : 12,
            mainAxisSpacing: 12.0,
          ),
          itemBuilder: (context, i) {
            return MyCard(
              color: updatedDetails[i].bgColor,
              child: valueCard(
                title: updatedDetails[i].title, 
                value: updatedDetails[i].value, 
                icon: updatedDetails[i].icon,
              )
            
            );
          },
        );
      },
    );
  }
}
