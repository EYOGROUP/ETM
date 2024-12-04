import 'dart:io';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/contact_us.dart';
import 'package:time_management/Navigation%20Pages/login_page.dart';
import 'package:time_management/Navigation%20Pages/privacy_policy_terms_of_use.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/db/mydb.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/provider/user_provider.dart';

class InfosPage extends StatefulWidget {
  const InfosPage({super.key});

  @override
  State<InfosPage> createState() => _InfosPageState();
}

class _InfosPageState extends State<InfosPage> {
  final String assetNameGoogle = 'assets/social/google-logo.svg';
  final String assetNameEmail = 'assets/social/email.png';
  final String assetNamePerson = 'assets/social/person_icon.png';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final tm = Provider.of<TimeManagementPovider>(context, listen: false);
        tm.setOrientation(context);
      },
    );
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
                          onTap: () {},
                        ),
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
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
