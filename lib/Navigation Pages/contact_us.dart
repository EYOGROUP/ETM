import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:time_management/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({
    super.key,
  });

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _globalKey = GlobalKey<FormState>();
  String _reasonChoosed = '';
  final List<String> _reasons = [
    'Technical Support',
    'Feature Request',
    'Time Tracking Errors',
    'App Performance',
    'Feedback',
    'Report a Bug',
    'Other'
  ];

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _globalKey,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Contact Us'),
          automaticallyImplyLeading: false,
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Platform.isIOS
                ? Icons.arrow_back_ios_new_outlined
                : Icons.arrow_back_outlined),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  if (_globalKey.currentState!.validate()) {
                    try {
                      if (_reasonChoosed == '') {
                        return Constants.showInSnackBar(
                            value:
                                'please choose a reason why you want to contact us',
                            context: context);
                      }

                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        query: encodeQueryParameters(<String, String>{
                          'subject':
                              '$_reasonChoosed / From (${_nameController.text})',
                          'body': _descriptionController.text,
                          'to': 'younesoffi.dahbi@gmail.com',
                        }),
                      );

                      if (!await launchUrl(emailLaunchUri,
                          mode: LaunchMode.externalApplication)) {
                        throw Exception('Could not launch $emailLaunchUri');
                      }
                    } catch (error) {
                      if (!context.mounted) return;
                      Constants.showInSnackBar(
                          value: error.toString(), context: context);
                    }
                  }
                },
                child: const Text(
                  'Send',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleWithTextfield(
                  controller: _nameController,
                  fieldName: 'Name:*',
                  fieldCaption: 'Enter your name',
                  isFlexibelField: false,
                ),
                Container(
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reason:*',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Gap(MediaQuery.of(context).size.height * 0.02),
                        DropdownButton(
                          iconEnabledColor:
                              Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.height * 0.02),
                          value: _reasonChoosed != '' ? _reasonChoosed : null,
                          items: _reasons
                              .map((reason) => DropdownMenuItem(
                                  value: reason, child: Text(reason)))
                              .toList(),
                          hint: const Text('Choose a reason'),
                          onChanged: (value) {
                            setState(() {
                              _reasonChoosed = value!;
                            });
                          },
                        ),
                      ],
                    )),
                TitleWithTextfield(
                  controller: _descriptionController,
                  fieldName: 'Description:*',
                  fieldCaption: 'Write...',
                  isFlexibelField: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TitleWithTextfield extends StatelessWidget {
  final String fieldName;
  final TextEditingController controller;
  final String fieldCaption;
  final bool isFlexibelField;

  const TitleWithTextfield({
    super.key,
    required this.controller,
    required this.fieldName,
    required this.fieldCaption,
    required this.isFlexibelField,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Gap(MediaQuery.of(context).size.height * 0.02),
          TextFormField(
            maxLines: isFlexibelField ? 5 : null,
            maxLength: isFlexibelField ? 300 : null,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              hintText: fieldCaption,
            ),
            controller: controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              return value!.isEmpty ? 'field must not be empty' : null;
            },
          ),
        ],
      ),
    );
  }
}
