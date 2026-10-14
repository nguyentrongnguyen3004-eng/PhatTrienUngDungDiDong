import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/word_item.dart';

class WordService {
  Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _file async {
    final path = await _path;
    return File('$path/words.txt');
  }

  Future<void> saveWord(WordItem word) async {
    final words = await loadWords();
    words.add(word);
    final file = await _file;
    final content = words.map((w) => w.toFileString()).join('\n');
    await file.writeAsString(content);
  }

  Future<List<WordItem>> loadWords() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        // Tạo một số từ mẫu mặc định ban đầu nếu chưa có file
        final defaults = [
          WordItem(word: 'subject', meaning: 'môn học'),
          WordItem(word: 'student', meaning: 'sinh viên'),
          WordItem(word: 'teacher', meaning: 'giáo viên'),
          WordItem(word: 'school', meaning: 'trường học'),
        ];
        await file.writeAsString(defaults.map((w) => w.toFileString()).join('\n'));
        return defaults;
      }
      final content = await file.readAsString();
      return content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => WordItem.fromString(line))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
