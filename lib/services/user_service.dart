import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

import 'user_model.dart';

class UserService {
  
  final CollectionReference<Map<String, dynamic>> userCollection = FirebaseFirestore.instance.collection("users");
  User? user = FirebaseAuth.instance.currentUser;

  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await userCollection.get();
      debugPrint(querySnapshot.docs[0].toString());
      return querySnapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<void> addUser(UserModel user) async {
    try {
      DocumentReference docRef = userCollection.doc();
      await docRef.set(user.toFirestore());
    } catch (e) {
      throw Exception('Error adding user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await userCollection.doc(userId).get();
      if (docSnapshot.exists) {
        return UserModel.fromSnapshot(docSnapshot);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
    return null;
  }

  Stream<List<UserModel>> readData() {
    try {
      return userCollection.snapshots().map((querySnapshot) =>
          querySnapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList());
    } catch (e) {
      debugPrint('Error reading data: $e');
      return const Stream.empty(); 
    }
  }

  Future<void> createUser(UserModel user, {File? photoFile}) async {
    String? photoUrl;
    try {
      if (photoFile != null) {
        photoUrl = await _uploadPhoto(photoFile, user.id!);
        user.photo = photoUrl;
      }
    } on Exception catch (e) {
      debugPrint('error uploading picture === $e');
      throw('error uploading picture == $e');
    }

    try {
      await userCollection.doc(user.id).set(user.toJson());
    } catch (e) {
      debugPrint('Error creating user data: $e');
      throw Exception("Error creating user data");
    }
  }

  Future<void> updateUser(UserModel userModel, {File? photoFile}) async {
    
    String? photoUrl;

    try {
      if (photoFile != null) {
        photoUrl = await _uploadPhoto(photoFile, userModel.id!);
        userModel.photo = photoUrl;
      }
    } on Exception catch (e) {
      debugPrint('error uploading picture === $e');
      throw('error uploading picture == $e');
    }

    try {
      final newData = userModel.toJson();
      await userCollection.doc(userModel.id).update(newData);
    } catch (e) {
      debugPrint('Error updating user data: $e');
      throw Exception("Error updating user data");
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await userCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      throw Exception("Error deleting user data");
    }
  }

  Future<Map<String, int>> fetchStats() async {
    try {
      final inmatesCount = (await FirebaseFirestore.instance.collection('inmates').get()).docs.length;
      final officersCount = (await FirebaseFirestore.instance.collection('officers').get()).docs.length;
      final activitiesCount = (await FirebaseFirestore.instance.collection('activities').get()).docs.length;
      final schedulesCount = (await FirebaseFirestore.instance.collection('schedules').get()).docs.length;
      final usersCount = (await userCollection.get()).docs.length;

      return {
        'users': usersCount,
        'inmates': inmatesCount,
        'officers': officersCount,
        'activities': activitiesCount,
        'schedules': schedulesCount,
      };
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
      throw Exception("Error fetching statistics");
    }
  }

  Future<String> _uploadPhoto(File photoFile, String userId) async {
    try {
      final ref = FirebaseStorage.instance.ref('user_photos/$userId');
      final uploadTask = ref.putBlob(photoFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      throw Exception("Error uploading photo");
    }
  }
}
