import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/architecture.dart';
import 'package:time_management/db/mydb.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimeManagementPovider with ChangeNotifier {
  bool _isDark = false;
  bool get isDarkGet => _isDark;
  Map<String, dynamic> _selectedCategory = {};
  Map<String, dynamic> get selectedCategory => _selectedCategory;

  set setCategory(Map<String, dynamic> categories) {
    resetSelectedCategory();
    _selectedCategory = categories;
    notifyListeners();
  }

  void resetSelectedCategory() {
    if (_selectedCategory.isNotEmpty) {
      _selectedCategory.clear();
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

  initCategoryInDB({required BuildContext context}) async {
    final getLabels = AppLocalizations.of(context)!;
    final List<String> categories = [
      getLabels.productivity,
      getLabels.healthFitness,
      getLabels.education,
      getLabels.business,
      getLabels.finance,
      getLabels.social,
      getLabels.entertainment,
    ];
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> initData;
    int? checkData;
    bool isCategoryTableExist = await isCategoryAlreadyInit(db: db);
    if (isCategoryTableExist) {
      initData = await db.readData(sql: 'select COUNT(*) from categories');
      checkData = Sqflite.firstIntValue(initData) ?? 0;
      if (checkData == 0) {
        for (String category in categories) {
          bool isAdsDisplayed = false;
          if (category == getLabels.productivity) {
            isAdsDisplayed = true;
          }
          ETMCategory etmCategory =
              ETMCategory(name: category, isAdsDisplayed: isAdsDisplayed);

          await db.insertData(
              tableName: "categories", data: etmCategory.toMap());
        }
      }
    }
  }

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

  initCategoryInDB({required BuildContext context}) async {
    final getLabels = AppLocalizations.of(context)!;
    final List<String> categories = [
      getLabels.productivity,
      getLabels.healthFitness,
      getLabels.education,
      getLabels.business,
      getLabels.finance,
      getLabels.social,
      getLabels.entertainment,
    ];
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> initData;
    int? checkData;
    bool isCategoryTableExist = await isCategoryAlreadyInit(db: db);
    if (isCategoryTableExist) {
      initData = await db.readData(sql: 'select COUNT(*) from categories');
      checkData = Sqflite.firstIntValue(initData) ?? 0;
    }
    if (checkData != null && checkData == 0) {
      for (String category in categories) {
        bool isAdsDisplayed = false;
        if (category == getLabels.productivity) {
          isAdsDisplayed = true;
        }
        ETMCategory etmCategory =
            ETMCategory(name: category, isAdsDisplayed: isAdsDisplayed);

        await db.insertData(tableName: "categories", data: etmCategory.toMap());
      }
    }
  }

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
                      "select * from break_sessions where workSessionId = ${getWorkDay['id']} and breakEndTime <> ''")
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
    List<Map<String, dynamic>> workSession = await db.readData(
            sql:
                'select * from work_sessions where isCompleted=1 and substr(startTime,1,10) ="$dateToday" ')
        as List<Map<String, dynamic>>;
    if (workSession.isNotEmpty) {
      isWorkFiniheshed = true;
    }
    return isWorkFiniheshed;
  }

  Future<Map<String, dynamic>> getWorkDataFromSpecificDate(
      {required DateTime date, required bool mounted}) async {
    Map<String, dynamic> workData = {};
    TrackingDB db = TrackingDB();
    String formatDate = DateFormat("yyyy-MM-dd").format(date);
    final getWorkData = await db.readData(
        sql:
            'select * from work_sessions where substr(startTime,1,10)="$formatDate"');
    if (mounted) {
      workData = Map<String, dynamic>.from(getWorkData.first);
      DateTime? startWorkTime =
          DateFormat("yyyy-MM-dd HH:mm:ss").tryParse(workData['startTime']);
      workData.update(
          'startTime', (value) => DateFormat('HH:mm').format(startWorkTime!));

      DateTime? endWorkTime =
          DateFormat("yyyy-MM-dd HH:mm:ss").tryParse(workData['endTime']);
      workData.update(
          'endTime', (value) => DateFormat('HH:mm').format(endWorkTime!));
      workData['workedTime'] =
          endWorkTime?.difference(startWorkTime!).inMinutes;
    }
    return workData;
  }

  Future<List<Map<String, dynamic>>> getBreaksFromSpecificDate(
      {required int workSessionsId, required bool mounted}) async {
    List<Map<String, dynamic>> breaks = [];
    TrackingDB db = TrackingDB();
    final getBreaksData = await db.readData(
        sql:
            "select * from break_sessions where workSessionId=$workSessionsId ");

    if (mounted) {
      if (getBreaksData.isNotEmpty) {
        breaks = getBreaksData
            .map((breakData) => Map<String, dynamic>.from(breakData))
            .toList();
        for (Map<String, dynamic> getBreakData in breaks) {
          DateTime? breakStartTimeAsDate = DateFormat("yyyy-MM-dd HH:mm:ss")
              .tryParse(getBreakData["breakStartTime"]);
          getBreakData["breakStartTime"] =
              DateFormat("HH:mm").format(breakStartTimeAsDate!);
          DateTime? breakEndTimeAsDate = DateFormat("yyyy-MM-dd HH:mm:ss")
              .tryParse(getBreakData["breakEndTime"]);

          getBreakData["breakEndTime"] =
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
            "select * from break_sessions where workSessionId = ${workDay['id']}");
    List<Map<String, dynamic>> formatBreaksToList = getBreaks
        .map((breakData) => Map<String, dynamic>.from(breakData))
        .toList();

    for (Map<String, dynamic> breakData in formatBreaksToList) {
      if (breakData['breakEndTime'] == '') {
        isAllBreaksClosed = false;
      }
    }
    return isAllBreaksClosed;
  }

  Future<void> deleteWork({required int id}) async {
    TrackingDB db = TrackingDB();
    await db.deleteData(sql: "delete from work_sessions where id =$id");
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
