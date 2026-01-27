import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/pill_reminder.dart';

class ReminderService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification plugin and timezone
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Timezones
      tz.initializeTimeZones();
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        final String timeZoneName = timeZoneInfo.identifier;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint('Failed to get local timezone: $e');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      // 2. Platform Initialization Settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
          );

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      // 3. Initialize Plugin
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (
          NotificationResponse response,
        ) async {
          debugPrint('Notification tapped: ${response.payload}');
        },
      );

      // 4. Request Permissions (Android 13+)
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _notificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidImplementation != null) {
          await androidImplementation.requestNotificationsPermission();
        }
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing ReminderService: $e');
    }
  }

  /// Schedule a daily reminder
  Future<void> scheduleReminder(PillReminder reminder) async {
    if (!reminder.isActive) return;

    try {
      // Prepare notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'pill_reminders_channel',
            'Pill Reminders',
            channelDescription: 'Notifications for pill reminders',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Time to take medicine',
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      // Calculate next instance
      final tz.TZDateTime scheduledDate = _nextInstanceOfTime(reminder.time);

      // Schedule using the latest API signature
      await _notificationsPlugin.zonedSchedule(
        reminder.id.hashCode,
        'Time to take medicine',
        '${reminder.medicineName} - ${reminder.dosage}',
        scheduledDate,
        notificationDetails,
        // Using androidScheduleMode as required by modern Android 12+ support
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: reminder.id,
      );

      debugPrint(
        'Scheduled reminder for ${reminder.medicineName} at $scheduledDate',
      );
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  /// Cancel a specific reminder
  Future<void> cancelReminder(PillReminder reminder) async {
    try {
      await _notificationsPlugin.cancel(reminder.id.hashCode);
      debugPrint('Cancelled reminder for ${reminder.medicineName}');
    } catch (e) {
      debugPrint('Error cancelling reminder: $e');
    }
  }

  /// Cancel all reminders
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('Cancelled all reminders');
    } catch (e) {
      debugPrint('Error cancelling all reminders: $e');
    }
  }

  /// Calculate the next instance of the reminder time
  tz.TZDateTime _nextInstanceOfTime(DateTime time) {
    // Ensure we are using length-safe local time
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

final reminderService = ReminderService();
