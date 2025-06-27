import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../data/model/ReminderModel.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      print('NotificationService: Initializing...');

      // Khởi tạo timezone
      tz.initializeTimeZones();
      print('NotificationService: Timezone initialized');

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap-hdpi/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          print(
            'NotificationService: Notification clicked: ${response.payload}',
          );
        },
      );

      print('NotificationService: Initialization completed successfully');
    } catch (e) {
      print('NotificationService: Error during initialization: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      print('NotificationService: Requesting permissions...');

      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        final bool? granted =
            await androidImplementation?.requestNotificationsPermission();
        print('NotificationService: Permission granted: $granted');
        return granted ?? false;
      }
      return false;
    } catch (e) {
      print('NotificationService: Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> scheduleNotification(ReminderModel reminder) async {
    try {
      print(
        'NotificationService: Scheduling notification for reminder: ${reminder.id}',
      );
      print('NotificationService: Reminder time: ${reminder.dateTime}');
      print('NotificationService: Current time: ${DateTime.now()}');

      // Kiểm tra xem thời gian đã qua chưa
      if (reminder.dateTime.isBefore(DateTime.now())) {
        print('NotificationService: Warning - Reminder time is in the past');
        return;
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'reminder_channel_id',
            'Reminders',
            channelDescription: 'Channel for pet care reminders',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      // Xử lý lặp lại dựa trên repeatType
      DateTimeComponents? matchDateTimeComponents;
      switch (reminder.repeatType) {
        case 'Hàng ngày':
          matchDateTimeComponents = DateTimeComponents.time;
          break;
        case 'Hàng tuần':
          matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
          break;
        case 'Hàng tháng':
          matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
          break;
        case 'Hàng năm':
          matchDateTimeComponents = DateTimeComponents.dateAndTime;
          break;
        default:
          matchDateTimeComponents = null; // Không lặp lại
      }

      // Sử dụng timezone cụ thể cho Việt Nam (Asia/Ho_Chi_Minh)
      final vietnamLocation = tz.getLocation('Asia/Ho_Chi_Minh');
      final scheduledDate = tz.TZDateTime.from(
        reminder.dateTime,
        vietnamLocation,
      );

      print('NotificationService: Vietnam timezone: ${vietnamLocation.name}');
      print('NotificationService: Scheduled date (Vietnam): $scheduledDate');
      print(
        'NotificationService: Scheduled date (UTC): ${scheduledDate.toUtc()}',
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        reminder.id.hashCode,
        reminder.title,
        reminder.description ?? 'Bạn có lời nhắc cho ${reminder.type}',
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: reminder.id,
        matchDateTimeComponents: matchDateTimeComponents,
      );

      print('NotificationService: Notification scheduled successfully');

      // Kiểm tra xem notification có được lên lịch không
      final pendingNotifications =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print(
        'NotificationService: Total pending notifications: ${pendingNotifications.length}',
      );
    } catch (e) {
      print('NotificationService: Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      print('NotificationService: Cancelled notification with id: $id');
    } catch (e) {
      print('NotificationService: Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('NotificationService: Cancelled all notifications');
    } catch (e) {
      print('NotificationService: Error cancelling all notifications: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pendingNotifications =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print(
        'NotificationService: Found ${pendingNotifications.length} pending notifications',
      );
      return pendingNotifications;
    } catch (e) {
      print('NotificationService: Error getting pending notifications: $e');
      return [];
    }
  }
}
