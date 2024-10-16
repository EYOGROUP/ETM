import 'dart:io';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/provider/tm_provider.dart';

class InfosPage extends StatefulWidget {
  const InfosPage({super.key});

  @override
  State<InfosPage> createState() => _InfosPageState();
}

class _InfosPageState extends State<InfosPage> {
  @override
  Widget build(BuildContext context) {
    final tmProvider =
        Provider.of<TimeManagementPovider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Infos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
            horizontal: MediaQuery.of(context).size.width * 0.02),
        child: Column(
          children: [
            ListTile(
              title: const Text('Contact Us'),
              trailing: Icon(Platform.isIOS
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_forward_outlined),
            ),
            ListTile(
              title: const Text('Give Feedback'),
              trailing: Icon(Platform.isIOS
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_forward_outlined),
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: Icon(Platform.isIOS
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_forward_outlined),
            ),
            ListTile(
              title: const Text('Tems of Use'),
              trailing: Icon(Platform.isIOS
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_forward_outlined),
            ),
            Gap(MediaQuery.of(context).size.height * 0.02),
            ListTile(
              title: const Text('Theme Mode'),
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
            const Text.rich(TextSpan(children: [
              TextSpan(text: 'App Version '),
              TextSpan(text: '1.00'),
            ]))
          ],
        ),
      ),
    );
  }
}
