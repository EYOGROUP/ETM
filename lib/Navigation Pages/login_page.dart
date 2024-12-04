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
  final _formKey = GlobalKey<FormState>();
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
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          ],
                        ),
                      ),
                      Gap(MediaQuery.of(context).size.height * 0.04),
                      Center(
                        child: ElevatedButtonCreated(
                          getLabels: getLabels.continueLabel,
                          onTap: () {},
                        ),
                      ),
                      Gap(MediaQuery.of(context).size.height * 0.03),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ));
                          },
                          child: Text(
                            getLabels.newUserRegisterHere,
                            style: TextStyle(fontSize: 17.0),
                          ))
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
