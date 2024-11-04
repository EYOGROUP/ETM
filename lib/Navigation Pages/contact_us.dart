import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  List<String>? _reasons;

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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final getLablels = AppLocalizations.of(context)!;
        _reasons = [
          getLablels.technicalSupport,
          getLablels.featureRequest,
          getLablels.timeTrackingErrors,
          getLablels.appPerformance,
          getLablels.feedback,
          getLablels.reportABug,
          getLablels.other
        ];
        setState(() {});

        final tm = Provider.of<TimeManagementPovider>(context, listen: false);
        tm.setOrientation(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    return Form(
      key: _globalKey,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(getLabels.contactUs),
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
                            value: getLabels.pleaseChooseAReason,
                            context: context);
                      }

                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        query: encodeQueryParameters(<String, String>{
                          'subject':
                              '$_reasonChoosed / ${getLabels.from} (${_nameController.text})',
                          'body': _descriptionController.text,
                          'to': 'younesoffi.dahbi@gmail.com',
                        }),
                      );

                      if (!await launchUrl(emailLaunchUri,
                          mode: LaunchMode.externalApplication)) {
                        throw Exception(
                            '${getLabels.couldNotLaunch} $emailLaunchUri');
                      }
                    } catch (error) {
                      if (!context.mounted) return;
                      Constants.showInSnackBar(
                          value: error.toString(), context: context);
                    }
                  }
                },
                child: Text(
                  getLabels.send,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
                  fieldName: '${getLabels.name}:*',
                  fieldCaption: getLabels.enterYourFullName,
                  isFlexibelField: false,
                ),
                Container(
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${getLabels.reason}:*',
                          style: const TextStyle(
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
                              ?.map((reason) => DropdownMenuItem(
                                  value: reason, child: Text(reason)))
                              .toList(),
                          hint: Text(getLabels.chooseAReason),
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
                  fieldName: '${getLabels.description}:*',
                  fieldCaption: '${getLabels.write}...',
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
    final getLabels = AppLocalizations.of(context)!;
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
                hintStyle: const TextStyle(fontSize: 14.0)),
            controller: controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              return value!.isEmpty ? getLabels.fieldMustNotBeEmpty : null;
            },
          ),
        ],
      ),
    );
  }
}
