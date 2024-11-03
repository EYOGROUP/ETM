import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

enum InfosApp {
  privacyPolicy,
  termOfUse,
}

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

  static Widget cardForTitleAndText(
      {required BuildContext context,
      required String title,
      required String text}) {
    // Extract MediaQuery data at the beginning of the build method
    final mediaQuery = MediaQuery.of(context);

    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isPortrait
                    ? MediaQuery.of(context).size.width * 0.045
                    : MediaQuery.of(context).size.width * 0.015),
          ),
          Gap(MediaQuery.of(context).size.height * 0.01),
          Text(text),
        ],
      ),
    );
  }
}
