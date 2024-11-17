import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:time_management/controller/notification.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(WorkManager());
}

void myTask() {
  // Code to execute during the foreground task
  print("Foreground task is running...");

  // Sending a notification
}

class WorkManager extends TaskHandler {
  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('onStart(starter: ${starter.name})');
  }

  // Called by eventAction in [ForegroundTaskOptions].
  // - nothing() : Not use onRepeatEvent callback.
  // - once() : Call onRepeatEvent only once.
  // - repeat(interval) : Call onRepeatEvent at milliseconds interval.
  @override
  void onRepeatEvent(DateTime timestamp) {
    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToTask(data);
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('onDestroy');
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }
}

class SS {
  // static Future<void> init() async {
  //   await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  //   registerBackgroundTask();
  // }

  // static Future<void> registerBackgroundTask() async {
  //   Duration nextDelay = await calculateNextScheduledTime();
  //   await Workmanager().registerPeriodicTask(
  //     "Schudeled Notification",
  //     "Daily Notification",
  //     frequency: const Duration(minutes: 15),
  //     // initialDelay: nextDelay,
  //     // backoffPolicy: BackoffPolicy.linear,
  //     // backoffPolicyDelay: const Duration(minutes: 10),
  //   );
  // }
  static void init() {}

  // Implement the process you want to run in the background.
  // ex) Check health data.
}

  // @pragma('vm:entry-point')
  // static void callbackDispatcher() {
  //   Workmanager().executeTask((task, inputData) async {
  //     print("native called background Task: $task");
  //     await NotificationManager.sendScheduleNotification();
  //     return Future.value(true);
  //   });
  // }

  // static Future<Duration> calculateNextScheduledTime() async {
  //   tz.initializeTimeZones();
  //   final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  //   tz.setLocalLocation(tz.getLocation(currentTimeZone));

  //   var currentTime = tz.TZDateTime.now(tz.local);
  //   var targetHour = 2; // Zum Beispiel 10:00 Uhr
  //   var targetMinute = 5; // Ganze Stunde

  //   // Erstellen des geplanten Zeitpunkts (z.B. 10:00 Uhr)
  //   var nextScheduledTime = tz.TZDateTime(
  //     tz.local,
  //     currentTime.year,
  //     currentTime.month,
  //     currentTime.day,
  //     targetHour,
  //     targetMinute,
  //   );
  //   // Falls der geplante Zeitpunkt bereits vergangen ist, verschiebe auf den nächsten Tag
  //   if (nextScheduledTime.isBefore(currentTime)) {
  //     nextScheduledTime = nextScheduledTime.add(const Duration(hours: 1));
  //   }
  //   print(nextScheduledTime);
  //   print(currentTime);
  //   print(nextScheduledTime.difference(currentTime));
  //   // Rückgabe der Zeitdifferenz bis zur nächsten Benachrichtigung
  //   return nextScheduledTime.difference(currentTime);
  // }

