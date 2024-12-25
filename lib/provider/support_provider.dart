import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/support.dart';
import 'package:time_management/provider/user_provider.dart';
import 'package:uuid/uuid.dart';

class SupportProvider extends ChangeNotifier {
  // create Contact Suppot
  Future<void> createContactSupport(
      {required BuildContext context,
      required Map<String, dynamic> reason,
      required String description,
      required String senderId,
      required String senderName}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool isUserLogin = await userProvider.isUserLogin(context: context);
    if (!isUserLogin) return;
    try {
      var contactId = "CC-${const Uuid().v4()}";
      ContactSupport support = ContactSupport(
          id: contactId,
          createdAt: DateTime.now(),
          reason: reason,
          description: description,
          senderId: senderId,
          status: Status.submitted.toString(),
          senderName: senderName);
      await FirebaseFirestore.instance
          .collection('contacts')
          .doc(contactId)
          .set(support.convertToMap());
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } on FirebaseException catch (error) {
      if (context.mounted) {
        Constants.showInSnackBar(
            value: error.message.toString(), context: context);
      }
    }
  }
}
