import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/user_provider.dart';

class NotificationSettingsUser extends StatefulWidget {
  final Map<String, dynamic> userDataGet;
  const NotificationSettingsUser({super.key, required this.userDataGet});

  @override
  State<NotificationSettingsUser> createState() =>
      _NotificationSettingsUserState();
}

class _NotificationSettingsUserState extends State<NotificationSettingsUser> {
  Map<String, dynamic>? userData;
  bool? isPushNotificationsActive;
  bool? isEmailNotificationsActive;
  bool? isInAppNotificationsActive;
  bool isUpdatingData = false;
  @override
  void initState() {
    super.initState();
    setUserData();
  }

  void setUserData() {
    userData = widget.userDataGet;
    isPushNotificationsActive = userData?["isPushNotificationsActive"];
    isEmailNotificationsActive = userData?["isEmailNotificationsActive"];
    isInAppNotificationsActive = userData?["isInAppNotificationsActive"];
  }

  Future<void> updateUserData() async {
    Map<String, dynamic> updateNotificationsPreferences = {};
    if (userData?["isPushNotificationsActive"] != isPushNotificationsActive) {
      updateNotificationsPreferences["isPushNotificationsActive"] =
          isPushNotificationsActive;
    }
    if (userData?["isEmailNotificationsActive"] != isEmailNotificationsActive) {
      updateNotificationsPreferences["isEmailNotificationsActive"] =
          isEmailNotificationsActive;
    }
    if (userData?["isInAppNotificationsActive"] != isInAppNotificationsActive) {
      updateNotificationsPreferences["isInAppNotificationsActive"] =
          isInAppNotificationsActive;
    }
    if (updateNotificationsPreferences.isNotEmpty) {
      setState(() {
        isUpdatingData = true;
      });
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateNotificationsUser(
          context: context,
          updatedData: updateNotificationsPreferences,
          userId: userData?["id"]);
      if (mounted) {
        updateNotificationsPreferences.forEach(
          (keyGet, valueSet) {
            userData?.update(
              keyGet,
              (value) => valueSet,
            );
          },
        );
        setState(() {
          isUpdatingData = false;
        });
      }
    }
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
        title: Text(getLabels.notificationPreferences),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getLabels.notificationPreferences,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            Gap(10.0),
            LeadingWithSwitch(
              leadingText: getLabels.pushNotifications,
              switchValue: isPushNotificationsActive!,
              onChange: (value) {
                setState(() {
                  isPushNotificationsActive = value;
                });
              },
            ),
            Gap(5.0),
            LeadingWithSwitch(
              leadingText: getLabels.emailNotifications,
              switchValue: isEmailNotificationsActive!,
              onChange: (value) {
                setState(() {
                  isEmailNotificationsActive = value;
                });
              },
            ),
            Gap(5.0),
            LeadingWithSwitch(
              leadingText: getLabels.inAppNotifications,
              switchValue: isInAppNotificationsActive!,
              onChange: (value) {
                setState(() {
                  isInAppNotificationsActive = value;
                });
              },
            ),
            Spacer(),
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 20.0),
                height: 50,
                width: 200,
                child: ElevatedButtonCreated(
                  textWidget: isUpdatingData
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text(getLabels.confirm),
                  onTap: () {
                    updateUserData();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LeadingWithSwitch extends StatelessWidget {
  const LeadingWithSwitch(
      {super.key,
      required this.leadingText,
      required this.switchValue,
      required this.onChange});

  final bool switchValue;
  final Function(bool value)? onChange;
  final String leadingText;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        leadingText,
        style: TextStyle(fontSize: 16.0),
      ),
      trailing: Switch(
        value: switchValue,
        onChanged: onChange,
      ),
    );
  }
}
