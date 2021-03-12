import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  var flutterLocalNotificationsPlugin;
  var notificationClickCallback;

  NotificationManager() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    initNotifications();
  }

  getNotificationInstance() {
    return flutterLocalNotificationsPlugin;
  }

  void initNotifications() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    tz.initializeTimeZones();
  }

  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    return flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  void showNotification(int id, String title, String body) async {
    await flutterLocalNotificationsPlugin.show(id, title, body, getPlatformChannelSpecfics(), payload: 'none');
  }

  void showNotificationDaily(int id, String title, String body, int hour, int minute) async {
    final DateTime now = DateTime.now();
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    DateTime nextAlert;
    if (hour >= now.hour && minute >= now.minute) {
      nextAlert = DateTime(now.year, now.month, now.day, hour, minute, 0);
    } else {
      nextAlert = DateTime(now.year, now.month, now.day + 1, hour, minute, 0);
    }
    final tz.TZDateTime tzDateTime = new tz.TZDateTime.from(nextAlert, tz.getLocation(currentTimeZone));

    await flutterLocalNotificationsPlugin.zonedSchedule(id, title, body, tzDateTime, getPlatformChannelSpecfics(),
        androidAllowWhileIdle: true, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.time);
    print('Notification succesfully scheduled at $hour:$minute');
  }

  void scheduleDailyNotification(int id, String title, String body, int hour, int minute) {
    Duration duration = new Duration(days: 1);
    const int alarmId = 0;
    DateTime nextAlert;
    final DateTime now = DateTime.now();
    if (hour >= now.hour && minute >= now.minute) {
      nextAlert = DateTime(now.year, now.month, now.day, hour, minute, 0);
    } else {
      nextAlert = DateTime(now.year, now.month, now.day + 1, hour, minute, 0);
    }
    AndroidAlarmManager.oneShotAt(nextAlert, alarmId + 1, () => AndroidAlarmManager.periodic(duration, alarmId, () => showNotification(id, title, body)));
  }

  NotificationDetails getPlatformChannelSpecfics() {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('pillReminderID', 'Reminder notifications', 'Pill Reminder notifications',
        importance: Importance.max, priority: Priority.high, ticker: 'Cloclo\'s Reminder', icon: 'app_icon');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    return platformChannelSpecifics;
  }

  Future onSelectNotification(String payload) async {
    if (notificationClickCallback != null) {
      notificationClickCallback();
    }
    return Future.value(0);
  }

  void registerNotificationCallback(Function callback) {
    notificationClickCallback = callback;
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    print('notification received');
    return Future.value(1);
  }

  void removeReminder(int notificationId) {
    flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}
