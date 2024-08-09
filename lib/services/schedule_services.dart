import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';

class ScheduleService {
  final CollectionReference scheduleCollection = FirebaseFirestore.instance.collection('schedules');

  Stream<List<ScheduleModel>> getSchedules() {
    return scheduleCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ScheduleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    try {
      await scheduleCollection.add(schedule.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Error adding schedule: $e');
      }
    }
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    try {
      await scheduleCollection.doc(schedule.id).update(schedule.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating schedule: $e');
      }
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await scheduleCollection.doc(scheduleId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting schedule: $e');
      }
    }
  }
}
