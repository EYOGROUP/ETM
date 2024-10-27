import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeManagementPovider with ChangeNotifier {
  bool _isDark = false;
  bool get isDarkGet => _isDark;

  getThemeApp({required BuildContext context}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;
    final bool? getValue = prefs.getBool('isDark');
    if (getValue != null) {
      bool isDark = getValue;
      if (isDark) {
        _isDark = true;
      } else {
        _isDark = false;
      }
    }
    notifyListeners();
  }

  Future<void> switchThemeApp(
      {required BuildContext context, required bool valueTheme}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;

    _isDark = valueTheme;
    await prefs.setBool('isDark', valueTheme);

    notifyListeners();
  }
}
