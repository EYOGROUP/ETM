import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:time_management/provider/user_provider.dart';

class VerificationEmailUser extends StatefulWidget {
  const VerificationEmailUser({super.key});

  @override
  State<VerificationEmailUser> createState() => _VerificationEmailUserState();
}

class _VerificationEmailUserState extends State<VerificationEmailUser> {
  bool isEmailForVerificationSended = false;
  bool isSendingVerification = false;

  Future<void> sendEmailVerification() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool isEmailVerifiedCheck =
        await userProvider.isEmailVerified(context: context);
    if (!mounted) return;

    if (isEmailVerifiedCheck) return;
    setState(() {
      isSendingVerification = true;
    });
    await userProvider.sendUserVerificationEmail(context: context);
    if (!mounted) return;
    setState(() {
      isEmailForVerificationSended = true;
      isSendingVerification = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(getLabels.verifyYourEmail),
        bottom: isSendingVerification
            ? PreferredSize(
                preferredSize: Size(200.0, 10.0),
                child: LinearProgressIndicator())
            : null,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle),
              child: Icon(
                Icons.email,
                size: 77,
              ),
            ),
          ),
          Gap(30.0),
          Text(
            getLabels.verifyYourEmail,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          Gap(10.0),
          if (!isEmailForVerificationSended) ...{
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Text(
                textAlign: TextAlign.center,
                getLabels.sendEmailAction,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Gap(20.0),
            TextButton(
                onPressed: () {
                  sendEmailVerification();
                },
                child: Text(
                  getLabels.sendEmail.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
                )),
          } else ...{
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Text(
                textAlign: TextAlign.center,
                getLabels.afterEmailSent,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Gap(20.0),
            Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 44.0,
                ),
                Gap(20.0),
                TextButton(
                    onPressed: () {
                      sendEmailVerification();
                    },
                    child: Text(
                      getLabels.resendEmail.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22.0),
                    )),
              ],
            ),
          }
        ],
      ),
    );
  }
}
