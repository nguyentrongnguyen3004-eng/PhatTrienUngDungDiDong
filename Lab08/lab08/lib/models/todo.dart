class Todo {
  String title;
  DateTime time;

  // Khởi tạo
  Todo({required this.title, required this.time});

  // convert -> string để lưu file
  String toFileString() {
    return "$title|${time.toIso8601String()}";
  }

  // parse <- string đọc từ file
  static Todo fromString(String line) {
    final parts = line.split("|");
    return Todo(
      title: parts[0],
      time: DateTime.parse(parts[1]),
    );
  }
}
