import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/user_provider.dart';

class PasswordForgetton extends StatefulWidget {
  final Map<String, dynamic> userDataGet;
  const PasswordForgetton({super.key, required this.userDataGet});

  @override
  State<PasswordForgetton> createState() => _PasswordForgettonState();
}

class _PasswordForgettonState extends State<PasswordForgetton> {
  Map<String, dynamic>? userData;
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isFieldEnabled = true;
  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    userData = widget.userDataGet;
    if (userData != null && userData!.isNotEmpty) {
      _emailController.text = userData?['email'];
      isFieldEnabled = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
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
                getLabels.resetPassword,
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
              Gap(20.0),
              Text(
                  style: TextStyle(height: 1.5, fontSize: 16.0),
                  getLabels.resetPasswordInstruction),
              Gap(40.0),
              Center(
                child: Column(
                  children: [
                    TextFieldWithValidator(
                      isFieldEnabled: isFieldEnabled,
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
                      textType: TextInputType.emailAddress,
                    ),
                    Gap(20.0),
                    ElevatedButtonCreated(
                        onTap: () {
                          userProvider.sendUserEmailPasswordReset(
                              context: context,
                              emailGet: _emailController.text,
                              formKey: _formKey,
                              userDataGet: userData!);
                        },
                        textWidget: Text(getLabels.sendInstructions))
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
