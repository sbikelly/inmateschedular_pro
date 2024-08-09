import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';

class AnnouncementServices with ChangeNotifier {
  final CollectionReference announcementsCollection = FirebaseFirestore.instance.collection('announcements');

  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    try {
      await announcementsCollection.add(announcement.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Error adding announcement: $e');
      }
    }
  }

  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      await announcementsCollection.doc(announcement.id).update(announcement.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating announcement: $e');
      }
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await announcementsCollection.doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting announcement: $e');
      }
    }
  }

  Stream<List<AnnouncementModel>> getAnnouncements() {
    return announcementsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }
}
