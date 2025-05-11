import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/support_provider.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  Map<String, dynamic>? userData;
  Map<String, String>? selectedReason;
  String? selectedReasonAsString;

  bool isSendingData = false;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
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
    final args = Get.arguments;
    userData = args;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        // final getLabels = AppLocalizations.of(context)!;
        initNameIfUserLogIn();
        // _reasons = [
        //   getLabels.technicalSupport,
        //   getLabels.featureRequest,
        //   getLabels.timeTrackingErrors,
        //   getLabels.appPerformance,
        //   getLabels.feedback,
        //   getLabels.reportABug,
        //   getLabels.other
        // ];
        setState(() {});

        final tm = Provider.of<TimeManagementPovider>(context, listen: false);
        tm.setOrientation(context);
      },
    );
  }

  List<Map<String, String>> contactReason() {
    return [
      {
        "en": "Technical Support",
        "de": "Technischer Support",
        "fr": "Support Technique"
      },
      {
        "en": "Feature Request",
        "de": "Funktionsanfrage",
        "fr": "Demande de Fonctionnalité"
      },
      {
        "en": "Time Tracking Errors",
        "de": "Zeitverfolgungsfehler",
        "fr": "Erreurs de Suivi du Temps"
      },
      {
        "en": "App Performance",
        "de": "App-Leistung",
        "fr": "Performance de l'Application"
      },
      {"en": "Feedback", "de": "Feedback", "fr": "Retours"},
      {
        "en": "Report a Bug",
        "de": "Einen Fehler melden",
        "fr": "Signaler un Bug"
      },
      {"en": "Other", "de": "Andere", "fr": "Autre"},
    ];
  }

  Future<void> _sendEmail() async {
    if (_globalKey.currentState!.validate()) {
      if (selectedReason == null) {
        return Constants.showInSnackBar(
            value: AppLocalizations.of(context)!.pleaseChooseAReason,
            context: context);
      }
      if (userData != null && userData!.isNotEmpty) {
        setState(() {
          isSendingData = true;
        });
        final SupportProvider supportProvider =
            Provider.of<SupportProvider>(context, listen: false);
        await supportProvider.createContactSupport(
            context: context,
            reason: selectedReason!,
            description: _descriptionController.text,
            senderId: userData?["id"],
            senderName: _nameController.text);
        setState(() {
          isSendingData = false;
        });
      } else {
        try {
          final Uri emailLaunchUri = Uri(
            scheme: 'mailto',
            path: 'younesoffi.dahbi@gmail.com', // Your email here
            query: encodeQueryParameters(<String, String>{
              'subject':
                  '$selectedReasonAsString / ${AppLocalizations.of(context)!.from} (${_nameController.text})',
              'body': _descriptionController.text,
            }),
          );

          if (!await launchUrl(emailLaunchUri,
              mode: LaunchMode.externalApplication)) {
            if (!mounted) return;
            throw Exception(
                '${AppLocalizations.of(context)!.couldNotLaunch} $emailLaunchUri');
          }
        } catch (error) {
          if (mounted) {
            Constants.showInSnackBar(value: error.toString(), context: context);
          }
        }
      }
    }
  }

  void initNameIfUserLogIn() {
    if (userData != null && userData!.isNotEmpty) {
      _nameController.text =
          "${userData?['firstName']} ${userData?["lastName"]}";
    } else {
      _nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    final eTMProvider =
        Provider.of<TimeManagementPovider>(context, listen: false);

    return Form(
      key: _globalKey,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(getLabels.contactUs),
          automaticallyImplyLeading: false,
          bottom: isSendingData
              ? PreferredSize(
                  preferredSize: Size(200.0, 10.0),
                  child: LinearProgressIndicator())
              : null,
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Platform.isIOS
                ? Icons.arrow_back_ios_new_outlined
                : Icons.arrow_back_outlined),
          ),
          actions: [
            TextButton(
              onPressed: _sendEmail,
              child: Text(
                getLabels.send,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleWithTextfield(
                  isEnabled: _nameController.text.isNotEmpty ? false : true,
                  controller: _nameController,
                  fieldName: '${getLabels.name}:*',
                  fieldCaption: getLabels.enterYourFullName,
                  isFlexibelField: false,
                ),
                // Adding the reason selection part as before
                Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${getLabels.reason}:*',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(MediaQuery.of(context).size.height * 0.02),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0))),
                        menuMaxHeight:
                            MediaQuery.of(context).size.height * 0.35,
                        isExpanded: true,
                        iconEnabledColor: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height * 0.02),
                        value: selectedReasonAsString,
                        items: contactReason()
                            .map((reason) => DropdownMenuItem(
                                  onTap: () {
                                    setState(() {
                                      selectedReason = reason;
                                    });
                                  },
                                  value: reason[eTMProvider
                                      .getCurrentLocalSystemLanguage()],
                                  child: Text(reason[eTMProvider
                                      .getCurrentLocalSystemLanguage()]!),
                                ))
                            .toList(),
                        hint: Text(getLabels.chooseAReason),
                        onChanged: (value) {
                          setState(() {
                            selectedReasonAsString = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                TitleWithTextfield(
                  controller: _descriptionController,
                  fieldName: '${getLabels.description}:*',
                  fieldCaption: '${getLabels.write}...',
                  isFlexibelField: true,
                ),
                // Providing clear contact information (email or phone)
                Gap(MediaQuery.of(context).size.height * 0.01),
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
  final bool? isEnabled;

  const TitleWithTextfield({
    super.key,
    required this.controller,
    required this.fieldName,
    required this.fieldCaption,
    required this.isFlexibelField,
    this.isEnabled,
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
            enabled: isEnabled,
            maxLines: isFlexibelField ? 5 : 1,
            maxLength: isFlexibelField ? 300 : null,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
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
