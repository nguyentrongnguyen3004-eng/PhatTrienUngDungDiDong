import 'package:flutter/material.dart';
import '../../models/daily_task.dart';
import '../../services/daily_task_service.dart';
import '../../services/notification_service.dart';

class ScreenDailyTasks extends StatefulWidget {
  const ScreenDailyTasks({super.key});

  @override
  State<ScreenDailyTasks> createState() => _ScreenDailyTasksState();
}

class _ScreenDailyTasksState extends State<ScreenDailyTasks> {
  final DailyTaskService _taskService = DailyTaskService();
  final NotificationService _notificationService = NotificationService();
  List<DailyTask> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final list = await _taskService.loadTasks();
    setState(() {
      _tasks = list;
    });
  }

  void _onTaskChecked(DailyTask task, bool? checked) async {
    if (checked == true) {
      // Hiển thị hộp thoại hỏi người dùng có xác nhận nhiệm vụ này đã hoàn thành ?
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Xác nhận"),
          content: Text("Nhiệm vụ \"${task.title}\" này đã hoàn thành?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Không"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Có"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        setState(() {
          task.isCompleted = true;
        });
        await _taskService.saveTasks(_tasks);

        // Đếm số lượng nhiệm vụ đã hoàn thành
        final completedCount = _tasks.where((t) => t.isCompleted).length;

        // Thông báo trên khay thông báo của hệ thống số lượng nhiệm vụ đã hoàn thành
        await _notificationService.showSimpleNotification(
          id: 999,
          title: 'Nhiệm vụ hoàn thành!',
          body: 'Bạn đã hoàn thành $completedCount nhiệm vụ trong ngày hôm nay.',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã hoàn thành! Tổng số việc xong: $completedCount')),
          );
        }
      }
    } else {
      setState(() {
        task.isCompleted = false;
      });
      await _taskService.saveTasks(_tasks);
    }
  }

  void _openAddTaskScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const ScreenAddDailyTask()),
    );
    if (result == true) {
      _loadTasks();
    }
  }

  void _setupOrEditReminder(DailyTask task) async {
    final timeParts = task.reminderTime.split(":");
    final initialHour = int.tryParse(timeParts[0]) ?? 8;
    final initialMinute = int.tryParse(timeParts.length > 1 ? timeParts[1] : "0") ?? 0;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (pickedTime != null) {
      final formattedTime =
          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
      setState(() {
        task.reminderTime = formattedTime;
      });
      await _taskService.saveTasks(_tasks);

      // Lên lịch thông báo
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationService.scheduleNotificationAt(
        id: task.id.hashCode,
        scheduledDate: scheduledDate,
        title: 'Nhắc nhở nhiệm vụ',
        body: 'Đến giờ: ${task.title}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật giờ nhắc cho "${task.title}" lúc $formattedTime')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhiệm vụ mỗi ngày"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text("Chưa có nhiệm vụ nào!"))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (val) => _onTaskChecked(task, val),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text("Nhắc lúc: ${task.reminderTime}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.grey),
                      onPressed: () => _setupOrEditReminder(task),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ================= MÀN HÌNH THÊM NHIỆM VỤ MỚI =================
class ScreenAddDailyTask extends StatefulWidget {
  const ScreenAddDailyTask({super.key});

  @override
  State<ScreenAddDailyTask> createState() => _ScreenAddDailyTaskState();
}

class _ScreenAddDailyTaskState extends State<ScreenAddDailyTask> {
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final DailyTaskService _taskService = DailyTaskService();
  final NotificationService _notificationService = NotificationService();
  TimeOfDay? _selectedTime;

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      _selectedTime = picked;
      _timeController.text =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  void _saveTask() async {
    final title = _titleController.text.trim();
    final timeStr = _timeController.text.trim();

    if (title.isEmpty || timeStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhiệm vụ và chọn giờ nhắc!')),
      );
      return;
    }

    final tasks = await _taskService.loadTasks();
    final newTask = DailyTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      reminderTime: timeStr,
      isCompleted: false,
    );

    tasks.add(newTask);
    await _taskService.saveTasks(tasks);

    // Lên lịch notification theo giờ đã chọn
    if (_selectedTime != null) {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationService.scheduleNotificationAt(
        id: newTask.id.hashCode,
        scheduledDate: scheduledDate,
        title: 'Nhiệm vụ: $title',
        body: 'Đến giờ thực hiện: $title',
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm nhiệm vụ mới"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Tên nhiệm vụ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              readOnly: true,
              onTap: _pickTime,
              decoration: const InputDecoration(
                labelText: "Giờ nhắc",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _saveTask,
              child: const Text("Lưu nhiệm vụ"),
            ),
          ],
        ),
      ),
    );
  }
}
