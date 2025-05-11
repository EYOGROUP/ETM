part of 'app_pages.dart';

/// used to switch pages
class Routes {
  // Dashboard Routes
  static const dashboard = _Paths.dashboard;

  // App Routes
  static const welcome = _Paths.welcome;
  static const pageController = _Paths.pageController;
  static const home = _Paths.home;
  static const login = _Paths.login;
  static const register = _Paths.register;
  static const forgotPassword = _Paths.forgotPassword;
  static const userAccount = _Paths.userAccount;
  static const changePasswordUser = _Paths.changePasswordUser;
  static const contactUs = _Paths.contactUs;
  static const aboutUs = _Paths.aboutUs;
  static const privacyPolicy = _Paths.privacyPolicy;
  static const termsAndConditions = _Paths.termsAndConditions;
  static const settings = _Paths.settings;
  static const notifications = _Paths.notifications;
  static const help = _Paths.help;
  static const feedback = _Paths.feedback;

  // Example :
  // static const index = '/';
  // static const splash = '/splash';
  // static const product = '/product';
}

/// contains a list of route names.
// made separately to make it easier to manage route naming
class _Paths {
  static const dashboard = '/dashboard';
  // Add your routes here
  static const welcome = '/welcome';
  static const pageController = '/pageController';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgotPassword';
  static const userAccount = '/userAccount';
  static const changePasswordUser = '/changePasswordUser';
  static const contactUs = '/contactUs';
  static const aboutUs = '/aboutUs';
  static const privacyPolicy = '/privacyPolicy';
  static const termsAndConditions = '/termsAndConditions';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const help = '/help';
  static const feedback = '/feedback';

  // Example :
  // static const index = '/';
  // static const splash = '/splash';
  // static const product = '/product';
}
