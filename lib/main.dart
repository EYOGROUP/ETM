import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/welcome.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:time_management/theme_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          TimeManagementPovider()..getThemeApp(context: context),
      child: Consumer<TimeManagementPovider>(
        builder: (context, tMProvider, child) => MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          themeMode: tMProvider.isDarkGet ? ThemeMode.dark : ThemeMode.light,
          darkTheme: ThemeApp.darkMode,
          theme: ThemeApp.lightMode,
          home: const WelcomePage(),
        ),
      ),
    );
  }
}
