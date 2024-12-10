import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/Navigation%20Pages/register_page.dart';
import 'package:time_management/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isObscurePassword = true;
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(getLabels.signIn),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getLabels.signInToContinue,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            Gap(MediaQuery.of(context).size.height * 0.01),
                            TextFieldWithValidator(
                              textType: TextInputType.emailAddress,
                              controller: _emailController,
                              getLabels: getLabels.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return getLabels.cannotBeEmpty;
                                }
                                if (value.contains(RegExp(
                                    r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]'))) {
                                  return null;
                                } else {
                                  return getLabels.emailNotValid;
                                }
                              },
                            ),
                            Gap(MediaQuery.of(context).size.height * 0.02),
                            TextFieldWithValidator(
                              obscureText: isObscurePassword,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() =>
                                    isObscurePassword = !isObscurePassword),
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
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Gap(MediaQuery.of(context).size.height * 0.04),
                      Center(
                        child: ElevatedButtonCreated(
                          textWidget:
                              Text(getLabels.continueLabel.toUpperCase()),
                          onTap: () {
                            FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text);
                          },
                        ),
                      ),
                      Gap(MediaQuery.of(context).size.height * 0.01),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ));
                        },
                        child: Text(
                          getLabels.forgotPassword.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      Gap(MediaQuery.of(context).size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getLabels.noAccount,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                              ));
                            },
                            child: Text(
                              getLabels.registerNow.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
