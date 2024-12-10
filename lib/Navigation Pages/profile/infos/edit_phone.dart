import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/provider/user_provider.dart';

class EditPhonePage extends StatefulWidget {
  final Map<String, dynamic> userDataGet;
  const EditPhonePage({super.key, required this.userDataGet});

  @override
  State<EditPhonePage> createState() => _EditPhonePageState();
}

class _EditPhonePageState extends State<EditPhonePage> {
  TextEditingController? _phoneNumberController;
  PhoneCountryData? _initialCountryData;
  Map<String, dynamic>? userData;
  @override
  void initState() {
    super.initState();
    userData = widget.userDataGet;
    _phoneNumberController =
        TextEditingController(text: userData?["phoneNumber"]);
    _initialCountryData = PhoneCodes.getPhoneCountryDataByCountryCode(
        userData?["phoneCountryCode"]);
  }

  bool isAnotherNumber() {
    if ((userData?["phoneNumber"] != _phoneNumberController?.text) ||
        userData?["phoneCountryCode"] != _initialCountryData?.countryCode) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> editPhoneNumber() async {
    if (isAnotherNumber()) {
      Map<String, dynamic> phoneUpdatedMap = {};
      if (userData?["phoneNumber"] != _phoneNumberController?.text) {
        phoneUpdatedMap["phoneNumber"] = _phoneNumberController?.text;
        userData?.update(
            "phoneNumber", (value) => _phoneNumberController?.text);
      }
      if (userData?["phoneCountryCode"] != _initialCountryData?.countryCode) {
        phoneUpdatedMap["phoneCountryCode"] = _initialCountryData?.countryCode;
        userData?.update(
            "phoneCountryCode", (value) => _initialCountryData?.countryCode);
        userData?.update(
            "phoneCode", (value) => _initialCountryData?.phoneCode);
      }
      setState(() {});
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.editUserPhoneNumber(
          context: context,
          userId: userData?["id"],
          phoneNumberMap: phoneUpdatedMap);
      if (!mounted) return;
      Navigator.of(context).pop(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(getLabels.phone),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => editPhoneNumber(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getLabels.send,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: isAnotherNumber()
                        ? null
                        : Theme.of(context).colorScheme.outline),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              getLabels.enterPhoneNumber,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Gap(20.0),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CountryDropdown(
                  menuMaxHeight: MediaQuery.of(context).size.height * 0.6,
                  initialCountryData: _initialCountryData ??
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
                  onChanged: (value) {
                    isAnotherNumber();
                    setState(() {});
                  },
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
        ],
      ),
    );
  }
}
