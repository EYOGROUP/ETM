import 'dart:io';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/contact_us.dart';
import 'package:time_management/Navigation%20Pages/login_page.dart';
import 'package:time_management/Navigation%20Pages/privacy_policy_terms_of_use.dart';
import 'package:time_management/Navigation%20Pages/profile/infos/info.dart';
import 'package:time_management/Navigation%20Pages/register_page.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/role.dart';

import 'package:time_management/db/mydb.dart';
import 'package:time_management/provider/role_provider.dart';

import 'package:time_management/provider/tm_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/provider/user_provider.dart';
import 'package:uuid/uuid.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String assetNameGoogle = 'assets/social/google-logo.svg';
  final String assetNameEmail = 'assets/social/email.png';
  final String assetNamePerson = 'assets/social/person_icon.png';
  bool? isUserLogedInOrExists;
  Map<String, dynamic>? userData;
  bool isInternetConnectedCheck = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        final tm = Provider.of<TimeManagementPovider>(context, listen: false);
        isInternetConntected(eTManagement: tm);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        tm.setOrientation(context);
        await isUserLogin(userProvider: userProvider);
        getUserData(userProvider: userProvider);
      },
    );
  }

  isUserLogin({required UserProvider userProvider}) async {
    isUserLogedInOrExists = await userProvider.isUserLogin(context: context);
    setState(() {});
  }

  Future<void> getUserData({required UserProvider userProvider}) async {
    userData = await userProvider.getUserData(
        context: context,
        mounted: mounted,
        isUserExists: isUserLogedInOrExists!);
    setState(() {});
  }

  isInternetConntected({required TimeManagementPovider eTManagement}) async {
    isInternetConnectedCheck =
        await eTManagement.isConnectedToInternet(context: context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    final tmProvider =
        Provider.of<TimeManagementPovider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(getLabels.infos),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.02,
                        horizontal: MediaQuery.of(context).size.width * 0.02),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isUserLogedInOrExists != null &&
                            !isUserLogedInOrExists!) ...{
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              getLabels.signInToContinue,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                          ),
                          LoginRegisterContainer(
                            assetName: assetNameGoogle,
                            containerText: getLabels.signInWithGoogle,
                            isSVG: true,
                            onTap: () {
                              userProvider.signInWithGoogle(context: context);
                            },
                          ),
                          LoginRegisterContainer(
                            assetName: assetNameEmail,
                            containerText: getLabels.signInWithEmail,
                            isSVG: false,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ));
                            },
                          ),
                          LoginRegisterContainer(
                            assetName: assetNamePerson,
                            containerText: getLabels.newUserRegisterHere,
                            isSVG: false,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                              ));
                            },
                          ),
                        } else ...{
                          !isInternetConnectedCheck
                              ? Center(
                                  child: Text(
                                    getLabels.noInternetConnection,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : userData != null
                                  ? Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          textBaseline: TextBaseline.alphabetic,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  textBaseline:
                                                      TextBaseline.ideographic,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${getLabels.welcome}, ${userData?["userName"]}!',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18.0),
                                                    ),
                                                    Gap(5.0),
                                                    userData?["isVerified"]
                                                        ? Tooltip(
                                                            message: getLabels
                                                                .verified,
                                                            child: Icon(
                                                              size: 20,
                                                              Icons.verified,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          )
                                                        : Tooltip(
                                                            message: getLabels
                                                                .notVerified,
                                                            child: Icon(
                                                              size: 20,
                                                              Icons.verified,
                                                              color: Colors
                                                                  .blueGrey,
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                                Gap(10.0),
                                                Constants
                                                    .leadingAndTitleTextInRow(
                                                        textSize: 14.0,
                                                        leadingTextKey:
                                                            getLabels
                                                                .accountCreated,
                                                        textValue: DateFormat(
                                                                getLabels
                                                                    .dateFormat)
                                                            .format(userData?[
                                                                    "createdAt"]
                                                                .toDate())),
                                              ],
                                            ),
                                            Expanded(
                                              child: Constants
                                                  .leadingAndTitleTextInRow(
                                                      textSize: 13.0,
                                                      leadingTextKey: getLabels
                                                          .premiumStatus,
                                                      textValue:
                                                          userData?["isPremium"]
                                                              ? getLabels.active
                                                              : getLabels
                                                                  .inactive),
                                            ),
                                          ],
                                        ),
                                        Gap(20.0),
                                        SettingsCardButton(
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) => InfoPage(
                                                userDataGet: userData ?? {},
                                              ),
                                            ));
                                          },
                                          iconData: Icons.person_outline,
                                          title: getLabels.info,
                                        ),
                                        SettingsCardButton(
                                          onTap: () async {
                                            FirebaseAuth.instance.signOut();
                                            print(userData);
                                            // Role role =
                                            //     Role(id: const Uuid().v4(), name: {
                                            //   'en': 'Normal User',
                                            //   'fr': 'Utilisateur Normal',
                                            //   'de': 'Normaler Benutzer'
                                            // }, permissions: [
                                            //   "log_time", // Ability to log working hours or time entries.
                                            //   "view_self_reports", // View their own reports (work logs, time entries).
                                            //   "update_profile", // Ability to update their personal profile details.
                                            //   "request_leave" // Ability to request leave/absences (if applicable).
                                            // ]);
                                            // Provider.of<RoleProvider>(context,
                                            //         listen: false)
                                            //     .addNewRole(
                                            //         context: context,
                                            //         roleMap: role.roleToMap());
                                          },
                                          iconData: Icons.lock_person_outlined,
                                          title: getLabels.profileSettings,
                                        ),
                                        SettingsCardButton(
                                          onTap: () {},
                                          iconData:
                                              Icons.manage_accounts_outlined,
                                          title: getLabels.account,
                                        ),
                                      ],
                                    )
                                  : Expanded(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                        },
                        Gap(MediaQuery.of(context).size.height * 0.02),
                        ListTile(
                          title: Text(getLabels.contactUs),
                          trailing: InkWell(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ContactUs(),
                            )),
                            child: Icon(Platform.isIOS
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_forward_outlined),
                          ),
                        ),
                        ListTile(
                          title: Text(getLabels.privacyPolicy),
                          trailing: GestureDetector(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const PrivacyPolicyOrTermsOfUseETM(
                                      infoApp: InfosApp.privacyPolicy),
                            )),
                            child: Icon(Platform.isIOS
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_forward_outlined),
                          ),
                        ),
                        ListTile(
                          title: Text(getLabels.termOfUse),
                          trailing: GestureDetector(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const PrivacyPolicyOrTermsOfUseETM(
                                      infoApp: InfosApp.termOfUse),
                            )),
                            child: Icon(Platform.isIOS
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_forward_outlined),
                          ),
                        ),
                        Gap(MediaQuery.of(context).size.height * 0.02),
                        ListTile(
                          title: Text(getLabels.themeMode),
                          trailing: DayNightSwitcher(
                            isDarkModeEnabled: tmProvider.isDarkGet,
                            onStateChanged: (bool isDarkModeEnabled) async {
                              await tmProvider.switchThemeApp(
                                  context: context,
                                  valueTheme: isDarkModeEnabled);
                              if (!mounted) return;
                            },
                          ),
                        ),
                        Spacer(),
                        InkWell(
                            onTap: () {
                              final delete = TrackingDB();
                              delete.deleteDB();
                            },
                            child: Text("hey")),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: getLabels.appVersion),
                                const TextSpan(text: ' 1.0.4'),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}

class LoginRegisterContainer extends StatelessWidget {
  const LoginRegisterContainer({
    super.key,
    required this.assetName,
    required this.containerText,
    required this.onTap,
    required this.isSVG,
  });
  final String containerText;
  final String assetName;
  final Function() onTap;
  final bool isSVG;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        padding: EdgeInsets.only(left: 25.0, bottom: 8.0, top: 8.0),
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.primaryContainer,
                width: 2.0),
            borderRadius: BorderRadius.circular(12.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            isSVG
                ? SvgPicture.asset(
                    assetName,
                    fit: BoxFit.cover,
                    height: 40.0,
                    width: 40.0,
                  )
                : Image.asset(
                    assetName,
                    fit: BoxFit.cover,
                    height: 40.0,
                    width: 40.0,
                  ),
            Gap(MediaQuery.of(context).size.width * 0.06),
            Text(
              containerText,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
