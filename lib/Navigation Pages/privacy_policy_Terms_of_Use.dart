import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:time_management/constants.dart';
import 'package:time_management/provider/tm_provider.dart';

class PrivacyPolicyOrTermsOfUseETM extends StatefulWidget {
  final Enum infoApp;
  const PrivacyPolicyOrTermsOfUseETM({super.key, required this.infoApp});

  @override
  State<PrivacyPolicyOrTermsOfUseETM> createState() =>
      _PrivacyPolicyOrTermsOfUseETMState();
}

class _PrivacyPolicyOrTermsOfUseETMState
    extends State<PrivacyPolicyOrTermsOfUseETM> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final tm = Provider.of<TimeManagementPovider>(context, listen: false);
        tm.setOrientation(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    List<Map<String, dynamic>> getPrivacyPolicyData = [
      {
        "title": getLabels.privacyPolicy,
        "value": getLabels.welcomePrivacyPolicy,
      },
      {
        "title": getLabels.informationCollection,
        "value": getLabels.dataStorageInfo
      },
      {"title": getLabels.useOfInformation, "value": getLabels.dataPurpose},
      {
        "title": getLabels.emailContactFeature,
        "value": getLabels.contactUsExplanation
      },
      {
        "title": getLabels.darkLightModeSettings,
        "value": getLabels.darkModePreference
      },
      {"title": getLabels.dataSecurity, "value": getLabels.localDataSecurity},
      {
        "title": getLabels.dataAccessQuestion,
        "value": getLabels.dataAccess,
      },
      {
        "title": getLabels.dataDeletionTitle,
        "value": getLabels.dataDeletion,
      },
      {
        "title": getLabels.policyChangesTitle,
        "value": getLabels.policyChanges,
      },
      {
        "title": getLabels.contactUs,
        "value": getLabels.contact,
      },
    ];
    List<Map<String, dynamic>> getTermsOfUseData = [
      {
        "title": getLabels.acceptanceOfTerms,
        "value": getLabels.termsAcceptance
      },
      {"title": getLabels.usageRestrictions, "value": getLabels.usagePurpose},
      {
        "title": getLabels.limitationOfLiability,
        "value": getLabels.limitationOfLiabilityExplanation
      },
      {
        "title": getLabels.userResponsibility,
        "value": getLabels.userResponsibilityExplanation
      },
      {
        "title": getLabels.modificationsToTerms,
        "value": getLabels.termsModificationNotice
      },
      {
        "title": getLabels.contactInformation,
        "value": getLabels.contactUsExplanation
      },
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.infoApp == InfosApp.privacyPolicy
            ? getLabels.privacyPolicy
            : getLabels.termOfUse),
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Platform.isIOS
              ? Icons.arrow_back_ios_new_outlined
              : Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: widget.infoApp == InfosApp.privacyPolicy
                  ? getPrivacyPolicyData.length
                  : getTermsOfUseData.length,
              itemBuilder: (context, index) => Constants.cardForTitleAndText(
                  context: context,
                  title: widget.infoApp == InfosApp.privacyPolicy
                      ? getPrivacyPolicyData[index]['title']
                      : getTermsOfUseData[index]['title'],
                  text: widget.infoApp == InfosApp.privacyPolicy
                      ? getPrivacyPolicyData[index]['value']
                      : getTermsOfUseData[index]['value']),
            ),
          ),
        ],
      ),
    );
  }
}
