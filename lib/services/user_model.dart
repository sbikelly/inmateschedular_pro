import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  late String? id;
  final String? firstName;
  final String? otherNames;
  final String? gender;
  final String? dob;
  final String? email;
  final String? phone;
  final String? address;
  final String? role;
  late final String? photo;

  UserModel({this.id, this.firstName, this.otherNames, this.gender, this.dob, this.role, this.email, this.phone, this.address, this.photo});

  static UserModel fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    try {
      final data = snapshot.data()!;
      return UserModel(
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        address: data['address'] as String?,
        firstName: data['firstName'] as String?,
        otherNames: data['otherNames'] as String?,
        gender: data['gender'] as String?,
        dob: data['dob'] as String?,
        role: data['role'] as String?,
        photo: data['photo'] as String?,
        id: data['id'] as String?,
      );
    } catch (e) {
      debugPrint('Error parsing user data from snapshot: $e');
      return UserModel();
    }
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      otherNames: data['otherNames'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      dob: data['dob'] ?? '',
      role: data['role'] ?? '',
      photo: data['photo'] ?? '',
      gender: data['gender'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'otherNames': otherNames,
      'email': email,
      'phone': phone,
      'address': address,
      'dob': dob,
      'role': role,
      'photo': photo,
      'gender': gender,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "phone": phone,
      "address": address,
      "firstName": firstName,
      "otherNames": otherNames,
      "gender": gender,
      "dob": dob,
      "role": role,
      "photo": photo,
    };
  }

  data() {}
}

class InmateModel {
  final String? id;
  final String? inmateID;
  final String? firstName;
  final String? otherNames;
  final String? gender;
  final String? dob;
  final String? email;
  final String? phone;
  final String? country;
  final String? state;
  final String? lga;
  final String? photo;
  final String? cellNo;
  
  InmateModel({
    this.email,
    this.phone,
    this.id,
    this.inmateID,
    this.firstName,
    this.otherNames,
    this.gender,
    this.dob,
    this.country,
    this.state,
    this.lga,
    this.photo,
    this.cellNo
  });

  static InmateModel fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    try {
      final data = snapshot.data()!;
      return InmateModel(
        id: data['id'] as String?,
        inmateID: data['inmateID'] as String?,
        firstName: data['firstName'] as String?,
        otherNames: data['otherNames']as String?,
        gender: data['gender']as String?,
        dob: data['dob']as String?,
        country: data['country']as String?,
        state: data['state']as String?,
        photo: data['photo']as String?,
        lga: data['lga']as String?,
        cellNo: data['cellNo']as String?,
      );
    } catch (e) {
      print('Error parsing inmate data from snapshot in InmateModel === $e');
      // Return a default user or handle error as needed
      return InmateModel();
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'otherNames': otherNames,
      'gender': gender,
      'dob': dob,
      'email': email,
      'phone': phone,
      'country': country,
      'state': state,
      'lga': lga,
      'photo': photo,
      'cellNo': cellNo,
      'id': id,
      'inmateID': inmateID,
    };
  }
}

class OfficerModel {
  String? id;
  String? officerID;
  String? name;
  String? email;
  String? photo;
  String? phone;
  String? dob;
  String? nationality;
  String? state;
  String? lga;
  String? gender;
  String? rank;

  OfficerModel({
    this.id,
    this.officerID,
    this.name,
    this.email,
    this.phone,
    this.photo,
    this.dob,
    this.nationality,
    this.state,
    this.lga,
    this.gender,
    this.rank,
  });

  static OfficerModel fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    try {
      return OfficerModel(
        id: data['id'] as String?,
        officerID: data['officerID'] as String?,
        name: data['name'] as String?,
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        photo: data['photo'] as String?,
        dob: data['dob'] as String?,
        nationality: data['nationality'] as String?,
        state: data['state'] as String?,
        lga: data['lga'] as String?,
        gender: data['gender'] as String?,
        rank: data['affiliations'] as String?,
      );
    } on Exception catch (e) {
      print('Error parsing officer data from snapshot in OfficerModel === $e');
      // Return a default user or handle error as needed
      return OfficerModel();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'officerID': officerID,
      'name': name,
      'email': email,
      'photo': photo,
      'phone': phone,
      'dob': dob ,
      'nationality': nationality,
      'state': state,
      'lga': lga,
      'gender': gender,
      'rank': rank,
    };
  }
}

