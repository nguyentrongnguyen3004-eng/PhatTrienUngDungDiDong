import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/daily_task.dart';

class DailyTaskService {
  Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _file async {
    final path = await _path;
    return File('$path/daily_tasks.txt');
  }

  Future<void> saveTasks(List<DailyTask> tasks) async {
    final file = await _file;
    final content = tasks.map((t) => t.toFileString()).join('\n');
    await file.writeAsString(content);
  }

  Future<List<DailyTask>> loadTasks() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        final sample = [
          DailyTask(
            id: '1',
            title: 'Học bài chương 4',
            reminderTime: '20:00',
            isCompleted: false,
          ),
          DailyTask(
            id: '2',
            title: 'Học bài chương 4',
            reminderTime: '20:00',
            isCompleted: false,
          ),
          DailyTask(
            id: '3',
            title: 'Học bài chương 4',
            reminderTime: '20:00',
            isCompleted: false,
          ),
        ];
        await saveTasks(sample);
        return sample;
      }
      final content = await file.readAsString();
      return content
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .map((l) => DailyTask.fromString(l))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
