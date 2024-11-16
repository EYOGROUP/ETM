import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart' as labels;

import 'package:permission_handler/permission_handler.dart';
import 'package:time_management/Navigation%20Pages/home.dart';

class NotificationManager {
  static late BuildContext mainContext;

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    AndroidInitializationSettings android =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    InitializationSettings initializationSettings =
        InitializationSettings(android: android);
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
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

  static void sendScheduleNotification({required BuildContext context}) async {
    final getLabels = labels.AppLocalizations.of(context);
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    bool? isNotificationEnabled = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin.show(
        1,
        getLabels?.yourScheduleAwaits ?? "Your schedule awaits",
        getLabels?.dontForgetTasks ?? "Don't forget your tasks",
        payload: "hey",
        const NotificationDetails(
            android: AndroidNotificationDetails("Id 1", "Basic notification",
                icon: "@mipmap/ic_launcher",
                channelShowBadge: true,
                largeIcon:
                    FilePathAndroidBitmap("assets/images/logo/production.png"),
                playSound: true,
                priority: Priority.max,
                importance: Importance.max)));
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }
}
