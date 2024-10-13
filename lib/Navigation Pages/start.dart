import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:slider_button/slider_button.dart';
import 'package:time_management/controller/architecture.dart';
import 'package:time_management/db/mydb.dart';

class StartTimePage extends StatefulWidget {
  const StartTimePage({super.key});

  @override
  State<StartTimePage> createState() => _StartTimePageState();
}

class _StartTimePageState extends State<StartTimePage> {
  bool _isStartWork = false;
  bool _finishWork = false;
  DateTime? workStartTime;
  DateTime? workFinishTime;
  Future<void> startWork() async {
    workStartTime = DateTime.now();
    TrackingDB db = TrackingDB();
    WorkSession workSession = WorkSession(
        startTime: workStartTime.toString(),
        endTime: DateTime.now().toString());
    //await db.deleteDB();
    await db.insertData(tableName: 'work_sessions', data: workSession.toMap());
    if (!mounted) return;
    setState(() {
      _isStartWork = true;
    });
  }

  completedWork() async {
    TrackingDB db = TrackingDB();
    workFinishTime = DateTime.now();
    List<Map<String, dynamic>> works = await db.readData(
        sql: 'select * from work_sessions') as List<Map<String, dynamic>>;

    for (Map<String, dynamic> work in works) {
      DateTime? startTimeToday = DateFormat('yyyy-MM-dd HH:mm:ss')
          .tryParse(work['startTime'])!
          .add(Duration(days: 0));

      bool isSameDate = areDatesSame(startTimeToday, DateTime.now());
      if (isSameDate) {
        print(startTimeToday);
      } else {
        print('not match');
      }
    }
  }

  readWork() async {
    TrackingDB db = TrackingDB();
    List<Map<String, dynamic>> works = await db.readData(
        sql: 'select * from work_sessions') as List<Map<String, dynamic>>;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Platform.isIOS
              ? Icons.arrow_back_ios_new_outlined
              : Icons.arrow_back_outlined),
        ),
        title: const Text('Start'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.06,
            vertical: MediaQuery.of(context).size.height * 0.015),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.topRight,
                child: Text(
                    "Today the, ${DateFormat('M/d/y').format(DateTime.now())}")),
            Text(
              'Welcome User !',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.03,
                  fontWeight: FontWeight.bold),
            ),
            TrackSlider(
                action: () async {
                  await startWork();
                  return false;
                },
                titleTracker: 'Working Time',
                isStart: _isStartWork,
                sliderLabel: _isStartWork
                    ? "Work started at: ${DateFormat('HH:mm:ss a').format(workStartTime!)}"
                    : 'Start work'),
            TrackSlider(
                action: () async {
                  await completedWork();
                  return false;
                },
                titleTracker: 'Break',
                sliderLabel: 'Start break'),
          ],
        ),
      ),
    );
  }
}

class TrackSlider extends StatelessWidget {
  final Future<bool?> Function() action;
  final String titleTracker;
  final String sliderLabel;
  bool? isStart;
  TrackSlider(
      {super.key,
      required this.action,
      required this.titleTracker,
      required this.sliderLabel,
      this.isStart});

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
          shimmer: true,
          highlightedColor: Theme.of(context).colorScheme.primary,
          baseColor: Theme.of(context).colorScheme.onSurface,
          label: Text(
            sliderLabel,
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
                fontSize: isStart != null ? 12 : 17),
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
