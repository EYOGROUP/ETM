import 'dart:async';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/architecture.dart';
import 'package:time_management/controller/category_architecture.dart';
import 'package:time_management/db/mydb.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/provider/category_provider.dart';

import 'package:time_management/provider/tm_provider.dart';
import 'package:time_management/provider/user_provider.dart';
import 'package:uuid/uuid.dart';

class StartTimePage extends StatefulWidget {
  const StartTimePage({super.key});

  @override
  State<StartTimePage> createState() => _StartTimePageState();
}

class _StartTimePageState extends State<StartTimePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isStartWork = false;

  DateTime? workStartTime;
  DateTime? workFinishTime;
  bool isInitFinished = false;
  int numberOfBreaks = 0;
  Timer? _timer; // Timer for periodic updates
  bool _isDisposed = false;
  String point = '';
  double _sliderWorkValue = 0.0;
  bool isThumbStartTouchingText = false;
  String sliderForWorkingTime = '';
  bool isSmallLabel = false;
  String startWorkTimeInit = "-";
  String finishWorkTimeInit = "-";

// variable for Break
  String sliderForBreakTime = "";
  bool _isBreak = false;
  bool isSmallBreakSliderLabel = false;
  double _sliderBreakValue = 0.0;
  bool isThumbBreakStartTouchingText = false;
  bool isInhours = false;
  int workedTime = 0;
  String? workStartedTime;
  String? workEndedTime;

  List<Map<String, dynamic>>? getCategories;
  bool isGettingData = false;
  String standardLanguage = "en";
// Category
  Map<String, dynamic> categoryHint = {};
  bool isSwitchCategoryAvailable = true;
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _breakReasonController = TextEditingController();
  RewardedAd? _rewardedAd;
  List<Map<String, dynamic>> activatedCategories = [];
  List<ETMCategory> _categories = [];
  List<Map<String, dynamic>> _categoriesGet = [];
  Map<String, dynamic>? choosedCategory;
  bool _isInternetConnected = false;
  bool isUserExists = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _categories = ETMCategory.categories;
        await checkInternet();
        await checkUserIfExist();
        await getCategoriesFromProvider();
        await loadRewardedAd();
        await getAllData(isSwitchCategory: false, isInit: true);
      },
    );
  }

  getCategoriesFromProvider() async {
    _categoriesGet = await Provider.of<CategoryProvider>(context, listen: false)
        .getCategories(context: context);
    setState(() {});
  }

  Future<void> checkInternet() async {
    final eTManagement =
        Provider.of<TimeManagementPovider>(context, listen: false);
    eTManagement.monitorInternet(context);
    eTManagement.isConnectedToInternet(context: context);
  }

  checkUserIfExist() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    isUserExists = await userProvider.isUserLogin(context: context);
  }

  Future<void> startWork(
      {required TimeManagementPovider timeManagementPovider}) async {
    bool isInsert = true;
    bool isAnotherCategory = true;
    bool isWorkFinished = false;

    AppLocalizations getLabels = AppLocalizations.of(context)!;
    getLabels = AppLocalizations.of(context)!;
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    if (!mounted) return;
    bool isAlreadStartedWork = await isAlreadyStartedWorkDay();

    List<Map<String, dynamic>> isAlreadClosedWork =
        await getNotClosedWorkData();
    bool isNotClosedAfterTime = await isNotClosedWork();
    if (!mounted) return;

    if (categoryProvider.selectedCategory.isEmpty &&
        !isAlreadStartedWork &&
        isAlreadClosedWork.isEmpty &&
        !isNotClosedAfterTime &&
        categoryHint.isEmpty) {
      return Constants.showInSnackBar(
          value: getLabels.selectCategory, context: context);
    }
    bool isCategoryAlreadyActivated = await isAlreadyCategoryActivated(
        categorySet: categoryProvider.selectedCategory);

    if (!mounted) return;
    if (!isCategoryAlreadyActivated) {
      return Constants.showInSnackBar(
          value: getLabels.activateCategoryToStart(
              categoryProvider.selectedCategory["name"]
                  [timeManagementPovider.getCurrentLocalSystemLanguage()]),
          context: context);
    }
    if (isAlreadStartedWork || isNotClosedAfterTime) {
      await completedWork(getLabels: getLabels);
    }

    if (categoryProvider.selectedCategory.isNotEmpty) {
      String categoryId = categoryProvider.selectedCategory["id"];
      List<Map<String, dynamic>> worksDay =
          await getDataSameDateLikeToday(categoryIdGet: categoryId);
      if (!mounted) return;
      if (worksDay.isEmpty) {
        isInsert = false;
      } else {
        for (Map<String, dynamic> workDay in worksDay) {
          if (workDay["categoryId"] == categoryId) {
            isAnotherCategory = false;
          }
          if (!isAnotherCategory &&
              workDay["isCompleted"] == 1 &&
              workDay["endTime"] != "") {
            isWorkFinished = true;
          }
        }
      }

      if (!isInsert || isAnotherCategory) {
        workStartTime = DateTime.now();

        var workSessionId = const Uuid().v4();
        TrackingDB db = TrackingDB();
        WorkSession workSession = WorkSession(
          categoryId: categoryId,
          startTime: workStartTime!,
          createdAt: workStartTime!,
          taskDescription: "",
          isCompleted: false,
          id: workSessionId,
        );

        await db.insertData(
            tableName: 'work_sessions', data: workSession.lokalToMap());
        await isSwitchCategoryAvailablity();
        if (!mounted) return;

        if (workFinishTime != null) {
          resetAllData();
        }
        setState(() {
          _isStartWork = true;
        });
      }
    }

    if (!mounted) return;

    if (!isAnotherCategory && isWorkFinished) {
      return Constants.showInSnackBar(
          value: getLabels.workFinishedForToday, context: context);
    }
  }

//ca-app-pub-6165489189371233/7954842835

  Future<void> loadRewardedAd() async {
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917'
        : 'ca-app-pub-3940256099942544/1712485313';
    await RewardedAd.load(
      adUnitId: adUnitId, // Deine Rewarded Ad Unit ID
      request: const AdRequest(),

      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Rewarded Ad failed to load: $error');
          setState(() {
            _rewardedAd = null;
          });
          _rewardedAd?.dispose();
        },
      ),
    );
  }

  Future<bool> isAlreadyCategoryActivated(
      {required Map<String, dynamic> categorySet}) async {
    bool isAlreadyActivate = false;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // if false: Is user as Lokal
    bool isUserExists = await userProvider.isUserLogin(context: context);
    if (!isUserExists) {
      // check if Category is locked

      if (categorySet["isUnlocked"] != 0 && categorySet["isPremium"] != 0) {
        isAlreadyActivate = true;
      } else {
        final categoryProvider =
            Provider.of<CategoryProvider>(context, listen: false);

        List<Map<String, dynamic>> categories =
            await categoryProvider.getAllLokalUserCategories(mounted: mounted);

        if (categories.isNotEmpty) {
          List<Map<String, dynamic>> categeryGet = categories
              .where((category) => category["id"] == categorySet['id'])
              .toList();

          if (categeryGet.isNotEmpty) {
            if (categeryGet[0]["isUnlocked"] == 1) {
              isAlreadyActivate = true;
            }
          }
        }
      }
    } else {
      if (categorySet["isPremium"] && categorySet["isUnlocked"]) {
        isAlreadyActivate = true;
      }
    }
    return isAlreadyActivate;
  }

  Future<void> _showRewardedAd(
      {required Map<String, dynamic> categorySet}) async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    bool isCategoryAlreadyActivated =
        await isAlreadyCategoryActivated(categorySet: categorySet);

    if (!mounted) return;

    if (isCategoryAlreadyActivated) {
      await setCategory(categorySet: categorySet);
      resetAllData();
      print('Category Alreadey Activated');
      return;
    }
    if (_rewardedAd == null) {
      return Constants.showInSnackBar(
          value: "Please try later again!", context: context);
    }

    if (!isCategoryAlreadyActivated && _rewardedAd != null) {
      await _rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
          await categoryProvider.unlockCategory(
              categorySet: categorySet, context: context, mounted: mounted);
          if (!mounted) return;
          resetAllData();
          categoryProvider.resetSelectedCategory();
          await setCategory(categorySet: categorySet);
          await categoryProvider.getLockedCategories(mounted: mounted);
          // getCategoriesFromProvider(categoryProvider: categoryProvider, isInit: false);
        },
      );

      _rewardedAd = null; // Reset the ad so it can be reloaded
      await loadRewardedAd(); // Load a new ad for next time
    }
  }

  Future<void> setCategory({required Map<String, dynamic> categorySet}) async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.setCategory = categorySet;
    await categoryProvider.insertCategoryLokal(
        categorySet: categorySet, context: context, mounted: mounted);
  }

  Future<void> getAllData(
      {required bool isSwitchCategory,
      Map<String, dynamic>? categorySet,
      required bool isInit}) async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        final timeManagementPovider =
            Provider.of<TimeManagementPovider>(context, listen: false);
        timeManagementPovider.setOrientation(context);
        final categoryProvider =
            Provider.of<CategoryProvider>(context, listen: false);
        await categoryProvider.getLockedCategories(mounted: mounted);
        if (!mounted) return;
        activatedCategories = categoryProvider.lockedCategories;
        await isSwitchCategoryAvailablity();
        if (!mounted) return;
        if (isSwitchCategoryAvailable) {
          if (isInit) {
            if (categoryProvider.selectedCategory.isNotEmpty) {
              categoryProvider.resetSelectedCategory();
              resetAllData();
            }
          }
        }
        // await getCategoriesFromProvider(categoryProvider: categoryProvider);
        // activatedCategories.add(getCategories!.first);

        sliderForWorkingTime = AppLocalizations.of(context)!.startWork;
        sliderForBreakTime = AppLocalizations.of(context)!.startBreak;

        if (!isSwitchCategory) {
          await getCategoryIfWorkAlreadyStarted(isClosedWork: false);
        }

        await getWorkTime(
            isSelectedCategory: isSwitchCategory,
            category: categoryProvider.selectedCategory.isNotEmpty
                ? categoryProvider.selectedCategory
                : categorySet);
        await getNumberOfBreaks(isSwitchCategory: isSwitchCategory);
        await getHoursOrMinutesWorkedForToday(
            categoryIdSet: categoryProvider.selectedCategory.isNotEmpty
                ? categoryProvider.selectedCategory["id"]
                : categorySet?['id']);
        await checkIfWorkAndBreakForTodayNotFinished();

        if (!mounted) return;

        stopLoadingAnimation();
        categoryHint = categoryProvider.selectedCategory;
      },
    );
  }

  void resetAllData() {
    setState(() {
      workStartTime = null;
      workStartedTime = null;
      categoryHint = {};

      workFinishTime = null;
      numberOfBreaks = 0;
      workedTime = 0;

      workEndedTime = null;
      isInhours = false;
    });
  }

  // Future<void> resetAllDataByInit() async {
  //   List<Map<String, dynamic>> getNoClosedWork = await getNotClosedWorkData();
  //   print(getNoClosedWork);
  //   if (getNoClosedWork.isEmpty) {
  //     resetAllData(switchCategory: true);
  //   }
  // }

  Future<List<Map<String, dynamic>>> getNotClosedWorkData() async {
    List<Map<String, dynamic>> getWorkNotClosed = [];
    TrackingDB db = TrackingDB();
    // List<Map<String, dynamic>> workSession = [];
    String dateToday = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    bool isAlreadyStartWork = await isAlreadyStartedWorkDay();
    if (mounted) {
      if (isAlreadyStartWork) {
        if (categoryProvider.selectedCategory.isNotEmpty) {
          String categoryId = categoryProvider.selectedCategory["id"];

          getWorkNotClosed = await db.readData(
              sql:
                  "select * from work_sessions where endTime='' and substr(startTime,1,10)='$dateToday' and categoryId = '$categoryId'");
        } else {
          getWorkNotClosed = await db.readData(
              sql:
                  "select * from work_sessions where endTime='' and substr(startTime,1,10)='$dateToday'");
        }
      }
    }
    return getWorkNotClosed;
  }

  Future<void> isSwitchCategoryAvailablity() async {
    List<Map<String, dynamic>> getNoClosedWork = await getNotClosedWorkData();
    if (mounted) {
      if (getNoClosedWork.isNotEmpty) {
        setState(() {
          isSwitchCategoryAvailable = false;
        });
      }
    }
  }

  Future<void> getCategoryIfWorkAlreadyStarted(
      {required bool isClosedWork, Map<String, dynamic>? data}) async {
    String? categoryId;
    TrackingDB db = TrackingDB();

    if (!isClosedWork) {
      List<Map<String, dynamic>> getNoClosedWork = await getNotClosedWorkData();

      if (getNoClosedWork.isNotEmpty) {
        categoryId = getNoClosedWork[0]["categoryId"];
      }
    }

    if (isClosedWork) {
      categoryId = data?['categoryId'];
    }
    if (categoryId != null) {
      final getLokalCategory = await db.readData(
          sql: "select * from categories where id='$categoryId'");
      if (!mounted) return;
      ETMCategory getCategory = ETMCategory.categories
          .where((category) => category.id == categoryId)
          .first;
      Map<String, dynamic> categoryInfoUpdat = {
        "name": getCategory.name,
        "id": getLokalCategory.first["id"],
        'isUnlocked': getLokalCategory.first["isUnlocked"] == 1 ? true : false,
        'unlockExpiry': getLokalCategory.first["unlockExpiry"],
        "description": getCategory.description,
        "isPremium": getCategory.isPremium,
      };

      setCategory(categorySet: categoryInfoUpdat);
      setState(() {
        categoryHint = categoryInfoUpdat;
      });
    }
  }

  Future<bool> isAlreadyStartedWorkDay() async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> workSession = [];
    String dateToday = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (categoryHint.isNotEmpty ||
        categoryProvider.selectedCategory.isNotEmpty) {
      String categoryId = categoryProvider.selectedCategory["id"];

      workSession = await db.readData(
              sql:
                  'select * from work_sessions where (isCompleted=0 and substr(startTime,1,10) ="$dateToday") OR (isCompleted =1 and substr(startTime,1,10) ="$dateToday") AND substr(startTime,1,10) ="$dateToday" AND categoryId="$categoryId" ')
          as List<Map<String, dynamic>>;
    }

    if (workSession.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isNotClosedWork() async {
    bool isNotClosedWork = false;
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> workSession = [];
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.selectedCategory.isNotEmpty) {
      String categoryId = categoryProvider.selectedCategory["id"];
      workSession = await db.readData(
              sql:
                  'select * from work_sessions where isCompleted=0  and categoryId="$categoryId"')
          as List<Map<String, dynamic>>;
    }
    if (workSession.isNotEmpty) {
      isNotClosedWork = true;
    }
    return isNotClosedWork;
  }

  Future<void> checkIfWorkAndBreakForTodayNotFinished() async {
    final getLabels = AppLocalizations.of(context)!;
    TrackingDB db = TrackingDB();
    String dateToday = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<Map<String, dynamic>> workSession = await db.readData(
            sql:
                'select * from work_sessions where isCompleted=0 and substr(startTime,1,10) ="$dateToday" ')
        as List<Map<String, dynamic>>;
    if (workSession.isNotEmpty) {
      bool isBreak = await isBreakTooken(getWorkDayData: workSession.first);
      bool isClosedBreak =
          await isAlreadyClosedBreak(getDayWorkData: workSession.first);
      if (isBreak && !isClosedBreak) {
        setState(() {
          _isBreak = true;
          sliderForBreakTime = getLabels.stopBreak;
        });
      }
      setState(() {
        _isStartWork = true;
        sliderForWorkingTime = getLabels.stopWork;
      });
    } else {
      setState(() {
        _isStartWork = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> getDataSameDateLikeToday(
      {String? categoryIdGet}) async {
    List<Map<String, dynamic>> workDay = [];
    TrackingDB db = TrackingDB();
    workFinishTime = DateTime.now();
    List<Map<String, dynamic>> works = [];
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    List<Map<String, dynamic>> notClosedWorkData = await getNotClosedWorkData();

    if (notClosedWorkData.isNotEmpty) {
      if (categoryProvider.selectedCategory.isNotEmpty) {
        String categoryId = categoryProvider.selectedCategory["id"];
        works = await db.readData(
                sql:
                    'select * from work_sessions where categoryId="$categoryId"')
            as List<Map<String, dynamic>>;
      } else if (categoryProvider.selectedCategory.isEmpty) {
        String categoryId = categoryIdGet ?? notClosedWorkData[0]['categoryId'];
        works = await db.readData(
                sql:
                    'select * from work_sessions where categoryId="$categoryId"')
            as List<Map<String, dynamic>>;
      }
    } else if (categoryProvider.selectedCategory.isNotEmpty) {
      String categoryId = categoryProvider.selectedCategory["id"];

      works = await db.readData(
              sql: 'select * from work_sessions where categoryId="$categoryId"')
          as List<Map<String, dynamic>>;
    }
    //  else {
    //   works = await db.readData(sql: 'select * from work_sessions')
    //       as List<Map<String, dynamic>>;
    // }

    for (Map<String, dynamic> work in works) {
      DateTime? startTimeToday =
          DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(work['startTime'])!;

// check if data date same like today
      bool isSameDate = areDatesSame(startTimeToday, DateTime.now());
      if (isSameDate) {
        workDay.add(work);
      }
      //  else {
      //   workDay.add(work);
      // }
    }

    return workDay;
  }

  Future<void> completedWork({required AppLocalizations getLabels}) async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final breakProvider =
        Provider.of<TimeManagementPovider>(context, listen: false);

    TrackingDB db = TrackingDB();
    workFinishTime = DateTime.now();
    List<Map<String, dynamic>> worksDay = await getDataSameDateLikeToday(
        categoryIdGet: categoryProvider.selectedCategory["id"]);

    if (!mounted) return;
    // check if not completed and endTime not filled
    if (worksDay.isEmpty) {
      return;
    }

    // if Work day not finished
    for (Map<String, dynamic> workDay in worksDay) {
      if (workDay['isCompleted'] == 0 && workDay['endTime'] == '') {
        Map<String, dynamic> updateData = {
          'endTime': workFinishTime.toString(),
          'isCompleted': 1,
          'taskDescription': _todoController.text
        };
        //check if all breaks closed
        bool isAllBreaksClosed =
            await breakProvider.isAllBreaksClosed(workDay: workDay);
        if (!mounted) return;
        if (!isAllBreaksClosed) {
          return Constants.showInSnackBar(
              value: getLabels.closeBreakFirst, context: context);
        }
        await db.updateData(
            tableName: 'work_sessions',
            data: updateData,
            columnId: 'id',
            id: workDay['id']);
        if (!mounted) return;
        await categoryProvider.closeCategoryForNotPremiumUserAfterUseIt();
        lockCategory();
        await getHoursOrMinutesWorkedForToday(
            categoryIdSet: categoryProvider.selectedCategory["id"]);

        if (!mounted) return;
        setState(() {
          _isStartWork = false;
          isSwitchCategoryAvailable = true;
        });
      }
    }
  }

  void lockCategory() {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    var selectedCategoryId = categoryProvider.selectedCategory["id"];

    List<Map<String, dynamic>> getLockedCatories = [];
    for (Map<String, dynamic> category in activatedCategories) {
      if (category["id"] == selectedCategoryId) {
        category.update(
          'isUnlocked',
          (value) => 0,
        );
        getLockedCatories.add(category);
      }
    }
    getCategories = getLockedCatories;

    setState(() {});
    // getCategory.update(
    //   'isUnlocked',
    //   (value) => 0,
    // );
  }

  // Future<void> getCategoriesFromProvider(
  //     {required CategoryProvider categoryProvider, bool isInit = true}) async {
  //   if (isInit) {
  //     setState(() {
  //       isGettingData = true;
  //     });
  //   }

  //   await categoryProvider.initCategoryInDB(context: context);
  //   if (mounted) {
  //     getCategories =
  //         await categoryProvider.getCategories(context: context, mounted: mounted);
  //   }
  //   setState(() {
  //     if (isInit) {
  //       isGettingData = false;
  //     }
  //   });
  // }

  getHoursOrMinutesWorkedForToday({String? categoryIdSet}) async {
    List<Map<String, dynamic>> worksDay =
        await getDataSameDateLikeToday(categoryIdGet: categoryIdSet);
    for (Map<String, dynamic> workDay in worksDay) {
      if (workDay.isEmpty || workDay['isCompleted'] == 0) {
        return;
      }
    }
    print(worksDay);
    startLoadingAnimation();
    for (Map<String, dynamic> workDay in worksDay) {
      DateTime? start =
          DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(workDay['startTime']);
      DateTime? endTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(workDay['endTime']);
      int hours = endTime!.difference(start!).inHours;
      if (hours > 0) {
        setState(() {
          isInhours = true;
          workedTime = hours;
        });
      } else {
        int inMinutes = endTime.difference(start).inMinutes;
        setState(() {
          workedTime = inMinutes;
        });
      }
    }
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

  Future<bool> isAlreadyClosedBreak(
      {required Map<String, dynamic> getDayWorkData}) async {
    bool isAlreadyClosedBreak = true;
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> breakSessions = await db.readData(
            sql:
                "select * from break_sessions where workSessionId ='${getDayWorkData['id']}' and endTime =''")
        as List<Map<String, dynamic>>;

    if (context.mounted) {
      if (breakSessions.isNotEmpty) {
        isAlreadyClosedBreak = false;
      }
    }
    return isAlreadyClosedBreak;
  }

  Future<bool> isBreakTooken(
      {required Map<String, dynamic> getWorkDayData}) async {
    bool isBreakTooken = false;
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> breakSessions = await db.readData(
            sql:
                "select * from break_sessions where workSessionId ='${getWorkDayData['id']}' ")
        as List<Map<String, dynamic>>;
    if (breakSessions.isNotEmpty) {
      isBreakTooken = true;
    }
    return isBreakTooken;
  }

  Future<bool> isFinishedWorkForToday(
      {required Map<String, dynamic> getWorkDayData}) async {
    bool isFinishedWorkForToday = false;
    if (getWorkDayData['endTime'] != '' && getWorkDayData['isCompleted'] == 1) {
      isFinishedWorkForToday = true;
    }
    return isFinishedWorkForToday;
  }

  Future<Map<String, dynamic>> getNotClosedBreak(
      {required Map<String, dynamic> getDayWorkData}) async {
    Map<String, dynamic> notClosedBreak = {};
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> breakSessions = await db.readData(
            sql:
                "select * from break_sessions where workSessionId ='${getDayWorkData['id']}' and endTime =''")
        as List<Map<String, dynamic>>;
    if (context.mounted) {
      if (breakSessions.isNotEmpty) {
        notClosedBreak = breakSessions.first;
      }
    }
    return notClosedBreak;
  }

  Future<void> takeOrFinishBreak() async {
    final getLabels = AppLocalizations.of(context)!;
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    String? categoryId;
    TrackingDB db = TrackingDB();

    if (categoryProvider.selectedCategory.isNotEmpty) {
      categoryId = categoryProvider.selectedCategory["id"];
    }

    List<Map<String, dynamic>> getWorksDayData =
        await getDataSameDateLikeToday(categoryIdGet: categoryId);

    if (!mounted) return;
    if (getWorksDayData.isEmpty) {
      return Constants.showInSnackBar(
          value: getLabels.startYourWorkBeforeBreak, context: context);
    }
    for (Map<String, dynamic> getWorkDayData in getWorksDayData) {
      bool? isWorkFinished =
          await isFinishedWorkForToday(getWorkDayData: getWorkDayData);

      if (!mounted) return;
      if (isWorkFinished) {
        return Constants.showInSnackBar(
            value: getLabels.startYourWorkBeforeBreak, context: context);
      }
      if (getWorkDayData.isNotEmpty) {
        bool isWorkAlreadyStarted = await isAlreadyStartedWorkDay();

        if (!mounted) return;
        if (isWorkAlreadyStarted) {
          bool isFinishedWork =
              await isFinishedWorkForToday(getWorkDayData: getWorkDayData);

          if (!mounted) return;
          if (isFinishedWork) {
            return Constants.showInSnackBar(
                value: getLabels.noMoreBreaksAvailable, context: context);
          } else {
            // here to start process for the break
            bool isAlreadyClosedBreakCheck = false;
            bool isBreakTookenCheck =
                await isBreakTooken(getWorkDayData: getWorkDayData);

            if (!mounted) return;
            if (isBreakTookenCheck) {
              isAlreadyClosedBreakCheck =
                  await isAlreadyClosedBreak(getDayWorkData: getWorkDayData);
            }

            if (!mounted) return;
            DateTime breakTime = DateTime.now();

            if (isBreakTookenCheck) {
              if (isAlreadyClosedBreakCheck) {
                await insertNewBreak(
                    getWorkDayData: getWorkDayData, breakTime: breakTime);
                if (!mounted) return;
                setState(() {
                  _isBreak = true;
                });
              } else {
                // finish Break
                TrackingDB db = TrackingDB();
                Map<String, dynamic> breakSession =
                    await getNotClosedBreak(getDayWorkData: getWorkDayData);

                if (!mounted) return;
                Map<String, dynamic> endTimeUpdate = {
                  'endTime': breakTime.toString(),
                  'reason': _breakReasonController.text
                };
                await db.updateData(
                    tableName: 'break_sessions',
                    data: endTimeUpdate,
                    columnId: 'id',
                    id: breakSession['id']);
                numberOfBreaks += 1;
                if (!mounted) return;
                setState(() {
                  _isBreak = false;
                });
              }
            } else {
              await insertNewBreak(
                  getWorkDayData: getWorkDayData, breakTime: breakTime);
              if (!mounted) return;
              setState(() {
                _isBreak = true;
              });
            }
          }
        }
      }
    }
  }

  Future<void> insertNewBreak(
      {required Map<String, dynamic> getWorkDayData,
      required DateTime breakTime}) async {
    TrackingDB db = TrackingDB();
    var breakSessionId = const Uuid().v4();
    BreakSession breakSession = BreakSession(
      durationMinutes: 0,
      workSessionId: getWorkDayData['id'],
      startTime: breakTime,
      createdAt: breakTime,
      reason: '',
      id: breakSessionId,
    );

    await db.insertData(
        tableName: 'break_sessions', data: breakSession.lokalToMap());
  }

  @override
  void dispose() {
    _isDisposed = true;
    // _rewardedAd?.dispose();
    _timer?.cancel(); // Cancel the timer if it's running
    super.dispose();
  }

  Future<void> getNumberOfBreaks({required bool isSwitchCategory}) async {
    numberOfBreaks = 0;
    TrackingDB db = TrackingDB();
    startLoadingAnimation();
    String? categoryId;
    try {
      if (categoryHint.isNotEmpty) {
        final getCategoryId = await db.readData(
                sql:
                    "select * from categories where id = '${categoryHint["id"]}'")
            as List<Map<String, dynamic>>;
        if (getCategoryId.isNotEmpty) {
          categoryId = getCategoryId[0]["id"];
        }
      }

      List<Map<String, dynamic>> getWorksDay =
          await getDataSameDateLikeToday(categoryIdGet: categoryId);

      for (Map<String, dynamic> getWorkDay in getWorksDay) {
        List<Map<String, dynamic>> breakSessions = [];
        if (getWorkDay['id'] != null) {
          if (categoryId != null) {
            breakSessions = await db.readData(
                    sql:
                        "select * from break_sessions where workSessionId = '${getWorkDay['id']}' and endTime <> ''")
                as List<Map<String, dynamic>>;
          } else {
            breakSessions = await db.readData(
                    sql:
                        "select * from break_sessions where workSessionId = '${getWorkDay['id']}' and endTime <> ''")
                as List<Map<String, dynamic>>;
          }

          if (mounted && !_isDisposed || isSwitchCategory) {
            setState(() {
              numberOfBreaks = breakSessions.length;
              isInitFinished = true;
              _isDisposed = true;
            });

            startLoadingAnimation(); // End the loading animation
          }
        }
      }
    } catch (error) {
      if (mounted) {
        Constants.showInSnackBar(value: error.toString(), context: context);
      }
    } finally {
      setState(() {
        isInitFinished = true;
      });
    }
  }

  void startLoadingAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (mounted) {
        setState(() {
          point += '.';
          if (point.length > 6) {
            point = ''; // Reset the dots after 6
          }
        });
      }
    });
  }

  void stopLoadingAnimation() {
    _timer?.cancel();
  }

  Future<void> getWorkTime(
      {required bool isSelectedCategory,
      Map<String, dynamic>? category}) async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    bool isAlreadyStarted = await isAlreadyStartedWorkDay();

    if (mounted) {
      if (isAlreadyStarted) {
        List<Map<String, dynamic>> getWorksDay = await getDataSameDateLikeToday(
            categoryIdGet: categoryProvider.selectedCategory["id"]);

        for (Map<String, dynamic> getWorkDay in getWorksDay) {
          if (mounted) {
            DateTime? startWork = DateFormat('yyyy-MM-dd hh:mm')
                .tryParse(getWorkDay['startTime']);
            String? formatStartTime = DateFormat('HH:mm').format(startWork!);
            setState(() {
              workStartedTime = formatStartTime;
            });
            if (getWorkDay['isCompleted'] == 1) {
              DateTime? endWork = DateFormat('yyyy-MM-dd HH:mm')
                  .tryParse(getWorkDay['endTime']);
              String? formatEndTime = DateFormat('HH:mm').format(endWork!);
              setState(() {
                workEndedTime = formatEndTime;
              });
            }
          }
          if (!isSelectedCategory && category == null) {
            await getCategoryIfWorkAlreadyStarted(
                isClosedWork: true, data: getWorkDay);
          } else {
            setState(() {
              categoryHint = {};
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final timeManagementPovider =
        Provider.of<TimeManagementPovider>(context, listen: false);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<ETMCategory> categories = ETMCategory.categories;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop<Object?>(),
          child: Icon(Platform.isIOS
              ? Icons.arrow_back_ios_new_outlined
              : Icons.arrow_back_outlined),
        ),
        title: Text(getLabels.home),
        centerTitle: true,
      ),
      body: !isGettingData
          ? SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                    vertical: MediaQuery.of(context).size.height * 0.015),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                        onPressed: () async {
                          // TrackingDB db = TrackingDB();
                          // final data = await db.readData(
                          //     sql: "select * from categories");
                          // print(data);

                          String sdkVersion =
                              await MobileAds.instance.getVersionString();
                          print("Google Mobile Ads SDK Version: $sdkVersion");
                          print(categoryProvider.selectedCategory);
                        },
                        child: Text("he")),
                    Text(
                      getLabels.welcome,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.03,
                          fontWeight: FontWeight.bold),
                    ),
                    Gap(MediaQuery.of(context).size.height * 0.01),
                    Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          "${getLabels.todayThe}, ${DateFormat(getLabels.dateFormat).format(DateTime.now())}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(MediaQuery.of(context).size.height * 0.03),
                        Text(
                          getLabels.chooseCategory,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02),
                        ),
                        Gap(MediaQuery.of(context).size.height * 0.02),
                        // DropdownMenu(
                        //   hintText: categoryHint.isEmpty &&
                        //           categoryProvider.selectedCategory.isEmpty
                        //       ? getLabels.selectCategory
                        //       : categoryProvider.selectedCategory.isEmpty
                        //           ? categoryHint["name"]
                        //           : categoryProvider.selectedCategory['name'],
                        //   expandedInsets: const EdgeInsets.all(5.0),
                        //   inputDecorationTheme: InputDecorationTheme(
                        //       border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(12.0))),
                        //   dropdownMenuEntries: getCategories!
                        //       .map(
                        //         (category) => DropdownMenuEntry(
                        //             enabled: isSwitchCategoryAvailable
                        //                 ? true
                        //                 : false,
                        //             label: category['name'],
                        //             value: category,
                        //             trailingIcon: Icon(
                        //               category["isAdsDisplayed"] == 1
                        //                   ? Icons.lock_open_outlined
                        //                   : Icons.lock_outline_rounded,
                        //               color: category["isAdsDisplayed"] == 1
                        //                   ? Constants.green
                        //                   : Constants.red,
                        //             )),
                        //       )
                        //       .toList(),
                        //   onSelected: (category) async {
                        //     await _showRewardedAd(category: category!);
                        //     await getAllData(
                        //         isSwitchCategory: true, category: category);
                        //     if (!mounted) return;
                        //   },
                        // ),
                        (timeManagementPovider.isInternetConnectedGet &&
                                    categoryProvider
                                        .isSwitchedToCloudCategories) ||
                                (!timeManagementPovider
                                            .isInternetConnectedGet &&
                                        categoryProvider
                                            .isSwitchedToLokalCategories ||
                                    !isUserExists)
                            ? DropdownButtonFormField2(
                                isExpanded: true,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0))),
                                dropdownStyleData: DropdownStyleData(
                                    useSafeArea: true,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.35),

                                hint: Text(categoryHint.isEmpty &&
                                        categoryProvider
                                            .selectedCategory.isEmpty
                                    ? getLabels.selectCategory
                                    : categoryHint.isEmpty
                                        ? categoryProvider
                                                .selectedCategory['name'][
                                            timeManagementPovider
                                                .getCurrentLocalSystemLanguage()]
                                        : categoryHint['name'][
                                            timeManagementPovider
                                                .getCurrentLocalSystemLanguage()]),
                                // value: categoryProvider.selectedCategory.isNotEmpty
                                //     ? categoryProvider.selectedCategory['id']
                                //     : categories.first.id,
                                items: _categoriesGet
                                    .map(
                                      (category) => DropdownMenuItem(
                                          enabled: isSwitchCategoryAvailable
                                              ? true
                                              : false,
                                          value: category["id"],
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(category["name"][
                                                  timeManagementPovider
                                                      .getCurrentLocalSystemLanguage()]),
                                              Gap(190),
                                              categoryProvider
                                                          .isSwitchedToLokalCategories ||
                                                      !isUserExists
                                                  ? Icon(
                                                      categoryProvider
                                                                  .lockedCategories
                                                                  .where((lockedCategory) =>
                                                                      lockedCategory[
                                                                          "id"] ==
                                                                      category[
                                                                          'id'])
                                                                  .isNotEmpty ||
                                                              category[
                                                                      "isUnlocked"] ==
                                                                  1
                                                          ? Icons
                                                              .lock_open_outlined
                                                          : Icons
                                                              .lock_outline_rounded,
                                                      color: categoryProvider
                                                                  .lockedCategories
                                                                  .where((lockedCategory) =>
                                                                      lockedCategory[
                                                                          "id"] ==
                                                                      category[
                                                                          "id"])
                                                                  .isNotEmpty ||
                                                              category[
                                                                      "isUnlocked"] ==
                                                                  1
                                                          ? Constants.green
                                                          : Constants.red,
                                                    )
                                                  : categoryProvider
                                                          .isSwitchedToCloudCategories
                                                      ? Icon(
                                                          categoryProvider
                                                                      .lockedCategories
                                                                      .where((lockedCategory) =>
                                                                          lockedCategory[
                                                                              "id"] ==
                                                                          category[
                                                                              'id'])
                                                                      .isNotEmpty ||
                                                                  category[
                                                                      "isUnlocked"]
                                                              ? Icons
                                                                  .lock_open_outlined
                                                              : Icons
                                                                  .lock_outline_rounded,
                                                          color: categoryProvider
                                                                      .lockedCategories
                                                                      .where((lockedCategory) =>
                                                                          lockedCategory[
                                                                              "id"] ==
                                                                          category[
                                                                              "id"])
                                                                      .isNotEmpty ||
                                                                  category[
                                                                      "isUnlocked"]
                                                              ? Constants.green
                                                              : Constants.red,
                                                        )
                                                      : Container(),
                                            ],
                                          )),
                                    )
                                    .toList(),
                                onChanged: (category) async {
                                  Map<String, dynamic>? categoryToMap;
                                  bool isUserLogedIn = await userProvider
                                      .isUserLogin(context: context);
                                  if (isUserLogedIn) {
                                    categoryToMap = ETMCategory.categories
                                        .firstWhere((categoryGet) =>
                                            categoryGet.id == category)
                                        .toMap(isLokal: false);
                                  } else {
                                    categoryToMap = ETMCategory.categories
                                        .firstWhere((categoryGet) =>
                                            categoryGet.id == category)
                                        .toMap(isLokal: true);
                                  }

                                  await _showRewardedAd(
                                      categorySet: categoryToMap);

                                  await getAllData(
                                      isSwitchCategory: true,
                                      categorySet: categoryToMap,
                                      isInit: false);
                                },
                              )
                            : (!categoryProvider.isSwitchedToCloudCategories &&
                                    !timeManagementPovider
                                        .isInternetConnectedGet)
                                ? Center(
                                    child: TextButton(
                                        onPressed: () async {
                                          categoryProvider
                                              .switchToLokalCategories = true;
                                          await getCategoriesFromProvider();
                                          categoryProvider
                                              .switchToCloudCategories = false;
                                        },
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          getLabels.switchToLocalCategories,
                                          style: TextStyle(fontSize: 16.0),
                                        )),
                                  )
                                : Center(
                                    child: TextButton(
                                        onPressed: () async {
                                          categoryProvider
                                              .switchToLokalCategories = false;
                                          await getCategoriesFromProvider();
                                          if (!mounted) return;
                                          categoryProvider
                                              .switchToCloudCategories = true;
                                        },
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          getLabels.switchToCloudCategories,
                                          style: TextStyle(fontSize: 16.0),
                                        ))),
                        // DropdownMenu(
                        //   hintText: categoryHint.isEmpty &&
                        //           categoryProvider.selectedCategory.isEmpty
                        //       ? getLabels.selectCategory
                        //       : categoryHint.isEmpty
                        //           ? categoryProvider.selectedCategory['name'][
                        //               timeManagementPovider
                        //                   .getCurrentLocalSystemLanguage()]
                        //           : categoryHint['name'][timeManagementPovider
                        //               .getCurrentLocalSystemLanguage()],
                        //   expandedInsets: const EdgeInsets.all(5.0),
                        //   menuStyle: MenuStyle(
                        //     maximumSize: WidgetStatePropertyAll(Size(
                        //         MediaQuery.of(context).size.width * 0.9,
                        //         MediaQuery.of(context).size.height * 0.35)),
                        //   ),
                        //   inputDecorationTheme: InputDecorationTheme(
                        //       border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(12.0))),
                        //   dropdownMenuEntries: _categories
                        //       .map(
                        //         (category) => DropdownMenuEntry(
                        //           enabled:
                        //               isSwitchCategoryAvailable ? true : false,
                        //           label: category.name[timeManagementPovider
                        //               .getCurrentLocalSystemLanguage()],
                        //           value: category.id,
                        //           trailingIcon: Icon(
                        //             categoryProvider.lockedCategories
                        //                         .where((lockedCategory) =>
                        //                             lockedCategory["id"] ==
                        //                             category.id)
                        //                         .isNotEmpty ||
                        //                     category.isUnlocked
                        //                 ? Icons.lock_open_outlined
                        //                 : Icons.lock_outline_rounded,
                        //             color: categoryProvider.lockedCategories
                        //                         .where((lockedCategory) =>
                        //                             lockedCategory["id"] ==
                        //                             category.id)
                        //                         .isNotEmpty ||
                        //                     category.isUnlocked
                        //                 ? Constants.green
                        //                 : Constants.red,
                        //           ),
                        //         ),
                        //       )
                        //       .toList(),
                        //   onSelected: (category) async {
                        //     print("hey");
                        //     print(category);
                        //     Map<String, dynamic> categoryToMap =
                        //         ETMCategory.categories
                        //             .firstWhere(
                        //               (categoryGet) =>
                        //                   categoryGet.id == category,
                        //             )
                        //             .toMap(isLokal: true);
                        //     print(categoryToMap);
                        //     // await _showRewardedAd(categorySet: category!);

                        //     // await getAllData(
                        //     //     isSwitchCategory: true,
                        //     //     categorySet: category,
                        //     //     isInit: false);
                        //     if (!mounted) return;
                        //   },
                        // ),

                        Gap(MediaQuery.of(context).size.height * 0.06),
                        Text(
                          getLabels.workTime,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02),
                        ),
                        Gap(MediaQuery.of(context).size.height * 0.02),
                        TrackSlider(
                            sliderValue: _sliderWorkValue,
                            inactiveColorl: _isStartWork
                                ? Theme.of(context).colorScheme.errorContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                            onChangeEnd: (value) {
                              setState(() {
                                _sliderWorkValue = 0;
                                isThumbStartTouchingText = false;
                                sliderForWorkingTime = _isStartWork
                                    ? getLabels.stopWork
                                    : getLabels.startWork;
                                isSmallLabel = false;
                              });
                            },
                            onChanged: (value) async {
                              if (value > 0.99) {
                                setState(() {
                                  isThumbStartTouchingText = true;
                                });
                              }
                              if (value >= 3.5) {
                                setState(() {
                                  isThumbStartTouchingText = false;
                                  sliderForWorkingTime = _isStartWork
                                      ? getLabels.theWorkWillFinishNow
                                      : getLabels.workWillStartNow;
                                  isSmallLabel = true;
                                });
                              }
                              setState(() {
                                _sliderWorkValue = value;
                              });
                              if (value >= 5.0) {
                                await startWork(
                                    timeManagementPovider:
                                        timeManagementPovider);
                                await getWorkTime(isSelectedCategory: false);
                                // if (!mounted) return;
                                // await readWork();
                              }
                            },
                            isThumbStartTouchingText: isThumbStartTouchingText,
                            sliderForWorkingTimeLabel: sliderForWorkingTime,
                            isSmallLabel: isSmallLabel),
                        Gap(MediaQuery.of(context).size.height * 0.02),
                        if (_isStartWork) ...{
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Task Description:",
                                    style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(3.0),
                                    iconSize: 25,
                                    constraints: BoxConstraints(
                                        maxHeight: 35, maxWidth: 35),
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Theme.of(context)
                                                .colorScheme
                                                .primaryContainer)),
                                    onPressed: () => timeManagementPovider
                                            .isInAddingTaskSet =
                                        !timeManagementPovider
                                            .isInAddingTaskGet,
                                    icon: Icon(
                                        !timeManagementPovider.isInAddingTaskGet
                                            ? Icons.add
                                            : Icons.clear_outlined),
                                    color: !timeManagementPovider
                                            .isInAddingTaskGet
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error,
                                  )
                                ],
                              )
                            ],
                          ),
                          if (timeManagementPovider.isInAddingTaskGet) ...{
                            Gap(MediaQuery.of(context).size.height * 0.02),
                            TextFieldFlexibel(
                              controller: _todoController,
                              hintText: "Describ your Task...",
                              maxLength: 300,
                              maxLines: 3,
                            ),
                          },
                        },
                        ListTile(
                          leading: Text(
                            getLabels.workStartedAt,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          title: Text(
                            workStartedTime ?? startWorkTimeInit,
                            style: const TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          leading: Text(
                            getLabels.workEndedAt,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          title: Text(
                            workEndedTime ?? finishWorkTimeInit,
                            style: const TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(MediaQuery.of(context).size.height * 0.06),
                        Text(
                          getLabels.breakTime,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02),
                        ),
                        Gap(MediaQuery.of(context).size.height * 0.02),
                        TrackSlider(
                            sliderValue: _sliderBreakValue,
                            inactiveColorl: _isBreak
                                ? Theme.of(context).colorScheme.errorContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                            onChangeEnd: (value) {
                              setState(() {
                                _sliderBreakValue = 0;
                                isThumbBreakStartTouchingText = false;
                                sliderForBreakTime = _isBreak
                                    ? getLabels.stopBreak
                                    : getLabels.startBreak;
                                isSmallBreakSliderLabel = false;
                              });
                            },
                            onChanged: (value) async {
                              if (value > 0.99) {
                                setState(() {
                                  isThumbBreakStartTouchingText = true;
                                });
                              }
                              if (value >= 3.5) {
                                setState(() {
                                  isThumbBreakStartTouchingText = false;

                                  sliderForBreakTime = _isBreak
                                      ? getLabels.theBreakWillEndNow
                                      : getLabels.theBreakWillStartNow;
                                  isSmallBreakSliderLabel = true;
                                });
                              }
                              setState(() {
                                _sliderBreakValue = value;
                              });
                              if (value >= 5.0) {
                                await takeOrFinishBreak();

                                // if (!mounted) return;
                                // await readBreaks();
                              }
                            },
                            isThumbStartTouchingText:
                                isThumbBreakStartTouchingText,
                            sliderForWorkingTimeLabel: sliderForBreakTime,
                            isSmallLabel: isSmallBreakSliderLabel)
                      ],
                    ),
                    Gap(MediaQuery.of(context).size.height * 0.02),
                    if (_isBreak) ...{
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Reason:",
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(3.0),
                                iconSize: 25,
                                constraints:
                                    BoxConstraints(maxHeight: 35, maxWidth: 35),
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Theme.of(context)
                                            .colorScheme
                                            .primaryContainer)),
                                onPressed: () => timeManagementPovider
                                        .isInAddingReasonSet =
                                    !timeManagementPovider.isInAddingReasonGet,
                                icon: Icon(
                                    !timeManagementPovider.isInAddingReasonGet
                                        ? Icons.add
                                        : Icons.clear_outlined),
                                color:
                                    !timeManagementPovider.isInAddingReasonGet
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error,
                              )
                            ],
                          )
                        ],
                      ),
                      if (timeManagementPovider.isInAddingReasonGet) ...{
                        Gap(MediaQuery.of(context).size.height * 0.02),
                        TextFieldFlexibel(
                          controller: _breakReasonController,
                          hintText: "Reason...",
                          maxLength: 50,
                          maxLines: 1,
                        ),
                      },
                      Gap(MediaQuery.of(context).size.height * 0.02),
                    },
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        getLabels.youWork(
                            workedTime,
                            workedTime <= 1
                                ? isInhours
                                    ? getLabels.hour
                                    : getLabels.minute
                                : isInhours
                                    ? getLabels.hours
                                    : getLabels.minutes),
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Gap(MediaQuery.of(context).size.height * 0.015),
                    ListTile(
                      leading: Text(
                        getLabels.numOfBreaks,
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        isInitFinished
                            ? numberOfBreaks <= 1
                                ? '$numberOfBreaks ${getLabels.breakLabel}'
                                : '$numberOfBreaks ${getLabels.breaks}'
                            : point,
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class TrackSlider extends StatelessWidget {
  final double sliderValue;
  final Color inactiveColorl;

  final Function(double)? onChangeEnd;
  final Function(double)? onChanged;
  final bool isThumbStartTouchingText;
  final String sliderForWorkingTimeLabel;
  final bool isSmallLabel;
  const TrackSlider(
      {super.key,
      required this.sliderValue,
      required this.inactiveColorl,
      required this.onChangeEnd,
      required this.onChanged,
      required this.isThumbStartTouchingText,
      required this.sliderForWorkingTimeLabel,
      required this.isSmallLabel});

  @override
  Widget build(BuildContext context) {
    // Extract MediaQuery data at the beginning of the build method
    final mediaQuery = MediaQuery.of(context);

    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.99,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: isPortrait
                      ? MediaQuery.of(context).size.aspectRatio * 73
                      : MediaQuery.of(context).size.aspectRatio * 20),
              trackHeight: MediaQuery.of(context).size.height * 0.08,
            ),
            child: Slider(
              activeColor: Theme.of(context).colorScheme.secondaryContainer,
              value: sliderValue,
              min: 0.0,
              max: 5.0,
              inactiveColor: inactiveColorl,
              thumbColor: Theme.of(context).colorScheme.onSurface,
              onChangeEnd: onChangeEnd,
              onChanged: onChanged,
            ),
          ),
        ),
        !isThumbStartTouchingText
            ? IgnorePointer(
                child: Text(
                  sliderForWorkingTimeLabel,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallLabel ? 12 : 20),
                ),
              )
            : Container(),
      ],
    );
  }
}
