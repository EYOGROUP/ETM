import 'package:flutter/material.dart';

class Constants {
  static String imagePath = 'assets/images/';

  static void showInSnackBar(
      {required String value, required BuildContext context}) {
    var snackBar = SnackBar(
      content: Text(value),
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      closeIconColor: Theme.of(context).colorScheme.outlineVariant,
      duration: const Duration(seconds: 5),
      showCloseIcon: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.height * 0.003)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
