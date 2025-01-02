import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/provider/user_provider.dart';

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
  final TextEditingController _userNameController = TextEditingController();
  PhoneCountryData? _initialCountryData;
  final TextEditingController _phoneNumberController = TextEditingController();
  bool isObscurePassword = true;
  bool isSendingData = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isUserNameAlreadyExists = false;

  Future<void> userRegistration() async {
    setState(() {
      isSendingData = true;
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.saveUserInFirebase(
      context: context,
      mounted: mounted,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phoneCountryCode: _initialCountryData?.countryCode,
      phoneNumber: _phoneNumberController.text,
      userName: _userNameController.text,
      phoneCode: _initialCountryData?.phoneCode,
    );
    if (!mounted) return;
    setState(() {
      isSendingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(getLabels.signUp),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
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
                TextFieldWithValidator(
                  textType: TextInputType.emailAddress,
                  controller: _userNameController,
                  getLabels: getLabels.userName,
                  suffixIcon: Icon(isUserNameAlreadyExists
                      ? Icons.remove_circle_outline
                      : Icons.check_circle_outline_outlined),
                  onChange: (userName) {
                    userProvider
                        .isUserNameAlreadyUser(
                            userNameChoosed: userName!, context: context)
                        .then(
                      (isUserNameExists) {
                        if (isUserNameExists) {
                          setState(() {
                            isUserNameAlreadyExists = isUserNameExists;
                          });
                        } else {
                          setState(() {
                            isUserNameAlreadyExists = isUserNameExists;
                          });
                        }
                      },
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getLabels.cannotBeEmpty;
                    } else {
                      if (isUserNameAlreadyExists) {
                        return getLabels.usernameTaken;
                      }
                    }

                    // if (isUserNameAlreadyExist) {
                    //   return "already Exist";
                    // }

                    return null;
                  },
                ),

                Gap(MediaQuery.of(context).size.height * 0.03),
                Row(
                  children: [
                    SizedBox(
                      height: 80,
                      width: MediaQuery.of(context).size.width / 2.2,
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
                    SizedBox(
                      height: 80.0,
                      width: MediaQuery.of(context).size.width / 2.3,
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
                Gap(MediaQuery.of(context).size.height * 0.02),
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
                Gap(MediaQuery.of(context).size.height * 0.03),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CountryDropdown(
                        menuMaxHeight: MediaQuery.of(context).size.height * 0.6,
                        initialCountryData:
                            PhoneCodes.getPhoneCountryDataByCountryCode("DE"),

                        // printCountryName: true,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.78)),
                        onCountrySelected: (PhoneCountryData countryData) {
                          setState(() {
                            _initialCountryData = countryData;
                          });
                        },
                      ),
                    ),
                    Gap(10.0),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.78),
                          border: OutlineInputBorder(),
                          hintText: getLabels.phoneNumber,
                          errorStyle: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          PhoneInputFormatter(
                            allowEndlessPhone: false,
                            defaultCountryCode:
                                _initialCountryData?.countryCode ?? "US",
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                // PhoneInputFormatter(
                //   searchBoxDecoration: InputDecoration(
                //       hintText: getLabels.searchByCountryOrDialCode,
                //       border: OutlineInputBorder(
                //           borderRadius: BorderRadius.circular(9.0))),
                //   spaceBetweenSelectorAndTextField: 7.0,
                //   selectorConfig: SelectorConfig(
                //       useBottomSheetSafeArea: true,
                //       leadingPadding: 12,
                //       selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
                //   initialValue: number,
                //   autoValidateMode: AutovalidateMode.disabled,
                //   inputDecoration: InputDecoration(
                //       hintText: getLabels.phoneNumber,
                //       filled: true,
                //       fillColor: Theme.of(context).colorScheme.primaryContainer,
                //       border: OutlineInputBorder(
                //           borderRadius: BorderRadius.circular(9.0))),
                //   keyboardType: TextInputType.phone,
                //   onInputChanged: (PhoneNumber value) {},
                // ),
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
                    onTap: () =>
                        setState(() => isObscurePassword = !isObscurePassword),
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
                Gap(MediaQuery.of(context).size.height * 0.15),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: ElevatedButtonCreated(
                    textWidget: isSendingData
                        ? Center(child: CircularProgressIndicator())
                        : Text(getLabels.create),
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        userRegistration();
                      }
                    },
                  ),
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
        ),
      ),
    );
  }
}
