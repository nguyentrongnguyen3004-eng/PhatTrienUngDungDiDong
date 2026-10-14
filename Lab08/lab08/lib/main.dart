import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'views/screen_noti_ex.dart';
import 'views/screen_todo.dart';
import 'views/screen_todo_notification.dart';
import 'views/screen_vocab_app.dart';
import 'views/screen_daily_tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 08 - Notification & File',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const Lab08Dashboard(),
    );
  }
}

class Lab08Dashboard extends StatelessWidget {
  const Lab08Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = [
      {
        'title': 'Bài tập 1: Notification cơ bản',
        'subtitle': 'Thông báo tức thì, sau 2 phút, sau 10 phút',
        'icon': Icons.notifications_active,
        'color': Colors.blue,
        'screen': const ScreenNotiEx(),
      },
      {
        'title': 'Bài tập 2: Thao tác File với Todo App',
        'subtitle': 'Lưu và đọc dữ liệu công việc từ file todo.txt',
        'icon': Icons.note_alt,
        'color': Colors.teal,
        'screen': const ScreenTodo(),
      },
      {
        'title': 'Bài tập 3: Todo + Đặt lịch Notification',
        'subtitle': 'Lưu file + Báo notification tức thì & hẹn giờ',
        'icon': Icons.alarm_on,
        'color': Colors.purple,
        'screen': const ScreenTodoNotification(),
      },
      {
        'title': 'Bài tập 4: Ứng dụng Học từ vựng',
        'subtitle': 'Menu Drawer, ôn tập (sai 3 lần báo noti), trắc nghiệm, lịch nhắc',
        'icon': Icons.school,
        'color': Colors.orange,
        'screen': const ScreenVocabHome(),
      },
      {
        'title': 'Bài tập về nhà: Todo Nhiệm vụ mỗi ngày',
        'subtitle': 'Lưu file, tích hoàn thành hiện Dialog & Noti số việc xong',
        'icon': Icons.task_alt,
        'color': Colors.green,
        'screen': const ScreenDailyTasks(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 08: Notification & File'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final item = exercises[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: (item['color'] as Color).withValues(alpha: 0.15),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 30,
                  ),
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    item['subtitle'] as String,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => item['screen'] as Widget,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
