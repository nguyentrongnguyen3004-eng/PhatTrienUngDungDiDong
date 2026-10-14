import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/file_services.dart';
import '../services/notification_service.dart';

class ScreenTodoNotification extends StatefulWidget {
  const ScreenTodoNotification({super.key});

  @override
  State<ScreenTodoNotification> createState() => _ScreenTodoNotificationState();
}

class _ScreenTodoNotificationState extends State<ScreenTodoNotification> {
  final TextEditingController controller = TextEditingController();
  final FileService fileService = FileService();
  final NotificationService notificationService = NotificationService();

  List<Todo> todos = [];
  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    todos = await fileService.loadTodos();
    setState(() {});
  }

  void addTodoWithNotification() async {
    if (controller.text.trim().isEmpty || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên công việc và chọn thời gian!')),
      );
      return;
    }

    final todo = Todo(title: controller.text.trim(), time: selectedTime!);
    todos.add(todo);
    await fileService.saveTodos(todos);

    // Hành động 1: Hiển thị notification đã thêm lịch cho công việc
    await notificationService.showSimpleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Đã thêm lịch công việc mới',
      body: 'Công việc "${todo.title}" đã được lên lịch thành công!',
    );

    // Hành động 2: Thiết lập lịch cho công việc theo thời gian đã chọn
    await notificationService.scheduleNotificationAt(
      id: todo.time.millisecondsSinceEpoch ~/ 1000,
      scheduledDate: todo.time,
      title: 'Nhắc nhở: ${todo.title}',
      body: 'Đã đến giờ thực hiện công việc: ${todo.title}',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã lưu "${todo.title}" và hẹn giờ nhắc lúc ${formatTime(todo.time)}',
          ),
        ),
      );
    }

    controller.clear();
    selectedTime = null;
    setState(() {});
  }

  void pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        selectedTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {});
      }
    }
  }

  String formatTime(DateTime time) {
    return DateFormat("dd/MM/yyyy HH:mm").format(time);
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.red.shade100,
      Colors.green.shade100,
      Colors.blue.shade100,
      Colors.yellow.shade100,
      Colors.purple.shade100,
    ];

    Color getTextColor(Color bg) {
      return bg.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhắc việc + Notification (Bài 3)"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Nhập công việc
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Tên công việc",
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Chọn thời gian
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTime == null
                        ? "Chưa chọn thời gian"
                        : formatTime(selectedTime!),
                  ),
                ),
                ElevatedButton(
                  onPressed: pickDateTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Chọn thời gian",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Nút Lưu với 2 hành động Notification
            ElevatedButton(
              onPressed: addTodoWithNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.blue, width: 1.5),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text("Lưu & Đặt lịch nhắc"),
            ),
            const SizedBox(height: 20),

            // Danh sách Todo
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final t = todos[index];
                  final Color bgColor = colors[index % colors.length];
                  return Card(
                    color: bgColor,
                    child: ListTile(
                      leading: Icon(
                        Icons.alarm,
                        color: getTextColor(bgColor),
                      ),
                      title: Text(
                        t.title,
                        style: TextStyle(
                          color: getTextColor(bgColor),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        formatTime(t.time),
                        style: TextStyle(
                          color: getTextColor(bgColor).withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
