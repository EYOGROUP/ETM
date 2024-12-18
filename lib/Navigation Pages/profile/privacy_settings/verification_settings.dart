import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/provider/user_provider.dart';

class VerificationSettingsUser extends StatefulWidget {
  final Map<String, dynamic> userDataGet;
  const VerificationSettingsUser({super.key, required this.userDataGet});

  @override
  State<VerificationSettingsUser> createState() =>
      _VerificationSettingsUserState();
}

class _VerificationSettingsUserState extends State<VerificationSettingsUser> {
  bool? isEmailVerified;
  late Timer _timer;
  bool _isDisposed = false;

  String point = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await getIfEmailVerified();
      },
    );
  }

  Future<void> getIfEmailVerified() async {
    getPoint();
    isEmailVerified = await Provider.of<UserProvider>(context, listen: false)
        .isEmailVerified(context: context);
    if (!mounted) return;

    setState(() {});
  }

  getPoint() async {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (mounted) {
        setState(() {
          point += '.';
          if (point.length > 3) {
            point = ''; // Reset the dots after 3
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(widget.userDataGet),
            icon: Icon(
                Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back)),
        centerTitle: true,
        title: Text(getLabels.verificationSettings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getLabels.verificationSettings,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            Gap(10.0),
            ListTile(
              leading: Text(
                "Email Verification",
                style: TextStyle(fontSize: 16.0),
              ),
              trailing: isEmailVerified != null
                  ? isEmailVerified!
                      ? Icon(
                          Icons.check_circle_outline,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        )
                  : Text(
                      point,
                      style: TextStyle(fontSize: 22.0),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
