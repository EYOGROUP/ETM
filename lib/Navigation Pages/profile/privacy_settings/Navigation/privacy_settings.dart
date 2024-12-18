import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:time_management/Navigation%20Pages/profile/privacy_settings/notification_settings.dart';
import 'package:time_management/Navigation%20Pages/profile/privacy_settings/verification_settings.dart';
import 'package:time_management/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrivacySettingsUser extends StatefulWidget {
  final Map<String, dynamic> userDataGet;
  const PrivacySettingsUser({super.key, required this.userDataGet});

  @override
  State<PrivacySettingsUser> createState() => _PrivacySettingsUserState();
}

class _PrivacySettingsUserState extends State<PrivacySettingsUser> {
  Map<String, dynamic>? userData;
  @override
  void initState() {
    super.initState();
    userData = widget.userDataGet;
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(userData),
            icon: Icon(
                Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back)),
        title: Text(getLabels.profileSettings),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Gap(20.0),
          SettingsCardButton(
            iconData: Icons.notifications_none_outlined,
            title: getLabels.notificationPreferences,
            onTap: () async {
              Map<String, dynamic> userDataGet =
                  await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    NotificationSettingsUser(userDataGet: userData ?? {}),
              ));
              if (!mounted) return;
              if (userDataGet.isNotEmpty) {
                setState(() {
                  userData = userDataGet;
                });
              }
            },
          ),
          SettingsCardButton(
            iconData: Icons.verified_user_outlined,
            title: getLabels.verificationSettings,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    VerificationSettingsUser(userDataGet: userData ?? {}),
              ));
            },
          ),
          SettingsCardButton(
            iconData: Icons.payments_outlined,
            title: getLabels.paymentSettings,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
