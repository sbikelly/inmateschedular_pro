import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';
import 'package:universal_io/io.dart';

class ActivityService with ChangeNotifier {
  final CollectionReference activityCollection = FirebaseFirestore.instance.collection('activities');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addActivity(ActivityModel activity) {
    return activityCollection.add(activity.toJson());
  }

  Future<void> updateActivity(ActivityModel activity) {
    return activityCollection.doc(activity.id).update(activity.toJson());
  }

  Future<void> deleteActivity(String id) {
    return activityCollection.doc(id).delete();
  }

  Stream<List<ActivityModel>> getActivities() {
    return activityCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ActivityModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<String?> uploadImage(String filePath) async {
    File file = File(filePath);
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('activity_images/$fileName');
      UploadTask uploadTask = ref.putFile(file);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return null;
    }
  }
  
}
