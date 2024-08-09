import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:universal_io/io.dart';

class OfficerService {  

  final CollectionReference _officersCollection = FirebaseFirestore.instance.collection('officers');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<OfficerModel>> fetchOfficers({int limit = 10, DocumentSnapshot? startAfter}) async {
    try {
      Query query = _officersCollection.limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => OfficerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching officers: $e');
      }
      return [];
    }
  }

  Future<void> addOfficer(OfficerModel officer, File? photo) async {
    try {
      DocumentReference docRef = _officersCollection.doc();
      String? photoUrl;
      if (photo != null) {
        photoUrl = await uploadPhoto(docRef.id, photo);
      }
      print('services = ${officer.rank}');

      await docRef.set({
        'id': docRef.id,
        'officerID': officer.officerID,
        'name': officer.name,
        'email': officer.email,
        'photo': photoUrl,
        'phone': officer.phone,
        'dob': officer.dob,
        'nationality': officer.nationality,
        'state': officer.state,
        'lga': officer.lga,
        'gender': officer.gender,
        'rank': officer.rank,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding officer: $e');
      }
    }
  }

  Future<void> updateOfficer(OfficerModel officer, File? photo) async {
    try {
      String? photoUrl;
      if (photo != null) {
        photoUrl = await uploadPhoto(officer.id!, photo);
      }

      DocumentReference docRef = _officersCollection.doc(officer.id);

      print('services = ${officer.rank}');

      await docRef.update({
        'officerID': officer.officerID,
        'name': officer.name,
        'email': officer.email,
        'photo': photoUrl ?? officer.photo,
        'phone': officer.phone,
        'dob': officer.dob,
        'nationality': officer.nationality,
        'state': officer.state,
        'lga': officer.lga,
        'gender': officer.gender,
        'rank': officer.rank,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating officer: $e');
      }
    }
  }

  Future<void> deleteOfficer(String id) async {
    try {
      await _officersCollection.doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting officer: $e');
      }
    }
  }

  Future<String?> uploadPhoto(String? id, File photo) async {
  try {
    Reference storageReference = _storage.ref().child('officers/$id/photo');
    
    // Check if the file already exists
    try {
      String existingFileUrl = await storageReference.getDownloadURL();
      // File already exists, decide what to do (e.g., return the existing URL or overwrite)
      if (kDebugMode) {
        print('File already exists at: $existingFileUrl');
      }
    } catch (e) {
      // If the error is not about the file not existing, rethrow it
      if (e is! FirebaseException || e.code != 'object-not-found ==  $e') {
        rethrow;
      }
    }

    // Upload the file
    UploadTask uploadTask = storageReference.putData(photo as Uint8List);
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
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    }
    if (kDebugMode) {
      print('No file selected');
    }
    return null;
  }
  
}
