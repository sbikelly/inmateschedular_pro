 import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/util/const.dart';
import 'package:inmateschedular_pro/util/responsive.dart';

Widget pageBar(BuildContext context, VoidCallback toggle, String page) {
  return Container(
    color: Colors.white, // Background color for the top bar
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Row(
      children: [
        if (Responsive.isDesktop(context))
          InkWell(
            onTap: toggle,
            child: const Padding(
              padding: EdgeInsets.all(3.0),
              child: Icon(
                Icons.menu,
                color: mainColor, // Icon color
                size: 25,
              ),
            ),
          )
        else
          const SizedBox.shrink(), // Use SizedBox.shrink() as an empty placeholder
        Expanded(
          child: Center(
            child: Text(
              'Admin | $page',
                style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


Widget LoadingCard({required title, required icon, required bgColor}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        const Padding(
          padding: EdgeInsets.only(top: 15, bottom: 4),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
}

Widget valueCard({required title, required value, required icon}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 4),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
            
}

Widget emptyCard({required title, required icon, required bgColor}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        const Padding(
          padding: EdgeInsets.only(top: 15, bottom: 4),
          child: Text(
            '',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
            
}

void showDeleteDialog({
  required BuildContext context,
  required String id,
  required Function(String id) deleteFunction,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              deleteFunction(id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item Deleted Successfully'),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

Widget buildOfficersList() {
    // Placeholder for officers list
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Officer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Add your officers list here
            ListView.builder(
              shrinkWrap: true,
              itemCount: 10, // Replace with actual number of officers
              itemBuilder: (context, index) {
                return const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    // Replace with actual officer image
                  ),
                  title: Text("Name"),
                  subtitle: Text("Rank"),
                  trailing: Icon(Icons.circle, color: Colors.green, size: 12),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
Widget buildInmates() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Officer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Add your officers list here
            ListView.builder(
              shrinkWrap: true,
              itemCount: 10, // Replace with actual number of officers
              itemBuilder: (context, index) {
                return const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    // Replace with actual officer image
                  ),
                  title: Text('Name'),
                  subtitle: Text('Rank'),
                  trailing: Icon(Icons.circle, color: Colors.green, size: 12),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

class LoadingDialog extends StatelessWidget {
  final String msg;
  
  const LoadingDialog({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        //mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Text('$msg ...'),
        ],
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}