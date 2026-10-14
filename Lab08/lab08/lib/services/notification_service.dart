import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);
    await _requestPermission();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  static AndroidNotificationDetails _createAndroidDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
    Importance importance = Importance.max,
    Priority priority = Priority.high,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );
  }

  Future<void> showSimpleNotification({
    int id = 0,
    String title = 'Nhắc học từ vựng',
    String body = 'Bạn đã học 5 từ mới hôm nay chưa?',
    String channelId = 'learn_english_channel',
    String channelName = 'Học Anh Văn',
  }) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
    );
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: details),
    );
  }

  Future<void> scheduleNotificationAfter({
    required int id,
    required Duration delay,
    required String channelId,
    required String channelName,
    required String channelDescription,
  }) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );

    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

    await _plugin.zonedSchedule(
      id,
      channelName,
      channelDescription,
      scheduledTime,
      NotificationDetails(android: details),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleNotificationAt({
    required int id,
    required DateTime scheduledDate,
    required String title,
    required String body,
    String channelId = 'todo_scheduled_channel',
    String channelName = 'Nhắc nhở công việc',
  }) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
    );

    tz.TZDateTime tzTime = tz.TZDateTime.from(scheduledDate, tz.local);
    // Nếu thời gian đã ở quá khứ thì cộng thêm 5 giây để test
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) {
      tzTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      NotificationDetails(android: details),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
