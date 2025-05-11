import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/profile/account/password_forgetton.dart';
import 'package:time_management/app/config/routes/app_pages.dart';
import 'package:time_management/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/provider/user_provider.dart';

class ChangePasswordUser extends StatefulWidget {
  const ChangePasswordUser({
    super.key,
  });

  @override
  State<ChangePasswordUser> createState() => _ChangePasswordUserState();
}

class _ChangePasswordUserState extends State<ChangePasswordUser> {
  Map<String, dynamic>? userData;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isObscurePassword = false;
  bool isSendingData = false;
  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    // 1) Grab the raw arguments
    userData = arg as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations getLabels = AppLocalizations.of(context)!;
    UserProvider userPorivder =
        Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(getLabels.changePassword),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getLabels.resetPassword,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Gap(MediaQuery.of(context).size.height * 0.03),
                TextFieldWithValidator(
                  obscureText: isObscurePassword,
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => isObscurePassword = !isObscurePassword),
                    child: Icon(isObscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                  textType: TextInputType.visiblePassword,
                  controller: _currentPasswordController,
                  getLabels: getLabels.currentPassword,
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
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            PasswordForgetton(userDataGet: userData ?? {}),
                      ));
                    },
                    child: Text(getLabels.forgotPassword)),
                Gap(MediaQuery.of(context).size.height * 0.04),
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
                        getLabels: getLabels.newPassword,
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
                        getLabels: getLabels.confirmNewPassword,
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
                      Gap(MediaQuery.of(context).size.height * 0.03),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: ElevatedButtonCreated(
                          textWidget: isSendingData
                              ? Center(child: CircularProgressIndicator())
                              : Text(getLabels.updatePassword),
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              userPorivder.changePassword(
                                  context: context,
                                  newPassword: _passwordController.text,
                                  email: userData?['email'],
                                  currentPassword:
                                      _currentPasswordController.text,
                                  labels: getLabels);
                            }
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
      ),
    );
  }
}
