import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // INTIALIZE
  Future<void> initNotification() async {
    if(_isInitialized) return;

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // const initSettingsIOS = DarwinInitializationSettings(
    //   requestAlertPermission: true,
    //   requestBadgePermission: true,
    //   requestSoundPermission: true,
    // );
    

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      // iOS: initSettingsIOS,
    );

    await notificationsPlugin.initialize(initSettings);
  }

  
  // NOTIFICSTIONS DETAIL SETUP
  NotificationDetails notificationDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id', 
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        );
  }


  // SHOW NOTIFICATION
//   Future<void> showNotification({
//   int id = 0,
//   String? title,
//   String? body,
// }) async {
  
//   return notificationsPlugin.show(
//     id,
//     title,
//     body,
//     notificationDetails(), 
//   );
// }

tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

tz.TZDateTime nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var daysUntil = (weekday - now.weekday) % 7;
  if (daysUntil == 0 && (now.hour > hour || (now.hour == hour && now.minute >= minute))) {
    daysUntil = 7;
  }
  final nextDate = now.add(Duration(days: daysUntil));
  return tz.TZDateTime(tz.local, nextDate.year, nextDate.month, nextDate.day, hour, minute);
}

  // ON NOTI TAP
  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
    bool isDaily = true,
    List<int> repeatDays = const[],
  }) async {
     if (isDaily) {
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  } else {
    for (int weekday in repeatDays) {
      final scheduledDate = nextInstanceOfWeekdayTime(weekday, hour, minute);
      await notificationsPlugin.zonedSchedule(
        id + weekday, // unique ID per weekday
        title,
        body,
        scheduledDate,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }





}



}