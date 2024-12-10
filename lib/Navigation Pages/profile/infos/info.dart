import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/profile/infos/edit_name.dart';
import 'package:time_management/Navigation%20Pages/profile/infos/edit_phone.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/user.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:time_management/provider/user_provider.dart';

class InfoPage extends StatefulWidget {
  final Map<String, dynamic> userDataGet;
  const InfoPage({super.key, required this.userDataGet});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  TextEditingController? _userNameController;
  Map<String, dynamic> userData = {};
  bool isUserNameAlreadyExists = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Gender> genders = [Gender.male, Gender.female, Gender.nothing];
  String? selectedGender;
  @override
  void initState() {
    super.initState();
    userData = widget.userDataGet;
    _userNameController =
        TextEditingController(text: widget.userDataGet["userName"]);
  }

  Future<void> showEditUsername(
      {required AppLocalizations getLabels,
      required UserProvider userProvider}) {
    final int limitChar = 20;
    _userNameController =
        TextEditingController(text: widget.userDataGet["userName"]);
    int char = _userNameController!.text.length;

    return showModalBottomSheet(
      backgroundColor:
          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.78),
      useSafeArea: true,
      context: context,
      builder: (context) => Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0))),
          child: StatefulBuilder(
            builder: (context, setState) => Row(
              textBaseline: TextBaseline.ideographic,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.7,
                  height: 70.0,
                  child: TextFieldWithValidator(
                      suffixIcon: IconButton(
                          onPressed: () {
                            _userNameController?.clear();
                            setState(() {});
                          },
                          icon: Icon(Icons.clear)),
                      controller: _userNameController!,
                      maxLength: limitChar,
                      getLabels: getLabels.userName,
                      onChange: (userName) {
                        setState(() {
                          char = userName!.length;
                        });
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
                      validator: (userName) {
                        if (userName == null || userName.isEmpty) {
                          return getLabels.fieldMustNotBeEmpty;
                        } else {
                          if (userData["userName"] != userName) {
                            if (isUserNameAlreadyExists) {
                              return "username exists";
                            }
                          }
                        }
                        return null;
                      },
                      textType: TextInputType.name),
                ),
                Gap(MediaQuery.of(context).size.width * 0.01),
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Gap(MediaQuery.of(context).size.width * 0.01),
                    Text(
                      '$char/$limitChar',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Gap(MediaQuery.of(context).size.width * 0.01),
                    TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            editUserName(userProvider: userProvider);
                          }
                        },
                        child: Text(
                          getLabels.send,
                          style: TextStyle(fontSize: 16.0),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> editUserName({required UserProvider userProvider}) async {
    Map<String, dynamic> editUserName = {};
    if (userData["userName"] != _userNameController?.text) {
      editUserName['userName'] = _userNameController?.text;
      userData.update("userName", (value) => _userNameController?.text);
      setState(() {});
    }
    if (editUserName.isNotEmpty) {
      await userProvider.editUserName(
          userNameUpdateMap: editUserName,
          userId: userData['id'],
          context: context);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  String getGenderString(
      {required String gender, required AppLocalizations getLabels}) {
    String? genderShow;
    if (gender == Gender.male.toString()) {
      genderShow = getLabels.male;
    } else if (gender == Gender.female.toString()) {
      genderShow = getLabels.female;
    } else {
      genderShow = getLabels.noDisplay;
    }
    return genderShow;
  }

  Future<void> editUserGender({required UserProvider userProvider}) async {
    if (selectedGender != null) {
      Map<String, dynamic> selectedGenderMap = {"gender": selectedGender};
      userData.update("gender", (value) => selectedGender);
      setState(() {});
      await userProvider.saveUserGender(
          context: context,
          userId: userData["id"],
          selectedGenderMap: selectedGenderMap);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final eTMProvider =
        Provider.of<TimeManagementPovider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(getLabels.info),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getLabels.aboutYou,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Gap(5.0),
          CardLeadingAndTrailing(
            leading: getLabels.name,
            trailing: "${userData["firstName"]} ${userData["lastName"]}",
            onTap: () async {
              var userDataGet =
                  await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditNamePage(
                  userData: userData,
                ),
              ));
              if (!mounted) return;
              if (userDataGet != null) {
                if (userDataGet.isNotEmpty) {
                  setState(() {
                    userData = userDataGet;
                  });
                }
              }
            },
          ),
          CardLeadingAndTrailing(
            leading: getLabels.userName,
            trailing: userData["userName"],
            onTap: () {
              showEditUsername(
                  getLabels: getLabels, userProvider: userProvider);
            },
          ),
          CardLeadingAndTrailing(
            leading: getLabels.gender,
            trailing: userData["gender"] != null && userData["gender"] != ""
                ? getGenderString(
                    gender: userData["gender"], getLabels: getLabels)
                : getLabels.none,
            onTap: () {
              if (userProvider.isUserAlreadyHasGender(
                  context: context, userData: userData)) {
                return;
              }
              showModalBottomSheet(
                context: context,
                builder: (context) => SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    padding: EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                              direction: DropdownDirection.left),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0))),
                          hint: Text(getLabels.selectGender),
                          items: genders.map(
                            (gender) {
                              String? genderShow;
                              if (gender == Gender.male) {
                                genderShow = getLabels.male;
                              } else if (gender == Gender.female) {
                                genderShow = getLabels.female;
                              } else {
                                genderShow = getLabels.noDisplay;
                              }
                              return DropdownMenuItem(
                                  value: gender, child: Text(genderShow));
                            },
                          ).toList(),
                          onChanged: (gender) {
                            setState(() {
                              selectedGender = gender.toString();
                            });
                          },
                        ),
                        Gap(40.0),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButtonCreated(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    textWidget: Text(getLabels.cancel)),
                              ),
                              Gap(20.0),
                              Expanded(
                                child: ElevatedButtonCreated(
                                    onTap: () {
                                      editUserGender(
                                          userProvider: userProvider);
                                    },
                                    textWidget: Text(getLabels.confirm)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          CardLeadingAndTrailing(
            leading: getLabels.phone,
            trailing: '+${userData["phoneCode"]} ${userData["phoneNumber"]}',
            onTap: () async {
              final userDataGetFromEdit =
                  await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditPhonePage(
                  userDataGet: userData,
                ),
              ));
              if (userDataGetFromEdit != null) {
                if (userData.isNotEmpty) {
                  setState(() {
                    userData = userDataGetFromEdit;
                  });
                }
              }
            },
          ),
          CardLeadingAndTrailing(
            leading: getLabels.email,
            trailing: userData["email"],
            onTap: () {},
          ),
          CardLeadingAndTrailing(
            leading: getLabels.accountType,
            trailing: userData["role"] != null && userData["role"] != ''
                ? userData["roleData"]["name"]
                    [eTMProvider.getCurrentLocalSystemLanguage()]
                : getLabels.none,
            onTap: () {},
          ),
          CardLeadingAndTrailing(
            leading: getLabels.accountStatus,
            trailing: userData["isVerified"]
                ? getLabels.verified
                : getLabels.notVerified,
            onTap: () {},
          ),
          CardLeadingAndTrailing(
            leading: getLabels.premiumStatus,
            trailing:
                userData["isPremium"] ? getLabels.active : getLabels.inactive,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
