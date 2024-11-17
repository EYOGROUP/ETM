import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:time_management/controller/notification.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class WorkManager {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    registerBackgroundTask();
  }

  static Future<void> registerBackgroundTask() async {
    Duration nextDelay = await calculateNextScheduledTime();
    await Workmanager().registerPeriodicTask(
      "Schudeled Notification",
      "Daily Notification",
      frequency: const Duration(minutes: 15),
      initialDelay: nextDelay,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 10),
    );
  }

  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      print("native called background Task: $task");
      await NotificationManager.sendScheduleNotification();
      return Future.value(true);
    });
  }

  static Future<Duration> calculateNextScheduledTime() async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    var currentTime = tz.TZDateTime.now(tz.local);
    var targetHour = 21; // Zum Beispiel 10:00 Uhr
    var targetMinute = 0; // Ganze Stunde

    // Erstellen des geplanten Zeitpunkts (z.B. 10:00 Uhr)
    var nextScheduledTime = tz.TZDateTime(
      tz.local,
      currentTime.year,
      currentTime.month,
      currentTime.day,
      targetHour,
      targetMinute,
    );
    // Falls der geplante Zeitpunkt bereits vergangen ist, verschiebe auf den nächsten Tag
    if (nextScheduledTime.isBefore(currentTime)) {
      nextScheduledTime = nextScheduledTime.add(const Duration(hours: 1));
    }
    print(nextScheduledTime);
    print(currentTime);
    print(nextScheduledTime.difference(currentTime));
    // Rückgabe der Zeitdifferenz bis zur nächsten Benachrichtigung
    return nextScheduledTime.difference(currentTime);
  }
}
