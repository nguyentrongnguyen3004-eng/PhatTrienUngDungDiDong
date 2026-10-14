class WordItem {
  final String word;
  final String meaning;

  WordItem({required this.word, required this.meaning});

  String toFileString() {
    return "$word|$meaning";
  }

  static WordItem fromString(String line) {
    final parts = line.split("|");
    return WordItem(
      word: parts[0],
      meaning: parts.length > 1 ? parts[1] : "",
    );
  }
}
