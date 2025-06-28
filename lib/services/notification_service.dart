import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../data/model/ReminderModel.dart';
import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      print('NotificationService: Initializing...');
      tz.initializeTimeZones();
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/img');

      const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) async {
          print(
            'NotificationService: Notification clicked: ${response.payload}',
          );
          if (response.payload != null) {
            try {
              final data = jsonDecode(response.payload!);
              final reminderId = data['id'] as String?;
              final repeatType = data['repeatType'] as String?;

              if (reminderId != null && repeatType == 'Không lặp lại') {
                // Xóa thông báo
                await _flutterLocalNotificationsPlugin.cancel(
                  reminderId.hashCode,
                );
                print(
                  'NotificationService: Cancelled one-time notification with id: $reminderId',
                );

                // Xóa nhắc nhở khỏi Supabase
                await deleteReminderFromDb(reminderId);
              }
            } catch (e) {
              print('NotificationService: Error processing notification response: $e');
            }
          }
        },
      );

      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
      >();

      await androidImplementation?.requestExactAlarmsPermission();
      print('NotificationService: Exact alarms permission requested');

      print('NotificationService: Initialization completed successfully');
    } catch (e) {
      print('NotificationService: Error during initialization: $e');
    }
  }

  static Future<void> deleteReminderFromDb(String reminderId) async {
    try {
      final client = Supabase.instance.client;
      await client.from('reminders').delete().eq('id', reminderId);
      print('NotificationService: Deleted reminder $reminderId from database');
    } catch (e) {
      print('NotificationService: Error deleting reminder from db: $e');
      throw e; // Ném lỗi để xử lý nếu cần
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

        final bool? granted = await androidImplementation
            ?.requestNotificationsPermission();
        print('NotificationService: Permission granted: $granted');
        return granted ?? false;
      }
      return false;
    } catch (e) {
      print('NotificationService: Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> scheduleNotification(
      ReminderModel reminder, {
        String? petName,
      }) async {
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

      final title = '${reminder.type} - ${petName ?? ''}';
      final body =
          '${reminder.title} cho thú cưng ${petName ?? ''} vào lúc '
          '${reminder.dateTime.hour.toString().padLeft(2, '0')}:${reminder.dateTime.minute.toString().padLeft(2, '0')} '
          'ngày ${reminder.dateTime.day}/${reminder.dateTime.month}/${reminder.dateTime.year}'
          '${reminder.description != null && reminder.description!.isNotEmpty ? '\n${reminder.description}' : ''}';

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        reminder.id.hashCode,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: jsonEncode({
          'id': reminder.id,
          'repeatType': reminder.repeatType,
        }),
        matchDateTimeComponents: matchDateTimeComponents,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
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
      final pendingNotifications = await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
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