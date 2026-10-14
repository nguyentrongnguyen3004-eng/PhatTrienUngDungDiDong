class DailyTask {
  String id;
  String title;
  String reminderTime; // Định dạng HH:mm
  bool isCompleted;

  DailyTask({
    required this.id,
    required this.title,
    required this.reminderTime,
    this.isCompleted = false,
  });

  String toFileString() {
    return "$id|$title|$reminderTime|${isCompleted ? '1' : '0'}";
  }

  static DailyTask fromString(String line) {
    final parts = line.split("|");
    return DailyTask(
      id: parts[0],
      title: parts.length > 1 ? parts[1] : "",
      reminderTime: parts.length > 2 ? parts[2] : "08:00",
      isCompleted: parts.length > 3 && parts[3] == "1",
    );
  }
}
