import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GraphModel {
  final double x;
  final double y;

  GraphModel({required this.x, required this.y});
}

class BarGraphModel {
  String lable;
  Color color;
  List<GraphModel> graph;

  BarGraphModel(
      {required this.lable, required this.color, required this.graph});
}


class StatsModel {
  final Icon icon;
  final String value;
  final String title;
  final Color? bgColor;
  const StatsModel(
      {required this.icon, required this.value, this.bgColor, required this.title});
}


class ActivityModel {
  String? id;
  String? title;
  String? description;
  List<String>? officers;
  String? location;
  String? type;
  String? photoUrl;
  Duration? duration;

  ActivityModel({this.id, this.title, this.description, this.officers, this.location, this.type, this.photoUrl, this.duration});

  factory ActivityModel.fromMap(Map<String, dynamic> data, String documentId) {
    try {
      return ActivityModel(
        id: documentId,
        title: data['title'] as String?,
        description: data['description'] as String?,
        officers: List<String>.from(data['officers'] ?? []),
        location: data['location'] as String?,
        type: data['type'] as String?,
        photoUrl: data['photoUrl'] as String?,
        duration: data['duration'] != null ? Duration(minutes: data['duration']) : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Activity Data from Snapshot === $e');
      }
      return ActivityModel();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'officers': officers,
      'location': location,
      'type': type,
      'photoUrl': photoUrl,
      'duration': duration?.inMinutes,
    };
  }
}


class CellModel {
  String? id;
  String? name;
  String? type;
  int? capacity;
  List<String>? occupants;

  CellModel({this.id, this.name, this.type, this.capacity, this.occupants});

  factory CellModel.fromMap(Map<String, dynamic> data, String documentId) {
    try {
      return CellModel(
        id: documentId,
        name: data['name'] as String?,
        type: data['type'] as String?,
        capacity: data['capacity'] as int?,
        occupants: List<String>.from(data['occupants'] ?? []),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Cell Data from Snapshot === $e');
      }
      return CellModel();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'capacity': capacity,
      'occupants': occupants,
    };
  }
}



const List<String> cellTypes = [
  'General Population Cells',
  'High-Security Cells',
  'Isolation or Solitary Confinement Cells',
  'Medical Cells',
  'Juvenile Cells',
  'Female Cells',
  'Death Row Cells',
  'Transit or Holding Cells'
];

const Map<String, List<int>> cellCapacities = {
  'General Population Cells': [10, 20],
  'High-Security Cells': [1, 2, 4],
  'Isolation or Solitary Confinement Cells': [1],
  'Medical Cells': [1, 2, 3, 4],
  'Juvenile Cells': [5, 10],
  'Female Cells': [10, 20],
  'Death Row Cells': [1, 2],
  'Transit or Holding Cells': [5, 10]
};


class ScheduleModel {
  String? id;
  List<String>? inmates;
  List<String>? supervisors;
  String? activity;
  DateTime? startTime;
  DateTime? endTime;

  ScheduleModel({this.id, this.inmates, this.supervisors, this.activity, this.startTime, this.endTime});

  factory ScheduleModel.fromMap(Map<String, dynamic> data, String documentId) {
    try {
      return ScheduleModel(
        id: documentId,
        inmates: List<String>.from(data['inmates'] ?? []),
        supervisors: List<String>.from(data['supervisors'] ?? []),
        activity: data['activity'] as String?,
        startTime: (data['startTime'] as Timestamp?)?.toDate(),
        endTime: (data['endTime'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Schedule Data from Snapshot === $e');
      }
      return ScheduleModel();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': id,
      'inmates': inmates,
      'supervisors': supervisors,
      'activity': activity,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

final Map<String, List<String>> listActivities = {
  'Recreational Activities': ['Sports and Fitness','Arts and Crafts','Music Programs','Farming and Gardening'],
  'Rehabilitation Activities': ['Substance Abuse Programs','Mental Health Counseling','Anger Management','Life Skills Training'],
  'Religious Activities': ['Worship Services', 'Religious Study Groups', 'Spiritual Counseling'],
  'Family and Community Activities': ['Visitation Programs', 'Family Counseling', 'Community Service'],
  'Societal Re-integration Activities': ['Job Placement Assistance', 'Housing Assistance', 'Legal Aid'],
  'Hobby and Interest Groups Activities': ['Book Clubs', 'Writing Workshops', 'Chess and Board Games'],
};

final List<String> activityTypes = [
  'Recreational Activities',
  'Rehabilitation Activities',
  'Religious Activities',
  'Family and Community Activities',
  'Societal Re-integration Activities',
  'Hobby and Interest Groups Activities',
];

class AnnouncementModel {
  String? id;
  String? title;
  String? description;
  DateTime? date;

  AnnouncementModel({this.id, this.title, this.description, this.date});

  factory AnnouncementModel.fromMap(Map<String, dynamic> data, String documentId) {
    try {
      return AnnouncementModel(
        id: documentId,
        title: data['title'] as String?,
        description: data['description'] as String?,
        date: (data['date'] as Timestamp).toDate(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Announcement Data from Snapshot: $e');
      }
      return AnnouncementModel();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date,
    };
  }
}

