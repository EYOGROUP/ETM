import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/user_provider.dart';

class CheckEmailAfteCodeSended extends StatefulWidget {
  final Map<String, dynamic> userDataGet;
  final String emailGet;
  const CheckEmailAfteCodeSended(
      {super.key, required this.userDataGet, required this.emailGet});

  @override
  State<CheckEmailAfteCodeSended> createState() =>
      _CheckEmailAfteCodeSendedState();
}

class _CheckEmailAfteCodeSendedState extends State<CheckEmailAfteCodeSended> {
  Map<String, dynamic>? userData;
  String? codePin;
  Timer? _timer;
  bool isCountDown = true;
  int countDownMin = 2;
  int countDownSec = 0;
  final OtpFieldController _otpFieldController = OtpFieldController();
  @override
  void initState() {
    super.initState();
    userData = widget.userDataGet;
    makeTimerCountDown();
  }

  makeTimerCountDown() {
    setState(() {
      isCountDown = true;
    });
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        if (countDownSec == 0) {
          setState(() {
            countDownMin -= 1;
            countDownSec = 59;
          });
        } else {
          setState(() {
            countDownSec--;
          });
        }
        if (countDownMin == 0 && countDownSec == 0) {
          _timer?.cancel();
          setState(() {
            isCountDown = false;
            countDownMin = 2;
            countDownSec = 0;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(33.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.98)),
                      child: Icon(
                        Icons.mark_email_unread_outlined,
                        size: 66.0,
                      ),
                    ),
                    Gap(40.0),
                    Text(
                      getLabels.checkYourMail,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Gap(20.0),
                    Text(
                      getLabels.passwordRecoveryInstructions,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Gap(20.0),
                    OTPTextField(
                      otpFieldStyle: OtpFieldStyle(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer),
                      length: 5,
                      width: MediaQuery.of(context).size.width * 0.7,
                      fieldWidth: 40,
                      style: TextStyle(fontSize: 17),
                      spaceBetween: 0.5,
                      textFieldAlignment: MainAxisAlignment.spaceAround,
                      keyboardType: TextInputType.number,
                      fieldStyle: FieldStyle.underline,
                      onChanged: (value) {},
                      controller: _otpFieldController,
                      onCompleted: (pin) {
                        setState(() {
                          codePin = pin;
                        });
                      },
                    ),
                    Gap(20.0),
                    ElevatedButtonCreated(
                        onTap: () {
                          if (codePin != null && codePin != '') {
                            userProvider.valideCodeConfirmation(
                                userData: userData!,
                                context: context,
                                codeGet: codePin!);
                          }
                        },
                        textWidget: Text(getLabels.confirm)),
                    Gap(10.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(getLabels.didNotReceiveCode),
                          Gap(10.0),
                          isCountDown
                              ? Text(
                                  '${countDownMin.toString().padLeft(2, "0")}:${countDownSec.toString().padLeft(2, "0")}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                )
                              : InkWell(
                                  onTap: () async {
                                    _otpFieldController.clear();
                                    setState(() {});
                                    await userProvider
                                        .sendUserEmailPasswordReset(
                                            isInit: false,
                                            context: context,
                                            emailGet: userData?['email'],
                                            userDataGet: userData!);
                                    if (!mounted) return;
                                    makeTimerCountDown();
                                  },
                                  child: Text(
                                    getLabels.resend,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                )
                        ],
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Text(
                        textAlign: TextAlign.center,
                        getLabels.emailNotReceived,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
