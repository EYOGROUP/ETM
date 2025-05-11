import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/contact_us.dart';
import 'package:time_management/Navigation%20Pages/home.dart';
import 'package:time_management/Navigation%20Pages/login_page.dart';
import 'package:time_management/Navigation%20Pages/pagination.dart';
import 'package:time_management/Navigation%20Pages/privacy_policy_terms_of_use.dart';
import 'package:time_management/Navigation%20Pages/profile/account/account_user.dart';
import 'package:time_management/Navigation%20Pages/profile/account/change_password.dart';
import 'package:time_management/Navigation%20Pages/profile/account/password_forgetton.dart';
import 'package:time_management/Navigation%20Pages/register_page.dart';
import 'package:time_management/Navigation%20Pages/welcome.dart';
import 'package:time_management/app/config/routes/app_pages.dart';
import 'package:time_management/app/features/dashboard/views/screens/dashboard_screen.dart';
import 'package:time_management/firebase_options.dart';
import 'package:time_management/provider/category_provider.dart';
import 'package:time_management/provider/support_provider.dart';
import 'package:time_management/provider/role_provider.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:time_management/provider/user_provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                TimeManagementPovider()..getThemeApp(context: context)),
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => RoleProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SupportProvider(),
        ),
      ],
      child: Consumer<TimeManagementPovider>(
        builder: (context, tMProvider, child) => GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
            Locale('fr'),
          ],
          title: 'Eyo Time Management',
          debugShowCheckedModeBanner: false,
          themeMode: tMProvider.isDarkGet ? ThemeMode.dark : ThemeMode.light,
          darkTheme: ThemeApp.darkMode,
          theme: ThemeApp.lightMode,

          initialRoute: Routes.welcome,
          getPages: [
            GetPage(name: Routes.welcome, page: () => const WelcomePage()),
            GetPage(name: Routes.home, page: () => const StartTimePage()),
            GetPage(
                name: Routes.dashboard, page: () => const DashboardScreen()),
            GetPage(name: Routes.pageController, page: () => PagesController()),
            GetPage(name: Routes.login, page: () => const LoginPage()),
            GetPage(name: Routes.register, page: () => const RegisterPage()),
            GetPage(
                name: Routes.forgotPassword,
                page: () => const PasswordForgetton(userDataGet: {})),
            GetPage(name: Routes.userAccount, page: () => const UserAccount()),
            GetPage(
                name: Routes.changePasswordUser,
                page: () => const ChangePasswordUser()),
            GetPage(name: Routes.contactUs, page: () => const ContactUs()),
            GetPage(
                name: Routes.privacyPolicy,
                page: () => const PrivacyPolicyOrTermsOfUseETM()),
            GetPage(
                name: Routes.termsAndConditions,
                page: () => const PrivacyPolicyOrTermsOfUseETM()),
          ],

          // home: const MyHomePage(),
          home: const WelcomePage(),
        ),
      ),
    );
  }
}
