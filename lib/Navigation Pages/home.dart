import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:slider_button/slider_button.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/controller/architecture.dart';
import 'package:time_management/db/mydb.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StartTimePage extends StatefulWidget {
  const StartTimePage({super.key});

  @override
  State<StartTimePage> createState() => _StartTimePageState();
}

class _StartTimePageState extends State<StartTimePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isStartWork = false;
  bool _finishWork = false;
  double _workHours = 0;

  DateTime? workStartTime;
  DateTime? workFinishTime;
  bool isInitFinished = false;
  int numberOfBreaks = 0;
  Timer? _timer; // Timer for periodic updates
  bool _isDisposed = false;
  String point = '';
  double _sliderWorkValue = 0.0;
  bool _isWorking = false;
  bool isThumbStartTouchingText = false;
  String sliderForWorkingTime = '';
  bool isSmallLabel = false;

// variable for Break
  String sliderForBreakTime = "";
  bool _isBreak = false;
  bool isSmallBreakSliderLabel = false;
  double _sliderBreakValue = 0.0;
  bool isThumbBreakStartTouchingText = false;

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

    print(isAlreadStartedWork);
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
                'select * from work_sessions where isCompleted=0 OR isCompleted =1 and substr(startTime,1,10) ="$dateToday"')
        as List<Map<String, dynamic>>;
    if (workSession.isNotEmpty) {
      return true;
    } else {
      return false;
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
    TrackingDB db = TrackingDB();
    workFinishTime = DateTime.now();
    Map<String, dynamic> workDay = await getDataSameDateLikeToday();
    if (!mounted) return;
    // check if not completed and endTime not filled
    if (workDay['isCompleted'] == 0 && workDay['endTime'] == '') {
      Map<String, dynamic> updateData = {
        'endTime': workFinishTime.toString(),
        'isCompleted': 1
      };
      await db.updateData(
          tableName: 'work_sessions',
          data: updateData,
          columnId: 'id',
          id: workDay['id']);
      if (!mounted) return;
      setState(() {
        _finishWork = true;
      });
    } else {
      if (!mounted) return;
      Constants.showInSnackBar(
          value: 'You work is already finished', context: context);
    }
  }

  readWork() async {
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> works = await db.readData(
        sql: "select * from work_sessions ") as List<Map<String, dynamic>>;
    print(works);
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
    bool isAlreadyClosedBreak = false;
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> breakSessions = await db.readData(
            sql:
                "select * from break_sessions where workSessionId =${getDayWorkData['id']} and breakEndTime <>''")
        as List<Map<String, dynamic>>;
    if (context.mounted) {
      if (breakSessions.isNotEmpty) {
        isAlreadyClosedBreak = true;
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
    DateTime breakTime = DateTime.now();
    Map<String, dynamic> getWorkDayData = await getDataSameDateLikeToday();
    if (!mounted) return;
    if (getWorkDayData.isNotEmpty) {
      bool isWorkAlreadyStarted = await isAlreadyStartedWorkDay();
      if (!mounted) return;
      if (isWorkAlreadyStarted) {
        print('is Started work');
        bool isFinishedWork =
            await isFinishedWorkForToday(getWorkDayData: getWorkDayData);
        if (!mounted) return;
        if (isFinishedWork) {
          return Constants.showInSnackBar(
              value:
                  'You finished your work, no Break more available for you work today!',
              context: context);
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
          }
        }
      }

      print(
          "is Break tooken ${await isBreakTooken(getWorkDayData: getWorkDayData)}");
      print(
          "is break already Closed: ${await isAlreadyClosedBreak(getDayWorkData: getWorkDayData)}");
      debugPrint('okey Take break');
    }
  }

  readBreaks() async {
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> works = await db.readData(
        sql: "select * from break_sessions ") as List<Map<String, dynamic>>;
    print(works);
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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        sliderForWorkingTime = AppLocalizations.of(context)!.startWork;
        sliderForBreakTime = AppLocalizations.of(context)!.startBreak;
        await getNumberOfBreaks();
        stopLoadingAnimation();
      },
    );
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
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.015),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.topRight,
                child: Text(
                    "${getLabels.todayThe}, ${DateFormat(getLabels.dateFormat).format(DateTime.now())}")),
            Text(
              getLabels.welcome,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.03,
                  fontWeight: FontWeight.bold),
            ),
            // TrackSlider(
            //     action: () async {
            //       await startWork();
            //       return false;
            //     },
            //     titleTracker: 'Working Time',
            //     isStart: _isStartWork || _finishWork,
            //     sliderLabel: _isStartWork && !_finishWork
            //         ? "Work started at: ${DateFormat('HH:mm:ss a').format(workStartTime!)}"
            //         : _finishWork
            //             ? "Work finished at: ${DateFormat('HH:mm:ss a').format(workFinishTime!)}"
            //             : 'Start work'),
            /* Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(MediaQuery.of(context).size.height * 0.06),
                Text(
                  'Working Time',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height * 0.02),
                ),
                Gap(MediaQuery.of(context).size.height * 0.02),
                /*   Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.99,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius:
                                  MediaQuery.of(context).size.aspectRatio * 73),
                          trackHeight:
                              MediaQuery.of(context).size.height * 0.08,
                        ),
                        child: Slider(
                          activeColor: Theme.of(context).colorScheme.primary,
                          value: _sliderValue,
                          min: 0.0,
                          max: 5.0,
                          inactiveColor: _isWorking ? Colors.red : Colors.green,
                          thumbColor: Theme.of(context).colorScheme.primary,
                          onChangeStart: (value) => print(value),
                          onChangeEnd: (value) {
                            setState(() {
                              _sliderValue = 0;
                              isThumbStartTouchingText = false;
                              sliderForWorkingTime = 'Start work!';
                              isLabelSmall = false;
                            });
                          },
                          onChanged: (value) {
                            print(value);
                            if (value > 0.99) {
                              setState(() {
                                isThumbStartTouchingText = true;
                              });
                            }
                            if (value >= 4.0) {
                              setState(() {
                                isThumbStartTouchingText = false;
                                sliderForWorkingTime = 'Work will start now!';
                                isLabelSmall = true;
                              });
                            }
                            setState(() {
                              _sliderValue = value;
                            });
                            if (value == 5.0) {
                              // If slider reaches max, toggle between start and end work
                              if (!_isWorking) {
                                setState(() {
                                  _isWorking = true;
                                  print(_isWorking);
                                });
                              } else {
                                setState(() {
                                  _isWorking = false;
                                });
                              }
                              setState(() {
                                _sliderValue = 0;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    !isThumbStartTouchingText
                        ? IgnorePointer(
                            child: Text(
                              sliderForWorkingTime,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontWeight: FontWeight.w500,
                                  fontSize: isLabelSmall ? 12 : 20),
                            ),
                          )
                        : Container(),
                  ],
                ),
               */
              ],
            ),*/
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
                    inactiveColorl: _isWorking
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.inversePrimary,
                    onChangeStart: (value) => print(value),
                    onChangeEnd: (value) {
                      setState(() {
                        _sliderWorkValue = 0;
                        isThumbStartTouchingText = false;
                        sliderForWorkingTime = _isWorking
                            ? getLabels.stopWork
                            : getLabels.startWork;
                        isSmallLabel = false;
                      });
                    },
                    onChanged: (value) {
                      print(value);
                      if (value > 0.99) {
                        setState(() {
                          isThumbStartTouchingText = true;
                        });
                      }
                      if (value >= 3.5) {
                        setState(() {
                          isThumbStartTouchingText = false;
                          sliderForWorkingTime = _isWorking
                              ? getLabels.theWorkWillFinishNow
                              : getLabels.workWillStartNow;
                          isSmallLabel = true;
                        });
                      }
                      setState(() {
                        _sliderWorkValue = value;
                      });
                      if (value == 5.0) {
                        // If slider reaches max, toggle between start and end work
                        if (!_isWorking) {
                          setState(() {
                            _isWorking = true;
                            print(_isWorking);
                          });
                        } else {
                          setState(() {
                            _isWorking = false;
                          });
                        }
                        setState(() {
                          _sliderWorkValue = 0;
                        });
                      }
                    },
                    isThumbStartTouchingText: isThumbStartTouchingText,
                    sliderForWorkingTimeLabel: sliderForWorkingTime,
                    isSmallLabel: isSmallLabel)
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
                    onChangeStart: (value) => print(value),
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
                    onChanged: (value) {
                      print(value);
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
                      if (value == 5.0) {
                        // If slider reaches max, toggle between start and end work
                        if (!_isBreak) {
                          setState(() {
                            _isBreak = true;
                            print(_isBreak);
                          });
                        } else {
                          setState(() {
                            _isBreak = false;
                          });
                        }
                        setState(() {
                          _sliderBreakValue = 0;
                        });
                      }
                    },
                    isThumbStartTouchingText: isThumbBreakStartTouchingText,
                    sliderForWorkingTimeLabel: sliderForBreakTime,
                    isSmallLabel: isSmallBreakSliderLabel)
              ],
            ),

            TrackSliderOld(
                action: () async {
                  await readBreaks();
                  await takeOrFinishBreak();
                  await readWork();
                  return false;
                },
                titleTracker: 'Break',
                sliderLabel: 'Start break'),
            Gap(MediaQuery.of(context).size.height * 0.04),
            ListTile(
              leading: Text(
                getLabels.numOfBreaks,
                style: const TextStyle(fontSize: 16.0),
              ),
              trailing: Text(
                isInitFinished
                    ? numberOfBreaks <= 1
                        ? '$numberOfBreaks ${getLabels.breakLabel}'
                        : '$numberOfBreaks ${getLabels.breaks}'
                    : point,
                style: const TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackSliderOld extends StatelessWidget {
  final Future<bool?> Function() action;
  final String titleTracker;
  final String sliderLabel;
  final bool isStart;
  const TrackSliderOld(
      {super.key,
      required this.action,
      required this.titleTracker,
      required this.sliderLabel,
      this.isStart = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(MediaQuery.of(context).size.height * 0.06),
        Text(
          titleTracker,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height * 0.02),
        ),
        Gap(MediaQuery.of(context).size.height * 0.02),
        SliderButton(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          action: action,
          vibrationFlag: true,
          width: MediaQuery.of(context).size.width * 0.9,
          alignLabel: Alignment.center,
          buttonColor: Theme.of(context).colorScheme.primary,
          highlightedColor: Theme.of(context).colorScheme.primary,
          baseColor: Theme.of(context).colorScheme.onSurface,
          label: Text(
            sliderLabel,
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
                fontSize: isStart ? 12 : 17),
          ),
          icon: Icon(
            Icons.arrow_circle_right_outlined,
            size: MediaQuery.of(context).size.height * 0.07,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ],
    );
  }
}

class TrackSlider extends StatelessWidget {
  final double sliderValue;
  final Color inactiveColorl;
  final Function(double)? onChangeStart;
  final Function(double)? onChangeEnd;
  final Function(double)? onChanged;
  final bool isThumbStartTouchingText;
  final String sliderForWorkingTimeLabel;
  final bool isSmallLabel;
  const TrackSlider(
      {super.key,
      required this.sliderValue,
      required this.inactiveColorl,
      required this.onChangeStart,
      required this.onChangeEnd,
      required this.onChanged,
      required this.isThumbStartTouchingText,
      required this.sliderForWorkingTimeLabel,
      required this.isSmallLabel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.99,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius:
                      MediaQuery.of(context).size.aspectRatio * 73),
              trackHeight: MediaQuery.of(context).size.height * 0.08,
            ),
            child: Slider(
              activeColor: Theme.of(context).colorScheme.tertiaryContainer,
              value: sliderValue,
              min: 0.0,
              max: 5.0,
              inactiveColor: inactiveColorl,
              thumbColor: Theme.of(context).colorScheme.onSurface,
              onChangeStart: onChangeStart,
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
