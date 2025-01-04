import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/architecture.dart';
import 'dart:io';
import 'package:time_management/db/mydb.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/provider/category_provider.dart';
import 'package:time_management/provider/user_provider.dart';
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

  bool _isLokalDataInCloudSync = false;
  bool get isLokalDataInCloudSync => _isLokalDataInCloudSync;

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
      {required DateTime date,
      required BuildContext context,
      required bool isUserExist}) async {
    List<Map<String, dynamic>> worksDay = [];

    if (isUserExist) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      DateTime? dateFilter = DateFormat("yyyy-MM-dd").tryParse(date.toString());
      final getUserWorkSession = await FirebaseFirestore.instance
          .collection('workSessions')
          .where('userId', isEqualTo: userId)
          .get();
      if (context.mounted) {
        worksDay = getUserWorkSession.docs
            .where(
              (userWorkSession) =>
                  DateFormat("yyyy-MM-dd").tryParse(
                      userWorkSession.data()["endTime"].toDate().toString()) ==
                  dateFilter,
            )
            .map((workSession) => workSession.data())
            .toList();
      }
    } else {
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
    }

    return worksDay;
  }

  Future<int> getNumberOfBreaks(
      {required DateTime date,
      required bool mounted,
      required BuildContext context,
      required bool isUserExist}) async {
    int numberOfBreaks = 0;

    List<Map<String, dynamic>> getWorksDay = await getDataSameDateLikeToday(
        date: date, context: context, isUserExist: isUserExist);
    try {
      for (Map<String, dynamic> getWorkDay in getWorksDay) {
        if (isUserExist) {
          final getWorkBreaks = await FirebaseFirestore.instance
              .collection('breakSessions')
              .where("workSessionId", isEqualTo: getWorkDay['id'])
              .where("isCompleted", isEqualTo: true)
              .get();
          if (context.mounted) {
            if (getWorkBreaks.docs.isNotEmpty) {
              numberOfBreaks = getWorkBreaks.size;
            }
          }
        } else {
          TrackingDB db = TrackingDB();
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
          if (workDay['isCompleted'] == 0 && workDay['endTime'] == '') {
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
    bool isWorkFiniheshed = true;
    List<Map<String, dynamic>> workSessions = [];

    if (context.mounted) {
      if (isUserExist) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        DateTime? dateFilter =
            DateFormat("yyyy-MM-dd").tryParse(date.toString());
        final getUserWorkSession = await FirebaseFirestore.instance
            .collection('workSessions')
            .where('userId', isEqualTo: userId)
            .get();
        if (context.mounted) {
          workSessions = getUserWorkSession.docs
              .where(
                (userWorkSession) =>
                    DateFormat("yyyy-MM-dd").tryParse(userWorkSession
                        .data()["endTime"]
                        .toDate()
                        .toString()) ==
                    dateFilter,
              )
              .map((workSession) => workSession.data())
              .toList();
        }
      } else {
        TrackingDB db = TrackingDB();
        String dateToday = DateFormat('yyyy-MM-dd').format(date);
        workSessions = await db.readData(
                sql:
                    'select * from work_sessions where substr(startTime,1,10) ="$dateToday" ')
            as List<Map<String, dynamic>>;
      }
      if (workSessions.isNotEmpty) {
        // isWorkFiniheshed = true;

        // same logic
        for (Map<String, dynamic> workSession in workSessions) {
          if (isUserExist) {
            if (!workSession["isCompleted"]) {
              isWorkFiniheshed = false;
            } else {
              isWorkFiniheshed = true;
            }
          } else {
            if (workSession["isCompleted"] == 0) {
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
        final getUserWorkSessions = await FirebaseFirestore.instance
            .collection("workSessions")
            .where("userId", isEqualTo: userId)
            .where("categoryId", isEqualTo: categoryId)
            .get();
        if (mounted) {
          getWorksData = getUserWorkSessions.docs
              .where((workSession) =>
                  DateFormat("yyyy-MM-dd").tryParse(
                      workSession.data()['startTime'].toDate().toString()) ==
                  dateFilter)
              .map((workUserSession) => workUserSession.data())
              .toList();
          worksData = getWorksData;
        }
      } else {
        final getUserWorkSessions = await FirebaseFirestore.instance
            .collection("workSessions")
            .where("userId", isEqualTo: userId)
            .get();
        if (mounted) {
          getWorksData = getUserWorkSessions.docs
              .where((workSession) =>
                  DateFormat("yyyy-MM-dd").tryParse(
                      workSession.data()['startTime'].toDate().toString()) ==
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
                'select * from work_sessions where substr(startTime,1,10)="$formatDate" and categoryId="$categoryId"');
      } else {
        getWorksData = await db.readData(
            sql:
                'select * from work_sessions where substr(startTime,1,10)="$formatDate"');
        worksDataGet.clear();

        if (getWorksData.isNotEmpty) {
          List<Map<String, dynamic>> getWorksDataTransfer =
              List.from(getWorksData);
          List<Map<String, dynamic>> worksDataConvert = getWorksDataTransfer
              .map((workData) => Map<String, dynamic>.from(workData))
              .toList();
          worksData = worksDataConvert;
        }
      }
    }
    print(worksData);
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
      required bool isUserExist,
      List<Map<String, dynamic>>? allWorks,
      String? workSessionId}) async {
    List<Map<String, dynamic>> breaks = [];
    if (isUserExist) {
      print("object");
      if (workSessionId != null) {
        final getBreakSession = await FirebaseFirestore.instance
            .collection("breakSessions")
            .where("workSessionId", isEqualTo: workSessionId)
            .get();
        if (mounted) {
          breaks = getBreakSession.docs
              .map((workUserSession) => workUserSession.data())
              .toList();
        }
        print(allWorks?.length);
      } else {
        print("object");
        print(allWorks);
        for (Map<String, dynamic> work in allWorks!) {
          final getBreakWorkSession = await FirebaseFirestore.instance
              .collection("breakSessions")
              .where("workSessionId", isEqualTo: work["id"])
              .get();
          if (mounted) {
            if (getBreakWorkSession.docs.isNotEmpty) {
              List<Map<String, dynamic>> breaksConvert = getBreakWorkSession
                  .docs
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
      {required Map<String, dynamic> workDay,
      required BuildContext context,
      required bool isUserExist}) async {
    bool isAllBreaksClosed = true;
    List<Map<String, dynamic>> formatBreaksToList = [];

    if (isUserExist) {
      final checkIfBreakSessionsExist = await FirebaseFirestore.instance
          .collection("breakSessions")
          .where("workSessionId", isEqualTo: workDay['id'])
          .limit(1)
          .get();
      if (context.mounted) {
        if (checkIfBreakSessionsExist.size > 0) {
          final getAllWorkBreaks = await FirebaseFirestore.instance
              .collection("breakSessions")
              .where("workSessionId", isEqualTo: workDay['id'])
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
              "select * from break_sessions where workSessionId = '${workDay['id']}'");
      final formatBreaksToListGet =
          getBreaks.map((breakData) => breakData).toList();
      formatBreaksToList = List.from(formatBreaksToListGet.map(
        (workSession) => Map<String, dynamic>.from(workSession),
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

// check if lokal data exists for Sync
  Future<bool> isLokalDataExists(
      {required BuildContext context, required bool isUserExist}) async {
    bool isLokalDataExists = false;
    if (isUserExist) {
      TrackingDB db = TrackingDB();
      bool? isTableExits = await db.doesTableExist("work_sessions");
      if (context.mounted) {
        if (!isTableExits) {
          isLokalDataExists = false;
        } else {
          final workSessionsGet = await db.readData(
              sql: 'select * from work_sessions') as List<Map<String, dynamic>>;
          if (context.mounted) {
            if (workSessionsGet.isNotEmpty) {
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
    _isLokalDataInCloudSync = true;

    final List<Map<String, dynamic>> getWorkSessions = await db.readData(
        sql: 'select * from work_sessions') as List<Map<String, dynamic>>;
    if (context.mounted) {
      for (int i = 0; i < getWorkSessions.length - 1; i++) {
        var workSessionNewId = const Uuid().v4();
        DateTime? startWorkTime = DateFormat("yyyy-MM-dd HH:mm:ss")
            .tryParse(getWorkSessions[i]['startTime']);
        DateTime? endWorkTime = DateFormat("yyyy-MM-dd HH:mm:ss")
            .tryParse(getWorkSessions[i]['endTime']);
        bool isCompleted =
            getWorkSessions[i]['isCompleted'] == 1 ? true : false;
        String taskDescription = getWorkSessions[i]["taskDescription"];
        final userId = FirebaseAuth.instance.currentUser?.uid;
        int durationMinutes = getWorkSessions[i]["durationMinutes"];
        WorkSession workSession = WorkSession(
            id: workSessionNewId,
            startTime: startWorkTime!,
            createdAt: startWorkTime,
            categoryId: getWorkSessions[i]["categoryId"],
            endTime: endWorkTime,
            isCompleted: isCompleted,
            taskDescription: taskDescription,
            userId: userId,
            durationMinutes: durationMinutes);
        await FirebaseFirestore.instance
            .collection('workSessions')
            .doc(workSessionNewId)
            .set(workSession.cloudToMap());
        if (!context.mounted) return;
        final List<Map<String, dynamic>> breakSessions = await db.readData(
                sql:
                    'select * from work_sessions where workSessionId ="${getWorkSessions[i]["id"]}" ')
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
                  workSessionId: workSessionNewId,
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
                  'DELETE FROM work_sessions WHERE id ="${getWorkSessions[i]["id"]}"');
          if (!context.mounted) return;
        }
      }
    }
    _isLokalDataInCloudSync = false;
    notifyListeners();
  }

  // request for Sync if Data in lokal exist
  Future<void> requestForSyncToCloud(
      {required BuildContext context,
      required bool isUserExist,
      required AppLocalizations labels,
      required TrackingDB db}) async {
    bool isWorkSessionsInLokalExists =
        await isLokalDataExists(context: context, isUserExist: isUserExist);
    print(isWorkSessionsInLokalExists);
    if (!context.mounted) return;
    if (isWorkSessionsInLokalExists) {
      await Constants.showDialogConfirmation(
          context: context,
          onConfirm: () {
            syncDataToCloud(context: context, db: db);
          },
          title: labels.syncDataWithCloud,
          message: labels.syncDataWarning);
    }
  }
}
