import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart' as labels;
import 'package:permission_handler/permission_handler.dart';

class NotificationManager {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Function(NotificationResponse)? onTap;
  static Future<void> init() async {
    AndroidInitializationSettings android =
        const AndroidInitializationSettings("@style/LaunchTheme");
    InitializationSettings initializationSettings =
        InitializationSettings(android: android);
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: onTap,
        onDidReceiveNotificationResponse: onTap);
  }

  static void sendScheduleNotification({required BuildContext context}) async {
    final getLabels = labels.AppLocalizations.of(context);

    await flutterLocalNotificationsPlugin.show(
        1,
        getLabels?.yourScheduleAwaits ?? "Your schedule awaits",
        getLabels?.dontForgetTasks ?? "Don't forget your tasks",
        payload: "hey",
        const NotificationDetails(
            android: AndroidNotificationDetails("Id 1", "Basic notification",
                priority: Priority.max, importance: Importance.max)));
    debugPrint("hey");
  }
}
