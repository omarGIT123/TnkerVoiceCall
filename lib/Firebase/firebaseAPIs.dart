import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testagora/Firebase/userModel.dart';

class FirebaseAPIs {
  late RegisterModel model;

  static List<RegisterModel> users = [];

  Future<void> getAllUsers() async {
    users.clear();
    if (users.isEmpty) {
      await FirebaseFirestore.instance.collection('users').get().then((value) {
        for (var element in value.docs) {
          return users.add(RegisterModel.fromJson(element.data()));
        }
      }).catchError((error) {
        print(error.toString());
      });
    }
  }

  Future<String?> userCreate({required iduser}) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(iduser)
        .collection('userinfo')
        .add({"Number": iduser});
    return ('success');
  }
}
