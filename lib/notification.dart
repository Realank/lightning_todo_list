import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class _NotificationManager {
  var flutterLocalNotificationsPlugin;
  _NotificationManager() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings =
        new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future scheduleNotification(int id, String title, String body, DateTime when) async {
    print('add notification $title $body at $when');

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'todo noti', 'Todo Notification', 'the notification when todo item scheduled on time',
        importance: Importance.Max,
        priority: Priority.High,
        color: const Color.fromARGB(255, 255, 0, 0));
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics =
        new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(id, title, body, when, platformChannelSpecifics,
        payload: 't[$title]b[$body]w[$when]');
  }

  Future _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }
  }
}

final notificationManager = _NotificationManager();
