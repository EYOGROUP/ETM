import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/register_page.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/user_provider.dart';

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
  bool isUserEmailAlreadyInFirebase = false;
  bool? isWrongEmail;
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<void> checkUserEmail({required UserProvider userProvider}) async {
    if (_formKey.currentState!.validate()) {
      isUserEmailAlreadyInFirebase = await userProvider.isUserEmailInFirebase(
          context: context, emailGet: _emailController.text);
      if (!mounted) return;
      isWrongEmail = !isUserEmailAlreadyInFirebase;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
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
                      if (isWrongEmail != null && isWrongEmail!)
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20.0),
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.96,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .error
                                    .withOpacity(0.90),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .errorContainer)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getLabels.emailDoesNotExist,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onError),
                                ),
                                Text(
                                  getLabels.emailEntryCheck,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onError),
                                )
                              ],
                            ),
                          ),
                        ),
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getLabels.signInToContinue,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                  Gap(MediaQuery.of(context).size.height *
                                      0.01),
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
                                  if (isUserEmailAlreadyInFirebase) ...{
                                    Gap(MediaQuery.of(context).size.height *
                                        0.02),
                                    TextFieldWithValidator(
                                      obscureText: isObscurePassword,
                                      suffixIcon: GestureDetector(
                                        onTap: () => setState(() =>
                                            isObscurePassword =
                                                !isObscurePassword),
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
                                  },
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(MediaQuery.of(context).size.height * 0.02),
                      Center(
                        child: ElevatedButtonCreated(
                          textWidget: Text(!isUserEmailAlreadyInFirebase
                              ? getLabels.continueLabel.toUpperCase()
                              : getLabels.login.toUpperCase()),
                          onTap: () {
                            if (!isUserEmailAlreadyInFirebase) {
                              checkUserEmail(userProvider: userProvider);
                            } else {
                              userProvider.signInWithEmailAndPassword(
                                  context: context,
                                  emailGet: _emailController.text,
                                  passwordGet: _passwordController.text);
                            }
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
