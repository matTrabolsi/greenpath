import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // INTIALIZE
  Future<void> initNotification() async {
    if(_isInitialized) return;



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
  Future<void> showNotification({
  int id = 0,
  String? title,
  String? body,
}) async {
  
  return notificationsPlugin.show(
    id,
    title,
    body,
    notificationDetails(), 
  );
}



  // ON NOTI TAP
  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    await notificationsPlugin.zonedSchedule(
      id,
      title, 
      body, 
      scheduledDate, 
      notificationDetails(), 

      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time,
      );
  }

  Future<void> cancelAllNotification() async{
    await notificationsPlugin.cancelAll();
  }



}