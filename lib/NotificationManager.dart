import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'dart:ui' as ui;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  var flutterLocalNotificationsPlugin;
//  var location = tz.getLocation('Europe/Paris');

  NotificationManager() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    initNotifications();
  }

  getNotificationInstance() {
    return flutterLocalNotificationsPlugin;
  }

  void initNotifications() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    tz.initializeTimeZones();
//    tz.setLocalLocation(location);
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
    final tz.TZDateTime tzDateTime = new tz.TZDateTime.from(DateTime(now.year, now.month, now.day, hour, minute, 0), tz.getLocation(currentTimeZone));

    await flutterLocalNotificationsPlugin.zonedSchedule(0, title, body, tzDateTime, getPlatformChannelSpecfics(),
        androidAllowWhileIdle: true, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.time);
    print('Notification succesfully scheduled at $hour:$minute');
  }

  NotificationDetails getPlatformChannelSpecfics() {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('id', 'name', 'description', importance: Importance.max, priority: Priority.high, ticker: 'Cloclo\'s Reminder');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    return platformChannelSpecifics;
  }

  Future onSelectNotification(String payload) async {
    print('Notification clicked');
    return Future.value(0);
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    return Future.value(1);
  }

  void removeReminder(int notificationId) {
    flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}
