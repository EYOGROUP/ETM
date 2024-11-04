import 'dart:io';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/contact_us.dart';
import 'package:time_management/Navigation%20Pages/privacy_policy_Terms_of_Use.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InfosPage extends StatefulWidget {
  const InfosPage({super.key});

  @override
  State<InfosPage> createState() => _InfosPageState();
}

class _InfosPageState extends State<InfosPage> {
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(getLabels.infos),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
            horizontal: MediaQuery.of(context).size.width * 0.02),
        child: Column(
          children: [
            ListTile(
              title: Text(getLabels.contactUs),
              trailing: InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
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
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyOrTermsOfUseETM(
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
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyOrTermsOfUseETM(
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
                      context: context, valueTheme: isDarkModeEnabled);
                  if (!mounted) return;
                },
              ),
            ),
            const Spacer(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: getLabels.appVersion),
                  const TextSpan(text: ' 1.00'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
