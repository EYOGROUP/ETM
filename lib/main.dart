import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/welcome.dart';
import 'package:time_management/firebase_options.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:time_management/theme_app.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterNativeSplash.remove();
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('de'),
            Locale('en'),
            Locale('fr'),
          ],
          title: 'Eyo Time Management',
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
