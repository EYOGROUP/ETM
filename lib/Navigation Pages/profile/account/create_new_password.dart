import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/user_provider.dart';

class CreateNewPasswordUser extends StatefulWidget {
  final Map<String, dynamic> userDataGet;
  const CreateNewPasswordUser({super.key, required this.userDataGet});

  @override
  State<CreateNewPasswordUser> createState() => _CreateNewPasswordUserState();
}

class _CreateNewPasswordUserState extends State<CreateNewPasswordUser> {
  Map<String, dynamic>? userData;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isObscurePassword = true;
  bool isSendingData = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    userData = widget.userDataGet;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations getLabels = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getLabels.createNewPassword,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Gap(10.0),
              Text(
                getLabels.passwordDifferentTip,
                style: TextStyle(fontSize: 18.0),
              ),
              Gap(MediaQuery.of(context).size.height * 0.03),
              Center(
                child: Column(
                  children: [
                    TextFieldWithValidator(
                      obscureText: isObscurePassword,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                            () => isObscurePassword = !isObscurePassword),
                        child: Icon(isObscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                      ),
                      textType: TextInputType.visiblePassword,
                      controller: _passwordController,
                      getLabels: getLabels.password,
                      validator: (passoword) {
                        if (passoword!.isEmpty) {
                          return getLabels.fieldMustNotBeEmpty;
                        } else {
                          if (passoword.length < 8) {
                            return getLabels.passwordTooShort;
                          }
                          if (!passoword.contains(RegExp(r'^(?=.*[\W_])'))) {
                            return getLabels.passwordMissingSpecialCharacter;
                          }
                        }
                        return null;
                      },
                    ),
                    Gap(MediaQuery.of(context).size.height * 0.03),
                    TextFieldWithValidator(
                      obscureText: isObscurePassword,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                            () => isObscurePassword = !isObscurePassword),
                        child: Icon(isObscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                      ),
                      textType: TextInputType.visiblePassword,
                      controller: _confirmPasswordController,
                      getLabels: getLabels.confirmPassword,
                      validator: (confirmPassword) {
                        if (confirmPassword!.isEmpty) {
                          return getLabels.fieldMustNotBeEmpty;
                        } else {
                          if (_passwordController.text != confirmPassword) {
                            return getLabels.passwordDoesntMatch;
                          }
                        }
                        return null;
                      },
                    ),
                    Gap(MediaQuery.of(context).size.height * 0.05),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: ElevatedButtonCreated(
                        textWidget: isSendingData
                            ? Center(child: CircularProgressIndicator())
                            : Text(getLabels.resetPassword),
                        onTap: () async {
                          // await FirebaseAuth.instance.sendPasswordResetEmail(
                          //     email: userData?['email']);
                          await userProvider.initDeep();
                          // if (_formKey.currentState!.validate()) {
                          //   setState(() {
                          //     isSendingData = true;
                          //   });
                          //   // await userProvider.resetUserPassword(
                          //   //     context: context,
                          //   //     newpassword: _confirmPasswordController.text);
                          //   if (!mounted) return;
                          //   setState(() {
                          //     isSendingData = false;
                          //   });
                          // }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
