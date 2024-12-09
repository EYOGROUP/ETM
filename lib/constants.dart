import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

enum InfosApp {
  privacyPolicy,
  termOfUse,
}

class Constants {
  static String imagePath = 'assets/images/';
  static Color green = Colors.green;
  static Color red = Colors.red;

  static void showInSnackBar(
      {required String value, required BuildContext context}) {
    var snackBar = SnackBar(
      content: Text(value),
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      closeIconColor: Theme.of(context).colorScheme.outlineVariant,
      duration: const Duration(seconds: 10),
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

  static Text leadingAndTitleTextInRow(
      {required String leadingTextKey,
      required String textValue,
      double textSize = 16.0}) {
    return Text.rich(
        style: TextStyle(fontSize: textSize),
        TextSpan(children: [
          TextSpan(text: '$leadingTextKey '),
          TextSpan(
              text: textValue, style: TextStyle(fontWeight: FontWeight.bold)),
        ]));
  }
}

class TextFieldWithValidator extends StatelessWidget {
  TextFieldWithValidator({
    super.key,
    required this.controller,
    required this.getLabels,
    required this.validator,
    required this.textType,
    this.obscureText = false,
    this.suffixIcon,
    this.onChange,
  });

  final TextEditingController controller;
  final String getLabels;
  final String? Function(String?)? validator;
  final TextInputType textType;
  bool obscureText = false;
  Widget? suffixIcon;
  final String? Function(String?)? onChange;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      keyboardType: textType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9.0),
              borderSide: BorderSide(
                  width: 1, color: Theme.of(context).colorScheme.primary)),
          filled: true,
          fillColor:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.78),
          hintText: getLabels,
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.1)),
      validator: validator,
      onChanged: onChange,
    );
  }
}

class ElevatedButtonCreated extends StatelessWidget {
  const ElevatedButtonCreated({
    super.key,
    required this.onTap,
    required this.textWidget,
  });

  final Widget textWidget;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10)),
            fixedSize: WidgetStatePropertyAll(Size(
              MediaQuery.of(context).size.width * 0.88,
              MediaQuery.of(context).size.height * 0.055,
            )),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0))),
            backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.primaryContainer)),
        onPressed: onTap,
        child: textWidget);
  }
}

class TextFieldFlexibel extends StatelessWidget {
  TextFieldFlexibel({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hintText;
  int? maxLines;
  int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.text,
      maxLength: maxLength,
      maxLines: maxLines,
      controller: controller,
      decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Theme.of(context).colorScheme.primaryContainer,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(9.0))),
    );
  }
}

class SettingsCardButton extends StatelessWidget {
  final Function() onTap;
  final IconData iconData;
  final String title;
  const SettingsCardButton({
    super.key,
    required this.onTap,
    required this.iconData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: ListTile(
          leading: Icon(iconData),
          title: Text(
            title,
            style: TextStyle(fontSize: 18.0),
          ),
          trailing: Icon(Platform.isIOS
              ? Icons.arrow_forward_ios_rounded
              : Icons.arrow_forward_outlined),
        ),
      ),
    );
  }
}

class CardLeadingAndTrailing extends StatelessWidget {
  final Function() onTap;
  final String leading;
  final String trailing;
  const CardLeadingAndTrailing(
      {super.key,
      required this.onTap,
      required this.leading,
      required this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: ListTile(
          leading: Text(
            leading,
            style: TextStyle(fontSize: 18.0),
          ),
          trailing: Text(
            trailing,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}
