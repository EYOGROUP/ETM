import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:time_management/constants.dart';

class PrivacyPolicyOrTermsOfUseETM extends StatelessWidget {
  final Enum infoApp;
  const PrivacyPolicyOrTermsOfUseETM({super.key, required this.infoApp});

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    List<Map<String, dynamic>> getPrivacyPolicyData = [
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
      {"title": getLabels.policyChanges, "value": getLabels.policyUpdateNotice},
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
        title: Text(infoApp == InfosApp.privacyPolicy
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
              itemCount: infoApp == InfosApp.privacyPolicy
                  ? getPrivacyPolicyData.length
                  : getTermsOfUseData.length,
              itemBuilder: (context, index) => Constants.cardForTitleAndText(
                  context: context,
                  title: infoApp == InfosApp.privacyPolicy
                      ? getPrivacyPolicyData[index]['title']
                      : getTermsOfUseData[index]['title'],
                  text: infoApp == InfosApp.privacyPolicy
                      ? getPrivacyPolicyData[index]['value']
                      : getTermsOfUseData[index]['value']),
            ),
          ),
        ],
      ),
    );
  }
}
