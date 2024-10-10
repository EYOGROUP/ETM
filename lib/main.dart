import 'package:flutter/material.dart';
import 'package:time_management/Navigation%20Pages/welcome.dart';
import 'package:time_management/theme_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: ThemeApp.darkMode,
      theme: ThemeApp.lightMode,
      home: const WelcomePage(),
    );
  }
}
