import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_management/constants.dart';

class RoleProvider extends ChangeNotifier {
  // Add new Role to ETM
  Future<void> addNewRole(
      {required BuildContext context,
      required Map<String, dynamic> roleMap}) async {
    try {
      if (roleMap.isNotEmpty) {
        String roleId = roleMap["id"];
        await FirebaseFirestore.instance
            .collection("roles")
            .doc(roleId)
            .set(roleMap);
      }
    } on FirebaseException catch (error) {
      if (context.mounted) {
        Constants.showInSnackBar(
            value: error.message.toString(), context: context);
      }
    }
  }
}
