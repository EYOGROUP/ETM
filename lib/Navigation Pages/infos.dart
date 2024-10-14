import 'dart:io';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
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
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Platform.isIOS
              ? Icons.arrow_back_ios_new_outlined
              : Icons.arrow_back_outlined),
        ),
        title: const Text('Infos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Theme mode'),
            trailing: DayNightSwitcher(
              isDarkModeEnabled: tmProvider.isDarkGet,
              onStateChanged: (bool isDarkModeEnabled) async {
                await tmProvider.switchThemeApp(
                    context: context, valueTheme: isDarkModeEnabled);
                if (!mounted) return;
              },
            ),
          )
        ],
      ),
    );
  }
}
