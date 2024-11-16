import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/architecture.dart';
import 'package:time_management/controller/notification.dart';
import 'package:time_management/db/mydb.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/provider/tm_provider.dart';

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        sliderForWorkingTime = AppLocalizations.of(context)!.startWork;
        sliderForBreakTime = AppLocalizations.of(context)!.startBreak;
        await getNumberOfBreaks();
        await getHoursOrMinutesWorkedForToday();
        await checkIfWorkAndBreakForTodayNotFinished();
        await getWorkTime();
        if (!mounted) return;
        final tm = Provider.of<TimeManagementPovider>(context, listen: false);
        tm.setOrientation(context);
        stopLoadingAnimation();
      },
    );
  }

  Future<void> startWork() async {
    bool isAlreadStartedWork = await isAlreadyStartedWorkDay();
    if (!mounted) return;

    if (isAlreadStartedWork) {
      await completedWork();
      return;
    }

    workStartTime = DateTime.now();
    TrackingDB db = TrackingDB();

    WorkSession workSession =
        WorkSession(startTime: workStartTime.toString(), endTime: '');
    // await db.deleteDB();
    await db.insertData(tableName: 'work_sessions', data: workSession.toMap());
    // Constants.showInSnackBar(value: 'Test', context: context);

    if (!mounted) return;
    setState(() {
      _isStartWork = true;
    });
  }

  Future<bool> isAlreadyStartedWorkDay() async {
    TrackingDB db = TrackingDB();
    String dateToday = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<Map<String, dynamic>> workSession = await db.readData(
            sql:
                'select * from work_sessions where (isCompleted=0 and substr(startTime,1,10) ="$dateToday") OR (isCompleted =1 and substr(startTime,1,10) ="$dateToday")')
        as List<Map<String, dynamic>>;

    if (workSession.isNotEmpty) {
      return true;
    } else {
      return false;
    }
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

  Future<Map<String, dynamic>> getDataSameDateLikeToday() async {
    Map<String, dynamic> workDay = {};
    TrackingDB db = TrackingDB();
    workFinishTime = DateTime.now();
    List<Map<String, dynamic>> works = await db.readData(
        sql: 'select * from work_sessions') as List<Map<String, dynamic>>;

    for (Map<String, dynamic> work in works) {
      DateTime? startTimeToday =
          DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(work['startTime'])!;

// check if data date same like today
      bool isSameDate = areDatesSame(startTimeToday, DateTime.now());
      if (isSameDate) {
        workDay = work;
      }
    }
    return workDay;
  }

  completedWork() async {
    final getLabels = AppLocalizations.of(context)!;
    final tM = Provider.of<TimeManagementPovider>(context, listen: false);
    TrackingDB db = TrackingDB();
    workFinishTime = DateTime.now();
    Map<String, dynamic> workDay = await getDataSameDateLikeToday();
    if (!mounted) return;
    // check if not completed and endTime not filled
    if (workDay.isEmpty) {
      return;
    }
    // if Work day not finished
    if (workDay['isCompleted'] == 0 && workDay['endTime'] == '') {
      Map<String, dynamic> updateData = {
        'endTime': workFinishTime.toString(),
        'isCompleted': 1
      };
      //check if all breaks closed
      bool isAllBreaksClosed = await tM.isAllBreaksClosed(workDay: workDay);
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
      await getHoursOrMinutesWorkedForToday();
      if (!mounted) return;
      setState(() {
        _isStartWork = false;
      });
    } else {
      if (!mounted) return;
      Constants.showInSnackBar(
          value: getLabels.workFinishedForToday, context: context);
    }
  }

  getHoursOrMinutesWorkedForToday() async {
    Map<String, dynamic> workDay = await getDataSameDateLikeToday();
    if (workDay.isEmpty || workDay['isCompleted'] == 0) {
      return;
    }

    startLoadingAnimation();

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
                "select * from break_sessions where workSessionId =${getDayWorkData['id']} and breakEndTime =''")
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
                "select * from break_sessions where workSessionId =${getWorkDayData['id']} ")
        as List<Map<String, dynamic>>;
    if (breakSessions.isNotEmpty) {
      isBreakTooken = true;
    }
    return isBreakTooken;
  }

  Future<bool> isFinishedWorkForToday(
      {required Map<String, dynamic> getWorkDayData}) async {
    bool isFinishedWorkForToday = false;
    if (getWorkDayData['endTimeendTime'] != '' &&
        getWorkDayData['isCompleted'] == 1) {
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
                "select * from break_sessions where workSessionId =${getDayWorkData['id']} and breakEndTime =''")
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
    DateTime breakTime = DateTime.now();
    Map<String, dynamic> getWorkDayData = await getDataSameDateLikeToday();
    if (!mounted) return;
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
          bool isBreakTookenCheck =
              await isBreakTooken(getWorkDayData: getWorkDayData);
          if (!mounted) return;
          bool isAlreadyClosedBreakCheck =
              await isAlreadyClosedBreak(getDayWorkData: getWorkDayData);

          if (!mounted) return;
          if (!isBreakTookenCheck || isAlreadyClosedBreakCheck) {
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
              'breakEndTime': breakTime.toString(),
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
        }
      }
    } else {
      Constants.showInSnackBar(
          value: getLabels.startYourWorkBeforeBreak, context: context);
    }
  }

  Future<void> insertNewBreak(
      {required Map<String, dynamic> getWorkDayData,
      required DateTime breakTime}) async {
    TrackingDB db = TrackingDB();
    BreakSession breakSession = BreakSession(
        workSessionId: getWorkDayData['id'],
        breakStartTime: breakTime.toString(),
        breakEndTime: '');
    await db.insertData(
        tableName: 'break_sessions', data: breakSession.toMap());
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel(); // Cancel the timer if it's running
    super.dispose();
  }

  Future<void> getNumberOfBreaks() async {
    numberOfBreaks = 0;
    TrackingDB db = TrackingDB();
    startLoadingAnimation();
    Map<String, dynamic> getWorkDay = await getDataSameDateLikeToday();
    try {
      if (getWorkDay['id'] != null) {
        List<Map<String, dynamic>> breakSessions = await db.readData(
                sql:
                    "select * from break_sessions where workSessionId = ${getWorkDay['id']} and breakEndTime <> ''")
            as List<Map<String, dynamic>>;
        if (mounted && !_isDisposed) {
          setState(() {
            numberOfBreaks = breakSessions.length;
            isInitFinished = true;
            _isDisposed = true;
          });
          startLoadingAnimation(); // End the loading animation
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

  Future<void> getWorkTime() async {
    bool isAlreadyStarted = await isAlreadyStartedWorkDay();
    if (mounted) {
      if (isAlreadyStarted) {
        Map<String, dynamic> getWorkDay = await getDataSameDateLikeToday();
        if (mounted) {
          DateTime? startWork =
              DateFormat('yyyy-MM-dd hh:mm').tryParse(getWorkDay['startTime']);
          String? formatStartTime = DateFormat('HH:mm').format(startWork!);
          setState(() {
            workStartedTime = formatStartTime;
          });
          if (getWorkDay['isCompleted'] == 1) {
            DateTime? endWork =
                DateFormat('yyyy-MM-dd HH:mm').tryParse(getWorkDay['endTime']);
            String? formatEndTime = DateFormat('HH:mm').format(endWork!);
            setState(() {
              workEndedTime = formatEndTime;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: MediaQuery.of(context).size.height * 0.015),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                  onPressed: () {
                    NotificationManager.sendScheduleNotification(
                        context: context);
                  },
                  child: Text("here")),
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
                  Gap(MediaQuery.of(context).size.height * 0.06),
                  Text(
                    getLabels.workTime,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height * 0.02),
                  ),
                  Gap(MediaQuery.of(context).size.height * 0.02),
                  TrackSlider(
                      sliderValue: _sliderWorkValue,
                      inactiveColorl: _isStartWork
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.inversePrimary,
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
                          await startWork();
                          await getWorkTime();
                          // if (!mounted) return;
                          // await readWork();
                        }
                      },
                      isThumbStartTouchingText: isThumbStartTouchingText,
                      sliderForWorkingTimeLabel: sliderForWorkingTime,
                      isSmallLabel: isSmallLabel),
                  Gap(MediaQuery.of(context).size.height * 0.02),
                  ListTile(
                    leading: Text(
                      getLabels.workStartedAt,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    title: Text(
                      workStartedTime ?? '-',
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
                      workEndedTime ?? '-',
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
                        fontSize: MediaQuery.of(context).size.height * 0.02),
                  ),
                  Gap(MediaQuery.of(context).size.height * 0.02),
                  TrackSlider(
                      sliderValue: _sliderBreakValue,
                      inactiveColorl: _isBreak
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.inversePrimary,
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
                      isThumbStartTouchingText: isThumbBreakStartTouchingText,
                      sliderForWorkingTimeLabel: sliderForBreakTime,
                      isSmallLabel: isSmallBreakSliderLabel)
                ],
              ),
              Gap(MediaQuery.of(context).size.height * 0.04),
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
              activeColor: Theme.of(context).colorScheme.tertiaryContainer,
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
                      color: Theme.of(context).colorScheme.inverseSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallLabel ? 12 : 20),
                ),
              )
            : Container(),
      ],
    );
  }
}
