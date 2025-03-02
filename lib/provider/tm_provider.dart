import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/architecture.dart';
import 'dart:io';
import 'package:time_management/db/mydb.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/provider/category_provider.dart';
import 'package:uuid/uuid.dart';

class TimeManagementPovider with ChangeNotifier {
  bool _isDark = false;
  bool get isDarkGet => _isDark;

  bool _isInAddingTask = false;
  bool get isInAddingTaskGet => _isInAddingTask;

  bool _isInAddingReason = false;
  bool get isInAddingReasonGet => _isInAddingReason;

  bool _isInternetConnected = false;
  bool get isInternetConnectedGet => _isInternetConnected;

  bool _isTrackingSessionAsLokalAlreadyStarted = false;
  bool get isTrackingSessionAsLokalAlreadyStarted =>
      _isTrackingSessionAsLokalAlreadyStarted;

  bool? isLokalDataInCloudSync;

  double _progressSyncToCloud = 0;

  set isInAddingTaskSet(bool isInAdding) {
    _isInAddingTask = isInAdding;
    notifyListeners();
  }

  set isInAddingReasonSet(bool isInAdding) {
    _isInAddingReason = isInAdding;
    notifyListeners();
  }

// Check if Sessions started as lokal
  set isTrackingSessionAsLokalAlreadyStartedSet(
      bool isTrackingSessionAsLokalAlreadyStartedGet) {
    _isTrackingSessionAsLokalAlreadyStarted =
        isTrackingSessionAsLokalAlreadyStartedGet;
    notifyListeners();
  }

  Future<void> monitorInternet({required BuildContext context}) async {
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
    } catch (e) {}
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
      {required DateTime date,
      required BuildContext context,
      required bool isUserExist}) async {
    List<Map<String, dynamic>> trackingsDay = [];

    if (isUserExist) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      DateTime? dateFilter = DateFormat("yyyy-MM-dd").tryParse(date.toString());
      final getUsertrackingSessions = await FirebaseFirestore.instance
          .collection('trackingSessions')
          .where('userId', isEqualTo: userId)
          .get();
      if (context.mounted) {
        final maptrackingSessions = getUsertrackingSessions.docs
            .map((trackingSession) => trackingSession.data());
        for (Map<String, dynamic> gettrackingSession in maptrackingSessions) {
          if (gettrackingSession['isCompleted'] &&
              gettrackingSession["endTime"] != '') {
            if (DateFormat("yyyy-MM-dd")
                .tryParse(gettrackingSession["startTime"].toDate().toString())!
                .isAtSameMomentAs(dateFilter!)) {
              trackingsDay.add(gettrackingSession);
            }
          }
        }
      }
    } else {
      TrackingDB db = TrackingDB();
      List<Map<String, dynamic>> works = await db.readData(
          sql: 'select * from tracking_sessions') as List<Map<String, dynamic>>;
      for (Map<String, dynamic> work in works) {
        DateTime? startTimeToday =
            DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(work['startTime'])!;

// check if data date same like today
        bool isSameDate = areDatesSame(startTimeToday, date);
        if (isSameDate) {
          trackingsDay.add(work);
        }
      }
    }

    return trackingsDay;
  }

  Future<int> getNumberOfBreaks(
      {required DateTime date,
      required bool mounted,
      required BuildContext context,
      required bool isUserExist}) async {
    int numberOfBreaks = 0;

    List<Map<String, dynamic>> getTrackingsDay = await getDataSameDateLikeToday(
        date: date, context: context, isUserExist: isUserExist);

    try {
      for (Map<String, dynamic> getTrackingDay in getTrackingsDay) {
        if (isUserExist) {
          final getTrackingBreaks = await FirebaseFirestore.instance
              .collection('breakSessions')
              .where("trackingSessionId",
                  isEqualTo: getTrackingDay['trackingSession'])
              .where("isCompleted", isEqualTo: true)
              .get();
          if (context.mounted) {
            final getDayFilterBreaks = getTrackingBreaks.docs.where(
                (breakSession) => areDatesSame(
                    breakSession.data()['startTime'].toDate(), date));

            if (getDayFilterBreaks.isNotEmpty) {
              numberOfBreaks += getDayFilterBreaks.length;
            }
          }
        } else {
          TrackingDB db = TrackingDB();
          if (getTrackingDay['id'] != null) {
            List<Map<String, dynamic>> breakSessions = await db.readData(
                    sql:
                        "select * from break_sessions where trackingSessionId = '${getTrackingDay['trackingSession']}' and endTime <> ''")
                as List<Map<String, dynamic>>;
            if (mounted) {
              final getDayFilterBreaks = breakSessions.where((breakSession) =>
                  areDatesSame(breakSession['startTime'].toDate(), date));
              if (getDayFilterBreaks.isNotEmpty) {
                numberOfBreaks += getDayFilterBreaks.length;
              }
            }
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
      {required DateTime choosedDate,
      required BuildContext context,
      required bool isUserExist}) async {
    Map<String, dynamic> data = {};

    List<Map<String, dynamic>> worksDay = await getDataSameDateLikeToday(
        date: choosedDate, context: context, isUserExist: isUserExist);

    double inMinutes = 0;

    for (Map<String, dynamic> workDay in worksDay) {
      if (workDay.isNotEmpty) {
        if (isUserExist) {
          if (!workDay['isCompleted']) {
            return data;
          }
        } else {
          if (workDay['isCompleted'] == 0) {
            return data;
          }
        }
        String? startWorkTime;
        String? endWorkTime;

        if (isUserExist) {
          startWorkTime = workDay['startTime'].toDate().toString();
          endWorkTime = workDay['endTime'].toDate().toString();
        } else {
          startWorkTime = workDay['startTime'];
          endWorkTime = workDay['endTime'];
        }
        DateTime? start =
            DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(startWorkTime!);
        DateTime? endTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(endWorkTime!);

        inMinutes += endTime!.difference(start!).inMinutes;
        data = {
          "hours": inMinutes,
          "isInHours": false,
        };
      }
    }
    return data;
  }

  Future<bool> isWorkFiniheshed(
      {required DateTime date,
      required BuildContext context,
      required bool isUserExist}) async {
    bool isWorkFiniheshed = false;
    List<Map<String, dynamic>> trackingSessions = [];
    bool istrackingSessionsAllClosed = true;
    if (context.mounted) {
      if (isUserExist) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        DateTime? dateFilter =
            DateFormat("yyyy-MM-dd").tryParse(date.toString());
        final getUsertrackingSessions = await FirebaseFirestore.instance
            .collection('trackingSessions')
            .where('userId', isEqualTo: userId)
            .get();

        if (context.mounted) {
          final maptrackingSessions = getUsertrackingSessions.docs
              .map((trackingSession) => trackingSession.data());
          for (Map<String, dynamic> gettrackingSession in maptrackingSessions) {
            if (gettrackingSession['isCompleted'] &&
                gettrackingSession["endTime"] != '') {
              if (DateFormat("yyyy-MM-dd")
                  .tryParse(gettrackingSession["endTime"].toDate().toString())!
                  .isAtSameMomentAs(dateFilter!)) {
                trackingSessions.add(gettrackingSession);
              }
            }
            if (DateFormat("yyyy-MM-dd")
                .tryParse(gettrackingSession["startTime"].toDate().toString())!
                .isAtSameMomentAs(dateFilter!)) {
              if (gettrackingSession["endTime"] == '' &&
                  !gettrackingSession['isCompleted']) {
                istrackingSessionsAllClosed = false;
              }
            }
          }
        }
      } else {
        TrackingDB db = TrackingDB();
        String dateToday = DateFormat('yyyy-MM-dd').format(date);
        trackingSessions = await db.readData(
                sql:
                    'select * from tracking_sessions where substr(startTime,1,10) ="$dateToday" ')
            as List<Map<String, dynamic>>;
      }
      if (trackingSessions.isNotEmpty) {
        // isWorkFiniheshed = true;

        // same logic
        for (Map<String, dynamic> trackingSession in trackingSessions) {
          if (isUserExist) {
            if (!trackingSession["isCompleted"]) {
              isWorkFiniheshed = false;
            } else {
              isWorkFiniheshed = true;
            }
          } else {
            if (trackingSession["isCompleted"] == 0) {
              isWorkFiniheshed = false;
            } else {
              isWorkFiniheshed = true;
            }
          }
        }
      } else {
        isWorkFiniheshed = false;
      }
    }
    if (istrackingSessionsAllClosed && isWorkFiniheshed) {
      isWorkFiniheshed = true;
    } else {
      isWorkFiniheshed = false;
    }

    return isWorkFiniheshed;
  }

  Future<List<Map<String, dynamic>>> getWorkDataFromSpecificDate(
      {required DateTime date,
      required bool mounted,
      String? categoryId,
      required bool isUserExist}) async {
    List<Map<String, dynamic>> worksDataGet = [];
    TrackingDB db = TrackingDB();
    String formatDate = DateFormat("yyyy-MM-dd").format(date);
    List<Map<String, dynamic>> getWorksData = [];
    List<Map<String, dynamic>> worksData = [];

    if (isUserExist) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      DateTime? dateFilter = DateFormat("yyyy-MM-dd").tryParse(date.toString());
      if (categoryId != null && categoryId != '') {
        final getUsertrackingSessions = await FirebaseFirestore.instance
            .collection("trackingSessions")
            .where("userId", isEqualTo: userId)
            .where("categoryId", isEqualTo: categoryId)
            .get();
        if (mounted) {
          getWorksData = getUsertrackingSessions.docs
              .where((trackingSession) =>
                  DateFormat("yyyy-MM-dd").tryParse(trackingSession
                      .data()['startTime']
                      .toDate()
                      .toString()) ==
                  dateFilter)
              .map((workUserSession) => workUserSession.data())
              .toList();
          worksData = getWorksData;
        }
      } else {
        final getUsertrackingSessions = await FirebaseFirestore.instance
            .collection("trackingSessions")
            .where("userId", isEqualTo: userId)
            .get();
        if (mounted) {
          getWorksData = getUsertrackingSessions.docs
              .where((trackingSession) =>
                  DateFormat("yyyy-MM-dd").tryParse(trackingSession
                      .data()['startTime']
                      .toDate()
                      .toString()) ==
                  dateFilter)
              .map((workUserSession) => workUserSession.data())
              .toList();
          worksData = getWorksData;
        }
      }
    } else {
      if (categoryId != null && categoryId != '') {
        getWorksData = await db.readData(
            sql:
                'select * from tracking_sessions where substr(startTime,1,10)="$formatDate" and categoryId="$categoryId"');
      } else {
        getWorksData = await db.readData(
            sql:
                'select * from tracking_sessions where substr(startTime,1,10)="$formatDate"');
        // worksDataGet.clear();
      }
      if (getWorksData.isNotEmpty) {
        List<Map<String, dynamic>> getWorksDataTransfer =
            List.from(getWorksData);
        List<Map<String, dynamic>> worksDataConvert = getWorksDataTransfer
            .map((workData) => Map<String, dynamic>.from(workData))
            .toList();
        worksData = worksDataConvert;
      }
    }

    if (mounted) {
      for (Map<String, dynamic> workData in worksData) {
        String? startWorkTimeConvert;
        String? endWorkTimeConvert;
        if (workData['startTime'] is Timestamp) {
          startWorkTimeConvert = workData['startTime'].toDate().toString();
          endWorkTimeConvert = workData['endTime'].toDate().toString();
        } else {
          startWorkTimeConvert = workData['startTime'];
          endWorkTimeConvert = workData['endTime'];
        }

        DateTime? startWorkTime =
            DateFormat("yyyy-MM-dd HH:mm:ss").tryParse(startWorkTimeConvert!);
        workData.update(
            'startTime', (value) => DateFormat('HH:mm').format(startWorkTime!));

        DateTime? endWorkTime =
            DateFormat("yyyy-MM-dd HH:mm:ss").tryParse(endWorkTimeConvert!);
        workData.update(
            'endTime', (value) => DateFormat('HH:mm').format(endWorkTime!));
        workData['workedTime'] =
            endWorkTime?.difference(startWorkTime!).inMinutes;
        worksDataGet.add(workData);
      }
    }

    return worksDataGet;
  }

  Future<List<Map<String, dynamic>>> getBreaksFromSpecificDateAndId(
      {required int trackingSessionsId, required bool mounted}) async {
    List<Map<String, dynamic>> breaks = [];
    TrackingDB db = TrackingDB();
    final getBreaksData = await db.readData(
        sql:
            "select * from break_sessions where trackingSessionId='$trackingSessionsId' ");

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
      required bool isUserExist,
      List<Map<String, dynamic>>? allTrackings,
      String? trackingSessionId}) async {
    List<Map<String, dynamic>> breaks = [];
    if (isUserExist) {
      if (trackingSessionId != null) {
        final getBreakSession = await FirebaseFirestore.instance
            .collection("breakSessions")
            .where("trackingSessionId", isEqualTo: trackingSessionId)
            .get();
        if (mounted) {
          breaks = getBreakSession.docs
              .map((breajUserSession) => breajUserSession.data())
              .toList();
        }
      } else {
        for (Map<String, dynamic> tracking in allTrackings!) {
          final getBreaktrackingSession = await FirebaseFirestore.instance
              .collection("breakSessions")
              .where("trackingSessionId",
                  isEqualTo: tracking["trackingSession"])
              .get();
          final getDayFilterBreaks = getBreaktrackingSession.docs.where(
              (breakSession) => areDatesSame(
                  breakSession['startTime'].toDate(), breakSessionTime));
          if (mounted) {
            if (getDayFilterBreaks.isNotEmpty) {
              List<Map<String, dynamic>> breaksConvert = getDayFilterBreaks
                  .map((breakSession) => breakSession.data())
                  .toList();
              breaks.addAll(breaksConvert);
            }
          }
        }
      }
    } else {
      TrackingDB db = TrackingDB();
      String formatDate = DateFormat("yyyy-MM-dd").format(breakSessionTime);
      List<Map<String, dynamic>>? getBreaksData;
      if (trackingSessionId != null) {
        getBreaksData = await db.readData(
            sql:
                'select * from break_sessions where trackingSessionId= "$trackingSessionId" ');
      } else {
        getBreaksData = await db.readData(
            sql:
                'select * from break_sessions where substr(endTime,1,10)="$formatDate" ');
      }
      if (mounted) {
        final getDayFilterBreaks = getBreaksData.where((breakSession) =>
            areDatesSame(breakSession['startTime'].toDate(), breakSessionTime));
        if (getDayFilterBreaks.isNotEmpty) {
          breaks = getDayFilterBreaks
              .map((breakData) => Map<String, dynamic>.from(breakData))
              .toList();
        }
      }
    }

    for (Map<String, dynamic> getBreakData in breaks) {
      String? startBreakTimeConvert;
      String? endBreakTimeConvert;
      if (getBreakData['startTime'] is Timestamp) {
        startBreakTimeConvert = getBreakData['startTime'].toDate().toString();
        endBreakTimeConvert = getBreakData['endTime'].toDate().toString();
      } else {
        startBreakTimeConvert = getBreakData['startTime'];
        endBreakTimeConvert = getBreakData['endTime'];
      }

      DateTime? breakStartTimeAsDate =
          DateFormat("yyyy-MM-dd HH:mm:ss").tryParse(startBreakTimeConvert!);
      getBreakData["startTime"] =
          DateFormat("HH:mm").format(breakStartTimeAsDate!);
      DateTime? breakEndTimeAsDate =
          DateFormat("yyyy-MM-dd HH:mm:ss").tryParse(endBreakTimeConvert!);

      getBreakData["endTime"] = DateFormat("HH:mm").format(breakEndTimeAsDate!);

      getBreakData['duration'] =
          breakEndTimeAsDate.difference(breakStartTimeAsDate).inMinutes;
    }

    return breaks;
  }

  Future<bool> isAllBreaksClosed(
      {required Map<String, dynamic> trackingDay,
      required BuildContext context,
      required bool isUserExist}) async {
    bool isAllBreaksClosed = true;
    List<Map<String, dynamic>> formatBreaksToList = [];

    if (isUserExist) {
      final checkIfBreakSessionsExist = await FirebaseFirestore.instance
          .collection("breakSessions")
          .where("trackingSessionId",
              isEqualTo: trackingDay['trackingSessionId'])
          .limit(1)
          .get();
      if (context.mounted) {
        if (checkIfBreakSessionsExist.size > 0) {
          final getAllWorkBreaks = await FirebaseFirestore.instance
              .collection("breakSessions")
              .where("trackingSessionId",
                  isEqualTo: trackingDay['trackingSessionId'])
              .get();
          if (context.mounted) {
            formatBreaksToList = getAllWorkBreaks.docs
                .map((breakSession) => breakSession.data())
                .toList();
          }
        }
      }
    } else {
      TrackingDB db = TrackingDB();
      final getBreaks = await db.readData(
          sql:
              "select * from break_sessions where trackingSessionId = '${trackingDay['trackingSessionId']}'");
      final formatBreaksToListGet =
          getBreaks.map((breakData) => breakData).toList();
      formatBreaksToList = List.from(formatBreaksToListGet.map(
        (trackingSession) => Map<String, dynamic>.from(trackingSession),
      ));
    }

    for (Map<String, dynamic> breakData in formatBreaksToList) {
      bool isCompletedBreak = false;
      if (isUserExist) {
        if (!breakData['isCompleted']) {
          isCompletedBreak = false;
        }
      }
      if (breakData['endTime'] == '') {
        isCompletedBreak = false;
      } else {
        isCompletedBreak = true;
      }
      if ((breakData['endTime'] == '' || breakData['endTime'] == null) &&
          !isCompletedBreak) {
        isAllBreaksClosed = false;
      }
    }
    return isAllBreaksClosed;
  }

  Future<void> deleteWork(
      {required String id,
      required bool isUserExist,
      required bool mounted}) async {
    //delete work if UserExist
    if (isUserExist) {
      final breakSessions = await FirebaseFirestore.instance
          .collection("breakSessions")
          .where("trackingSessionId", isEqualTo: id)
          .get();
      if (!mounted) return;
      if (breakSessions.size > 0) {
        List<Map<String, dynamic>> breakSessionsAsList = breakSessions.docs
            .map((breakSession) => breakSession.data())
            .toList();
        for (Map<String, dynamic> breakSession in breakSessionsAsList) {
          await FirebaseFirestore.instance
              .collection("breakSessions")
              .doc(breakSession["id"])
              .delete();
          if (!mounted) return;
        }
      }
      await FirebaseFirestore.instance
          .collection("trackingSessions")
          .doc(id)
          .delete();
    } else {
      TrackingDB db = TrackingDB();
      await db.deleteData(sql: "delete from tracking_sessions where id ='$id'");
    }
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

// check if lokal data exists for Sync
  Future<bool> isLokalDataExists(
      {required BuildContext context, required bool isUserExist}) async {
    bool isLokalDataExists = false;
    if (isUserExist) {
      TrackingDB db = TrackingDB();
      bool? isTableExits = await db.doesTableExist("tracking_sessions");
      if (context.mounted) {
        if (!isTableExits) {
          isLokalDataExists = false;
        } else {
          final trackingSessionsGet =
              await db.readData(sql: 'select * from tracking_sessions')
                  as List<Map<String, dynamic>>;
          if (context.mounted) {
            if (trackingSessionsGet.isNotEmpty) {
              isLokalDataExists = true;
            }
          }
        }
      }
    }
    return isLokalDataExists;
  }

// Sync Data to Cloud after Confirmation
  Future<void> syncDataToCloud({
    required BuildContext context,
    required TrackingDB db,
  }) async {
    isLokalDataInCloudSync = true;

    final List<Map<String, dynamic>> gettrackingSessions = await db.readData(
        sql: 'select * from tracking_sessions') as List<Map<String, dynamic>>;

    if (context.mounted) {
      int completedItems = 0;
      for (int i = 0; i <= gettrackingSessions.length - 1; i++) {
        completedItems = i + 1;
        _progressSyncToCloud =
            (completedItems / gettrackingSessions.length) * 100;
        context.loaderOverlay
            .progress("Loading ${_progressSyncToCloud.toInt()}%");
        DateTime? startWorkTime = DateFormat("yyyy-MM-dd HH:mm:ss")
            .tryParse(gettrackingSessions[i]['startTime']);
        DateTime? endWorkTime = DateFormat("yyyy-MM-dd HH:mm:ss")
            .tryParse(gettrackingSessions[i]['endTime']);
        bool isCompleted =
            gettrackingSessions[i]['isCompleted'] == 1 ? true : false;
        String taskDescription = gettrackingSessions[i]["taskDescription"];
        final userId = FirebaseAuth.instance.currentUser?.uid;

        int durationMinutes = gettrackingSessions[i]["durationMinutes"];
        String id = gettrackingSessions[i]["id"];
        String trackingSessionId = gettrackingSessions[i]["id"];
        TrackingSession trackingSession = TrackingSession(
            id: id,
            startTime: startWorkTime!,
            createdAt: startWorkTime,
            categoryId: gettrackingSessions[i]["categoryId"],
            endTime: endWorkTime,
            isCompleted: isCompleted,
            taskDescription: taskDescription,
            userId: userId,
            durationMinutes: durationMinutes);
        await FirebaseFirestore.instance
            .collection('trackingSessions')
            .doc(trackingSessionId)
            .set(trackingSession.cloudToMap());

        if (!context.mounted) return;
        final List<Map<String, dynamic>> breakSessions = await db.readData(
                sql:
                    'select * from break_sessions where trackingSessionId ="$trackingSessionId" ')
            as List<Map<String, dynamic>>;
        if (context.mounted) {
          if (breakSessions.isNotEmpty) {
            for (Map<String, dynamic> breakSession in breakSessions) {
              var breakSessionNewId = const Uuid().v4();
              DateTime? startBreakTime = DateFormat("yyyy-MM-dd HH:mm:ss")
                  .tryParse(breakSession['startTime']);
              DateTime? endBreakTime = DateFormat("yyyy-MM-dd HH:mm:ss")
                  .tryParse(breakSession["endTime"]);
              String reason = breakSession['reason'];
              int durationBreakMinutes = breakSession["durationMinutes"];
              BreakSession breakSessionInit = BreakSession(
                  id: breakSessionNewId,
                  trackingSessionId: trackingSessionId,
                  startTime: startBreakTime!,
                  createdAt: startBreakTime,
                  endTime: endBreakTime,
                  reason: reason,
                  durationMinutes: durationBreakMinutes,
                  isCompleted: true);
              await FirebaseFirestore.instance
                  .collection("breakSessions")
                  .doc(breakSessionNewId)
                  .set(breakSessionInit.cloudToMap());
              if (!context.mounted) return;
            }
          }
          // delete Lokal Data
          await db.deleteData(
              sql:
                  'DELETE FROM tracking_sessions WHERE id ="$trackingSessionId"');
          if (!context.mounted) return;
        }

        if (!context.mounted) return;
      }
    }
    isLokalDataInCloudSync = false;
    notifyListeners();
  }

  // request for Sync if Data in lokal exist
  Future<void> requestForSyncToCloud(
      {required BuildContext context,
      required bool isUserExist,
      required AppLocalizations labels,
      required TrackingDB db}) async {
    bool istrackingSessionsInLokalExists =
        await isLokalDataExists(context: context, isUserExist: isUserExist);

    if (!context.mounted) return;
    if (istrackingSessionsInLokalExists) {
      await Constants.showDialogConfirmation(
          context: context,
          onConfirm: () async {
            Navigator.of(context).pop();
            context.loaderOverlay
                .show(progress: "Loading ${_progressSyncToCloud.toInt()}%");
            await syncDataToCloud(context: context, db: db);
            if (!context.mounted) return;
            notifyListeners();
          },
          title: labels.syncDataWithCloud,
          message: labels.syncDataWarning);
    }
  }
}
