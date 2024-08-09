import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inmateschedular_pro/services/user_model.dart';

class InmateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<List<InmateModel>> fetchInmates({int limit = 10, DocumentSnapshot? startAfter}) async {

    try {
  Query query = _firestore.collection('inmates').limit(limit);
  if (startAfter != null) {
    query = query.startAfterDocument(startAfter);
  }
  
  QuerySnapshot querySnapshot = await query.get();
  
  return querySnapshot.docs.map((doc) => InmateModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
} on Exception catch (e) {
  print('error fetching inmate from inmate services ================   $e');
  List<InmateModel> inmates = [];
  return inmates;
}


  }

  Future<void> addInmate(InmateModel inmate, /*File? photo*/) async {
    DocumentReference docRef = _firestore.collection('inmates').doc();
    /*
    String? photoUrl;
    if (photo != null) {
      photoUrl = await _uploadPhoto(docRef.id, photo);
    }
    */

    await docRef.set({
      'id': docRef.id,
      'inmateID': inmate.inmateID,
      'firstName': inmate.firstName,
      'otherNames': inmate.otherNames,
      'gender': inmate.gender,
      'dob': inmate.dob,
      'email': inmate.email,
      'phone': inmate.phone,
      'country': inmate.country,
      'state': inmate.state,
      'lga': inmate.lga,
      'cellNo': inmate.cellNo,
      'photo': inmate.photo,
    });
  }

  Future<void> updateInmate(InmateModel inmate, File? photo) async {
    String? photoUrl;
    if (photo != null) {
      photoUrl = await _uploadPhoto(inmate.id!, photo);
    }

    await _firestore.collection('inmates').doc(inmate.id).update({
      'firstName': inmate.firstName,
      'otherNames': inmate.otherNames,
      'gender': inmate.gender,
      'dob': inmate.dob,
      'email': inmate.email,
      'phone': inmate.phone,
      'country': inmate.country,
      'state': inmate.state,
      'lga': inmate.lga,
      'cellNo': inmate.cellNo,
      'inmateID': inmate.inmateID,
      'photo': photoUrl ?? inmate.photo,
    });
  }

  Future<void> deleteInmate(String id) async {
    await _firestore.collection('inmates').doc(id).delete();
  }

  Future<String?> _uploadPhoto(String id, File photo) async {
    try {
      Reference storageReference = _storage.ref().child('students/$id/photo');
      UploadTask uploadTask = storageReference.putFile(photo);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading photo: $e');
      }
      return null;
    }
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}

