import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart' as labels;

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_management/Navigation%20Pages/home.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationManager {
  static late BuildContext mainContext;

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    AndroidInitializationSettings android =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    InitializationSettings initializationSettings =
        InitializationSettings(android: android);
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
    bool? isNotificationEnabled = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await prefs.setBool("isNotificationEnabled", isNotificationEnabled!);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: handleBackgroundNotification,
      onDidReceiveNotificationResponse: handleBackgroundNotification,
    );
  }

  static void handleBackgroundNotification(NotificationResponse response) {
    // Hier kannst du z. B. das Payload überprüfen
    debugPrint("Background notification payload: ${response.payload}");
    // Weitere Aktionen basierend auf dem Payload
  }

  static navigate() {
    Navigator.of(mainContext).push(MaterialPageRoute(
      builder: (mainContext) => const StartTimePage(),
    ));
  }

  static void onNotificationTap(
    NotificationResponse notificationResponse,
  ) {
    debugPrint(
        'Notification tapped with payload: ${notificationResponse.payload}');
    navigate();
  }

  static Future<void> sendScheduleNotification() async {
    Locale deviceLocale = WidgetsBinding
        .instance.platformDispatcher.locale; // or html.window.locale

    labels.AppLocalizations getLabels =
        await labels.AppLocalizations.delegate.load(deviceLocale);

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? isNotificationEnabled = prefs.getBool("isNotificationEnabled");

    if (isNotificationEnabled!) {
      NotificationDetails notificationDetails = const NotificationDetails(
          android: AndroidNotificationDetails("Id 1", "Schedule notification",
              icon: "@mipmap/ic_launcher",
              channelShowBadge: true,
              playSound: true,
              priority: Priority.max,
              importance: Importance.max));
      tz.initializeTimeZones();

      final String currenTimeZone = await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(tz.getLocation(currenTimeZone));

      var currentTime = tz.TZDateTime.now(tz.local);
      var targetHour = 21; // Zum Beispiel 10:00 Uhr
      var targetMinute = 0; // Ganze Stunde
      var timeToSendNotification = tz.TZDateTime.now(tz.local);
      // Erstellen des geplanten Zeitpunkts (z.B. 10:00 Uhr)
      var nextScheduledTime = tz.TZDateTime(
        tz.local,
        currentTime.year,
        currentTime.month,
        currentTime.day,
        targetHour,
        targetMinute,
      );
      timeToSendNotification = nextScheduledTime;
      // Falls der geplante Zeitpunkt bereits vergangen ist, verschiebe auf den nächsten Tag
      if (timeToSendNotification.isBefore(currentTime)) {
        timeToSendNotification =
            timeToSendNotification.add(const Duration(hours: 1));
      } else {
        timeToSendNotification = currentTime;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        getLabels.yourScheduleAwaits,
        getLabels.dontForgetTasks,
        timeToSendNotification,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
