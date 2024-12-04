import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:time_management/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(getLabels.signUp),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
        child: Column(
          children: [
            Gap(MediaQuery.of(context).size.height * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getLabels.emailRegistration,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gap(MediaQuery.of(context).size.height * 0.006),
                Text(getLabels.completeYourProfile)
              ],
            ),
            Gap(MediaQuery.of(context).size.height * 0.03),
            Row(
              children: [
                Expanded(
                  child: TextFieldWithValidator(
                    textType: TextInputType.name,
                    controller: _firstNameController,
                    getLabels: getLabels.firstName,
                    validator: (firstName) {
                      return firstName == null || firstName.isEmpty
                          ? getLabels.cannotBeEmpty
                          : null;
                    },
                  ),
                ),
                Gap(MediaQuery.of(context).size.width * 0.03),
                Expanded(
                  child: TextFieldWithValidator(
                    textType: TextInputType.name,
                    controller: _lastNameController,
                    getLabels: getLabels.lastName,
                    validator: (lastName) {
                      return lastName == null || lastName.isEmpty
                          ? getLabels.cannotBeEmpty
                          : null;
                    },
                  ),
                ),
              ],
            ),
            Gap(MediaQuery.of(context).size.height * 0.03),
            TextFieldWithValidator(
              textType: TextInputType.emailAddress,
              controller: _emailController,
              getLabels: getLabels.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getLabels.cannotBeEmpty;
                }
                if (value.contains(
                    RegExp(r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]'))) {
                  return null;
                } else {
                  return getLabels.emailNotValid;
                }
              },
            ),
            Gap(MediaQuery.of(context).size.height * 0.03),
            TextFieldWithValidator(
              textType: TextInputType.visiblePassword,
              controller: _passwordController,
              getLabels: getLabels.password,
              validator: (passoword) {},
            ),
            Gap(MediaQuery.of(context).size.height * 0.03),
            TextFieldWithValidator(
              textType: TextInputType.visiblePassword,
              controller: _confirmPasswordController,
              getLabels: getLabels.confirmPassword,
              validator: (confirmPassowrd) {},
            ),
            Gap(MediaQuery.of(context).size.height * 0.15),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: ElevatedButtonCreated(
                  onTap: () {}, getLabels: getLabels.create),
            ),
            Gap(MediaQuery.of(context).size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  getLabels.alreadyHaveAnAccount,
                  style: TextStyle(fontSize: 16.0),
                ),
                Gap(5.0),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    getLabels.loginHere,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
