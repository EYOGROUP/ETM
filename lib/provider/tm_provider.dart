import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:time_management/constants.dart';

import 'dart:io';

import 'package:time_management/db/mydb.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/provider/category_provider.dart';

class TimeManagementPovider with ChangeNotifier {
  bool _isDark = false;
  bool get isDarkGet => _isDark;

  bool _isInAddingTask = false;
  bool get isInAddingTaskGet => _isInAddingTask;

  bool _isInAddingReason = false;
  bool get isInAddingReasonGet => _isInAddingReason;

  bool _isInternetConnected = false;
  bool get isInternetConnectedGet => _isInternetConnected;

  set isInAddingTaskSet(bool isInAdding) {
    _isInAddingTask = isInAdding;
    notifyListeners();
  }

  set isInAddingReasonSet(bool isInAdding) {
    _isInAddingReason = isInAdding;
    notifyListeners();
  }

  Future<void> monitorInternet(BuildContext context) async {
    final subscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> connectivity) async {
        bool hasInternet = await hasActiveInternet();
        if (context.mounted) {
          final getLabels = AppLocalizations.of(context)!;
          final categoryProvider =
              Provider.of<CategoryProvider>(context, listen: false);
          if (connectivity.contains(ConnectivityResult.none) || !hasInternet) {
            _isInternetConnected = false;

            return Constants.showInSnackBar(
                value: getLabels.noInternetConnection, context: context);
          } else {
            _isInternetConnected = true;
            categoryProvider.switchToLokalCategories = false;

            return Constants.showInSnackBar(
                value: getLabels.internetConnectionActive, context: context);
          }
        }
      },
    );
    subscription.cancel();
    notifyListeners();
  }

// check Internet if it working
  Future<bool> hasActiveInternet() async {
    try {
      final result = await InternetAddress.lookup("google.com");
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<bool> isConnectedToInternet({required BuildContext context}) async {
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();

    bool hasInternet = await hasActiveInternet();

    if (connectivityResult.contains(ConnectivityResult.none) || !hasInternet) {
      _isInternetConnected = false;
      return false;
    } else {
      if (context.mounted) {
        final categoryProvider =
            Provider.of<CategoryProvider>(context, listen: false);
        categoryProvider.switchToLokalCategories = false;
      }

      _isInternetConnected = true;

      return true;
    }
  }

  Future<bool> isCategoryAlreadyInit({required TrackingDB db}) async {
    bool isAlreadyIn = true;
    try {
      List<Map<String, dynamic>> insertNewBreak = await db.readData(
          sql:
              "SELECT name FROM sqlite_master WHERE type='table' AND name='categories'");

      if (insertNewBreak.isEmpty) {
        isAlreadyIn = false;
      }
    } catch (e) {
      print(e.toString());
    }
    return isAlreadyIn;
  }

  String getCurrentLocalSystemLanguage() {
    String localeName = Platform.localeName;
    List<String> supportLuanguages = ["en", "de", "fr"];
    String currentLocalSystem = '';

    if (localeName.contains("_") || localeName.contains("-")) {
      // Split by the first occurring separator and return the language code
      currentLocalSystem = localeName.split(RegExp(r'[_-]')).first;
    } else {
      currentLocalSystem =
          localeName; // If no separator, return the locale name as is
    }
    if (supportLuanguages.contains(currentLocalSystem)) {
      currentLocalSystem = currentLocalSystem;
    } else {
      currentLocalSystem = "en";
    }

    return currentLocalSystem;
  }
  // initCategoryInDB({required BuildContext context}) async {
  //   final userProvider = Provider.of(context, listen: false);
  //   final getLabels = AppLocalizations.of(context)!;
  //   List categories = ETMCategory.categories;
  //   TrackingDB db = TrackingDB();
  //   List<Map<String, dynamic>> initData;
  //   int? checkData;
  //   bool isCategoryTableExist = await isCategoryAlreadyInit(db: db);
  //   if (isCategoryTableExist) {
  //     initData = await db.readData(sql: 'select COUNT(*) from categories');
  //     checkData = Sqflite.firstIntValue(initData) ?? 0;
  //     if (checkData == 0) {
  //       for (ETMCategory category in categories) {
  //         await db.insertData(
  //             tableName: "categories", data: category.toMap(isLokal: true));
  //       }
  //     }
  //   }
  // }

  Future<List<Map<String, dynamic>>> getCategories(
      {required BuildContext context, required bool mounted}) async {
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> getDataModifiedData = [];
    bool isCategoryAlreadyInitCheck = await isCategoryAlreadyInit(db: db);
    if (isCategoryAlreadyInitCheck) {
      final getData = await db.readData(sql: "select * from categories")
          as List<Map<String, dynamic>>;
      if (context.mounted) {
        final getLabels = AppLocalizations.of(context)!;
        getDataModifiedData = getData
            .map((category) => Map<String, dynamic>.from(category))
            .toList();
        for (Map<String, dynamic> category in getDataModifiedData) {
          switch (category["id"]) {
            case 1:
              category["name"] = getLabels.productivity;
              break;
            case 2:
              category["name"] = getLabels.healthFitness;
              break;
            case 3:
              category["name"] = getLabels.education;
              break;
            case 4:
              category["name"] = getLabels.business;
              break;
            case 5:
              category["name"] = getLabels.finance;
              break;
            case 6:
              category["name"] = getLabels.social;
              break;
            case 7:
              category["name"] = getLabels.entertainment;
              break;

            default:
              break;
          }
        }
      }
    }
    return getDataModifiedData;
  }

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

  bool areDatesSame(DateTime date1, DateTime date2) {
    if (date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getDataSameDateLikeToday(
      {required DateTime date}) async {
    List<Map<String, dynamic>> worksDay = [];
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> works = await db.readData(
        sql: 'select * from work_sessions') as List<Map<String, dynamic>>;

    for (Map<String, dynamic> work in works) {
      DateTime? startTimeToday =
          DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(work['startTime'])!;

// check if data date same like today
      bool isSameDate = areDatesSame(startTimeToday, date);
      if (isSameDate) {
        worksDay.add(work);
      }
    }
    return worksDay;
  }

  Future<int> getNumberOfBreaks(
      {required DateTime date,
      required bool mounted,
      required BuildContext context}) async {
    int numberOfBreaks = 0;
    TrackingDB db = TrackingDB();

    List<Map<String, dynamic>> getWorksDay =
        await getDataSameDateLikeToday(date: date);
    try {
      for (Map<String, dynamic> getWorkDay in getWorksDay) {
        if (getWorkDay['id'] != null) {
          List<Map<String, dynamic>> breakSessions = await db.readData(
                  sql:
                      "select * from break_sessions where workSessionId = '${getWorkDay['id']}' and endTime <> ''")
              as List<Map<String, dynamic>>;
          if (mounted) {
            numberOfBreaks += breakSessions.length;
          }
        }
      }
    } catch (error) {
      if (context.mounted) {
        Constants.showInSnackBar(value: error.toString(), context: context);
      }
    }
    return numberOfBreaks;
  }

  Future<Map<String, dynamic>> getHoursOrMinutesWorkedForToday(
      {required DateTime choosedDate}) async {
    Map<String, dynamic> data = {};

    List<Map<String, dynamic>> worksDay =
        await getDataSameDateLikeToday(date: choosedDate);
    double inMinutes = 0;

    for (Map<String, dynamic> workDay in worksDay) {
      if (workDay.isNotEmpty) {
        if (workDay['isCompleted'] == 0 && workDay['endTime'] == '') {
          return data;
        }

        DateTime? start =
            DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(workDay['startTime']);
        DateTime? endTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(workDay['endTime']);

        inMinutes += endTime!.difference(start!).inMinutes;
        data = {
          "hours": inMinutes,
          "isInHours": false,
        };
      }
    }
    return data;
  }

  Future<bool> isWorkFiniheshed({required DateTime date}) async {
    bool isWorkFiniheshed = false;
    TrackingDB db = TrackingDB();
    String dateToday = DateFormat('yyyy-MM-dd').format(date);
    List<Map<String, dynamic>> workSessions = await db.readData(
            sql:
                'select * from work_sessions where substr(startTime,1,10) ="$dateToday" ')
        as List<Map<String, dynamic>>;
    if (workSessions.isNotEmpty) {
      // isWorkFiniheshed = true;

      // same logic
      for (Map<String, dynamic> workSession in workSessions) {
        if (workSession["isCompleted"] == 1) {
          isWorkFiniheshed = true;
        } else {
          isWorkFiniheshed = false;
        }
      }
    }

    return isWorkFiniheshed;
  }

  Future<List<Map<String, dynamic>>> getWorkDataFromSpecificDate(
      {required DateTime date,
      required bool mounted,
      String? categoryId}) async {
    List<Map<String, dynamic>> worksDataGet = [];
    TrackingDB db = TrackingDB();
    String formatDate = DateFormat("yyyy-MM-dd").format(date);
    List<Map<String, dynamic>> getWorkData = [];
    if (categoryId != null && categoryId != '') {
      getWorkData = await db.readData(
          sql:
              'select * from work_sessions where substr(startTime,1,10)="$formatDate" and categoryId="$categoryId"');
    } else {
      getWorkData = await db.readData(
          sql:
              'select * from work_sessions where substr(startTime,1,10)="$formatDate"');
    }

    if (mounted) {
      worksDataGet.clear();

      if (getWorkData.isNotEmpty) {
        List<Map<String, dynamic>> getWorksData = List.from(getWorkData);
        List<Map<String, dynamic>> worksData = getWorksData
            .map((workData) => Map<String, dynamic>.from(workData))
            .toList();

        for (Map<String, dynamic> workData in worksData) {
          DateTime? startWorkTime =
              DateFormat("yyyy-MM-dd HH:mm:ss").tryParse(workData['startTime']);
          workData.update('startTime',
              (value) => DateFormat('HH:mm').format(startWorkTime!));

          DateTime? endWorkTime =
              DateFormat("yyyy-MM-dd HH:mm:ss").tryParse(workData['endTime']);
          workData.update(
              'endTime', (value) => DateFormat('HH:mm').format(endWorkTime!));
          workData['workedTime'] =
              endWorkTime?.difference(startWorkTime!).inMinutes;
          worksDataGet.add(workData);
        }
      }
    }

    return worksDataGet;
  }

  Future<List<Map<String, dynamic>>> getBreaksFromSpecificDateAndId(
      {required int workSessionsId, required bool mounted}) async {
    List<Map<String, dynamic>> breaks = [];
    TrackingDB db = TrackingDB();
    final getBreaksData = await db.readData(
        sql:
            "select * from break_sessions where workSessionId='$workSessionsId' ");

    if (mounted) {
      if (getBreaksData.isNotEmpty) {
        breaks = getBreaksData
            .map((breakData) => Map<String, dynamic>.from(breakData))
            .toList();
        for (Map<String, dynamic> getBreakData in breaks) {
          DateTime? breakStartTimeAsDate = DateFormat("yyyy-MM-dd HH:mm:ss")
              .tryParse(getBreakData["startTime"]);
          getBreakData["startTime"] =
              DateFormat("HH:mm").format(breakStartTimeAsDate!);
          DateTime? breakEndTimeAsDate = DateFormat("yyyy-MM-dd HH:mm:ss")
              .tryParse(getBreakData["endTime"]);

          getBreakData["endTime"] =
              DateFormat("HH:mm").format(breakEndTimeAsDate!);

          getBreakData['duration'] =
              breakEndTimeAsDate.difference(breakStartTimeAsDate).inMinutes;
        }
      }
    }
    return breaks;
  }

  Future<List<Map<String, dynamic>>> getBreaksFromSpecificDate(
      {required DateTime breakSessionTime,
      required bool mounted,
      String? workSessionId}) async {
    List<Map<String, dynamic>> breaks = [];
    TrackingDB db = TrackingDB();
    String formatDate = DateFormat("yyyy-MM-dd").format(breakSessionTime);
    List<Map<String, dynamic>>? getBreaksData;
    if (workSessionId != null) {
      getBreaksData = await db.readData(
          sql:
              'select * from break_sessions where workSessionId= "$workSessionId" ');
    } else {
      getBreaksData = await db.readData(
          sql:
              'select * from break_sessions where substr(endTime,1,10)="$formatDate" ');
    }

    if (mounted) {
      if (getBreaksData.isNotEmpty) {
        breaks = getBreaksData
            .map((breakData) => Map<String, dynamic>.from(breakData))
            .toList();
        for (Map<String, dynamic> getBreakData in breaks) {
          DateTime? breakStartTimeAsDate = DateFormat("yyyy-MM-dd HH:mm:ss")
              .tryParse(getBreakData["startTime"]);
          getBreakData["startTime"] =
              DateFormat("HH:mm").format(breakStartTimeAsDate!);
          DateTime? breakEndTimeAsDate = DateFormat("yyyy-MM-dd HH:mm:ss")
              .tryParse(getBreakData["endTime"]);

          getBreakData["endTime"] =
              DateFormat("HH:mm").format(breakEndTimeAsDate!);

          getBreakData['duration'] =
              breakEndTimeAsDate.difference(breakStartTimeAsDate).inMinutes;
        }
      }
    }
    return breaks;
  }

  Future<bool> isAllBreaksClosed(
      {required Map<String, dynamic> workDay}) async {
    bool isAllBreaksClosed = true;
    TrackingDB db = TrackingDB();
    final getBreaks = await db.readData(
        sql:
            "select * from break_sessions where workSessionId = '${workDay['id']}'");
    List<Map<String, dynamic>> formatBreaksToList = getBreaks
        .map((breakData) => Map<String, dynamic>.from(breakData))
        .toList();

    for (Map<String, dynamic> breakData in formatBreaksToList) {
      if (breakData['endTime'] == '') {
        isAllBreaksClosed = false;
      }
    }
    return isAllBreaksClosed;
  }

  Future<void> deleteWork({required String id}) async {
    TrackingDB db = TrackingDB();
    await db.deleteData(sql: "delete from work_sessions where id ='$id'");
  }

  bool isPortrait(BuildContext context) {
    bool isPortraitGet = false;
    final mediaQuery = MediaQuery.of(context);

    bool isPortraitCheck = mediaQuery.orientation == Orientation.portrait;
    if (isPortraitCheck) {
      isPortraitGet = true;
    }
    return isPortraitGet;
  }

  void setOrientation(BuildContext context) {
    // Check if the device is a tablet
    bool isTablet = !isPortrait(context);

    if (isTablet) {
      // Allow rotation on tablets
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ]);
    } else {
      // Lock orientation to portrait for phones
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }
}
