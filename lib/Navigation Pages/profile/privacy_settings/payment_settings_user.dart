import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/user_provider.dart';

class PaymentSettingsUser extends StatefulWidget {
  final Map<String, dynamic> userDataGet;
  const PaymentSettingsUser({super.key, required this.userDataGet});

  @override
  State<PaymentSettingsUser> createState() => _PaymentSettingsUserState();
}

class _PaymentSettingsUserState extends State<PaymentSettingsUser> {
  Map<String, dynamic> userData = {};
  final TextEditingController _paypalEmailController = TextEditingController();
  final TextEditingController _billingEmailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    userData = widget.userDataGet;
  }

  bool isPaypalEmailRegistred() {
    bool isEmailSaved = false;
    if (userData.containsKey("payPalEmailAddress")) {
      if (userData["payPalEmailAddress"] != null &&
          userData["payPalEmailAddress"] != "") {
        isEmailSaved = true;
      }
    }
    return isEmailSaved;
  }

  Future<void> sendPayPalEmailToFirebase(
      {required UserProvider userProvider}) async {
    if (!isPaypalEmailRegistred()) {
      if (_paypalEmailController.text == "") return;
      Map<String, dynamic> paypalData = {
        "payPalEmailAddress": _paypalEmailController.text
      };
      await userProvider.savePayPalInFirebase(
          context: context, userData: userData, payPalEmailAddress: paypalData);

      if (!mounted) return;

      if (userData.containsKey("payPalEmailAddress")) {
        userData.update(
          "payPalEmailAddress",
          (value) => _paypalEmailController.text,
        );
      } else {
        userData.addAll(paypalData);
      }
    }
  }

  Future<void> deleteUserPayPalEmail({
    required AppLocalizations labels,
    required UserProvider userProvider,
  }) async {
    if (!isPaypalEmailRegistred()) return;
    Constants.showDialogConfirmation(
      context: context,
      title: labels.confirmDeletion,
      message: labels.confirmPayPalEmailDeletion,
      onConfirm: () async {
        Map<String, dynamic> payPalEmailDelete = {"payPalEmailAddress": ""};
        await userProvider.deleteUserPayPalEmail(
            context: context,
            userData: userData,
            payPalEmailDelete: payPalEmailDelete);
        if (!mounted) return;
        userData.update(
          'payPalEmailAddress',
          (value) => "",
        );
        Navigator.of(context).pop();
        setState(() {});
      },
    );
  }

  Future<void> changeBillingEmailAddress({
    required AppLocalizations labels,
  }) async {
    Map<String, dynamic> updateBillingEmailAddress = {};
    if (_billingEmailController.text != userData["billingEmailAddress"]) {
      updateBillingEmailAddress["billingEmailAddress"] =
          _billingEmailController.text;
    }

    if (updateBillingEmailAddress.isNotEmpty) {
      Navigator.of(context).pop();
      await Constants.showDialogConfirmation(
        context: context,
        title: labels.updateBillingEmail,
        message: labels.confirmUpdateBillingEmail,
        onConfirm: () async {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userData["id"])
                .update(updateBillingEmailAddress);
            if (!mounted) return;
            userData.update(
              "billingEmailAddress",
              (value) => _billingEmailController.text,
            );
            Navigator.of(context).pop();
            _billingEmailController.clear();
          } on FirebaseException catch (error) {
            Constants.showInSnackBar(
                value: error.message.toString(), context: context);
          }
        },
      );
    }
  }

  Future<Widget?> showAddEmail(
      {required TextEditingController textEditingController,
      required String editorLabel,
      required AppLocalizations labels,
      required String title,
      required String subTitle,
      required Function() onConfirm}) {
    return showDialog(
      context: context,
      builder: (context) => Form(
        key: _formKey,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    Gap(10.0),
                    Text(
                      subTitle,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Gap(20.0),
                    TextFieldWithValidator(
                      controller: textEditingController,
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      getLabels: editorLabel,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return labels.cannotBeEmpty;
                        }
                        if (value.contains(RegExp(
                            r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]'))) {
                          return null;
                        } else {
                          return labels.emailNotValid;
                        }
                      },
                      textType: TextInputType.emailAddress,
                    ),
                    Gap(20.0),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              labels.cancel,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            )),
                        Gap(20.0),
                        TextButton(
                            onPressed: onConfirm, child: Text(labels.confirm)),
                      ],
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

  @override
  void dispose() {
    super.dispose();
    _paypalEmailController.dispose();
    _billingEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(getLabels.paymentSettings),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.0)),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //TODO Premium things
                      Constants.leadingAndTitleTextInRow(
                          textColor: Theme.of(context).colorScheme.surface,
                          leadingTextKey: "ETM Premium:",
                          textValue: userData["isPremium"]
                              ? getLabels.active
                              : getLabels.inactive),
                      Gap(5.0),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: ElevatedButtonCreated(
                              onTap: () {},
                              textWidget: Text(
                                getLabels.getEtmPremium,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gap(20.0),
              if (isPaypalEmailRegistred()) ...{
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.95,
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getLabels.storedPaymentMethod,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: 18.0),
                        ),
                        Gap(5.0),
                        Constants.leadingAndTitleTextInRow(
                            textColor: Theme.of(context).colorScheme.surface,
                            leadingTextKey: "PayPal:",
                            textValue: userData['payPalEmailAddress']),
                        Gap(5.0),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: ElevatedButtonCreated(
                                onTap: () {
                                  deleteUserPayPalEmail(
                                      labels: getLabels,
                                      userProvider: userProvider);
                                },
                                textWidget: Text(
                                  getLabels.delete,
                                )),
                          ),
                        ),
                        Gap(10.0),
                        Text(
                          getLabels.unlinkingNote,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              } else ...{
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Constants.leadingAndTitleTextInRow(
                            textColor: Theme.of(context).colorScheme.surface,
                            leadingTextKey: "Paypal:",
                            textValue: getLabels.inactive),
                        Gap(5.0),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: ElevatedButtonCreated(
                                onTap: () async {
                                  await showAddEmail(
                                      title: "PayPal E-Mail",
                                      subTitle:
                                          getLabels.pleaseEnterPayPalEmail,
                                      textEditingController:
                                          _paypalEmailController,
                                      editorLabel: getLabels.emailAddress,
                                      labels: getLabels,
                                      onConfirm: () async {
                                        if (_formKey.currentState!.validate()) {
                                          await sendPayPalEmailToFirebase(
                                                  userProvider: userProvider)
                                              .whenComplete(
                                            () {
                                              if (!context.mounted) return;
                                              Navigator.of(context).pop();
                                              _paypalEmailController.clear();
                                            },
                                          );
                                          setState(() {});
                                        }
                                      });
                                },
                                textWidget: Text(
                                  getLabels.add,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              },
              Gap(20.0),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.95,
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.0)),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Constants.leadingAndTitleTextInRow(
                          textColor: Theme.of(context).colorScheme.surface,
                          leadingTextKey: getLabels.billingEmail,
                          textValue: userData["billingEmailAddress"]),
                      Gap(5.0),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: ElevatedButtonCreated(
                              onTap: () async {
                                _billingEmailController.text =
                                    userData["billingEmailAddress"];
                                await showAddEmail(
                                    title: getLabels.billingEmail,
                                    subTitle: getLabels.pleaseEnterBillingEmail,
                                    textEditingController:
                                        _billingEmailController,
                                    editorLabel: getLabels.emailAddress,
                                    labels: getLabels,
                                    onConfirm: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await changeBillingEmailAddress(
                                            labels: getLabels);
                                        setState(() {});
                                      }
                                    });
                              },
                              textWidget: Text(
                                getLabels.changeEmailAddress,
                              )),
                        ),
                      ),
                      Gap(10.0),
                      Text(
                        getLabels.billingReceiptNote,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
