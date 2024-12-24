import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/profile/account/change_password.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/user_provider.dart';

class UserAccount extends StatefulWidget {
  final Map<String, dynamic> userDataGet;
  const UserAccount({super.key, required this.userDataGet});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  Map<String, dynamic>? userData;
  String? emailDotted;
  @override
  void initState() {
    super.initState();
    userData = widget.userDataGet;
    dottedEmailAddress();
  }

  void dottedEmailAddress() {
    List<String> makeEmailAsList = userData?['email'].split("@");
    String firstEmailList = makeEmailAsList[0]
        .replaceRange(1, null, "*" * (makeEmailAsList[0].length - 1));
    emailDotted = "$firstEmailList@${makeEmailAsList[1]}";
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations getLabels = AppLocalizations.of(context)!;
    UserProvider userPorivder =
        Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(getLabels.account),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(textAlign: TextAlign.center, getLabels.rememberPasswordTip),
            Gap(40.0),
            TextField(
              enabled: false,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  hintText: emailDotted,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0))),
            ),
            Gap(20.0),
            ElevatedButtonCreated(
                removeBackgroundColor: true,
                onTap: () {
                  userPorivder.logoutUser(context: context);
                },
                textWidget: Text(getLabels.logout)),
            Gap(20.0),
            ElevatedButtonCreated(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        ChangePasswordUser(userDataGet: userData ?? {}),
                  ));
                },
                textWidget: Text(getLabels.changePassword)),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextButton(
                  onPressed: () {}, child: Text(getLabels.deleteMyAccount)),
            )
          ],
        ),
      ),
    );
  }
}
