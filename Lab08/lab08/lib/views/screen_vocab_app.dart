import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../models/word_item.dart';
import '../../services/word_service.dart';
import '../../services/notification_service.dart';

class ScreenVocabHome extends StatefulWidget {
  const ScreenVocabHome({super.key});

  @override
  State<ScreenVocabHome> createState() => _ScreenVocabHomeState();
}

class _ScreenVocabHomeState extends State<ScreenVocabHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;
    String title;

    switch (_selectedIndex) {
      case 0:
        title = "Ứng dụng học từ vựng";
        bodyWidget = const VocabAddTab();
        break;
      case 1:
        title = "Ôn tập từ mới";
        bodyWidget = const VocabStudyTab();
        break;
      case 2:
        title = "Trắc nghiệm Đúng / Sai";
        bodyWidget = const VocabQuizTab();
        break;
      case 3:
        title = "Lịch nhắc";
        bodyWidget = const VocabPendingRemindersTab();
        break;
      default:
        title = "Ứng dụng học từ vựng";
        bodyWidget = const VocabAddTab();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 45, color: Colors.blue),
              ),
              accountName: const Text(
                "Trợ lý học từ vựng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text("vocabulary@learning.app"),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Trang chính"),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text("Học từ"),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text("Kiểm tra từ"),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text("Lịch nhắc"),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: bodyWidget,
    );
  }
}

// ================= TAB 1: THÊM TỪ VỰNG =================
class VocabAddTab extends StatefulWidget {
  const VocabAddTab({super.key});

  @override
  State<VocabAddTab> createState() => _VocabAddTabState();
}

class _VocabAddTabState extends State<VocabAddTab> {
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _wordService = WordService();
  final _notificationService = NotificationService();

  void _saveAndSchedule() async {
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();

    if (word.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ Từ và Nghĩa!')),
      );
      return;
    }

    await _wordService.saveWord(WordItem(word: word, meaning: meaning));

    // Lên lịch notification nhắc sau 10 phút
    final notiId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _notificationService.scheduleNotificationAfter(
      id: notiId,
      delay: const Duration(minutes: 10),
      channelId: 'vocab_channel',
      channelName: 'Học từ vựng',
      channelDescription: 'Hãy ôn tập từ mới: "$word" (nghĩa: $meaning)',
    );

    // Bắn 1 notification tức thì báo đã lưu
    await _notificationService.showSimpleNotification(
      id: notiId + 1,
      title: 'Đã lưu từ vựng',
      body: 'Từ "$word" đã được lưu. Hãy ôn tập lại sau 10 phút!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu và lên lịch nhắc học từ sau 10 phút'),
          duration: Duration(seconds: 3),
        ),
      );
    }

    _wordController.clear();
    _meaningController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _wordController,
            decoration: const InputDecoration(
              labelText: "Từ",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _meaningController,
            decoration: const InputDecoration(
              labelText: "Nghĩa",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _saveAndSchedule,
            child: const Text("Lưu & Nhắc học sau 10 phút"),
          ),
        ],
      ),
    );
  }
}

// ================= TAB 2: HỌC TỪ =================
class VocabStudyTab extends StatefulWidget {
  const VocabStudyTab({super.key});

  @override
  State<VocabStudyTab> createState() => _VocabStudyTabState();
}

class _VocabStudyTabState extends State<VocabStudyTab> {
  final _wordService = WordService();
  final _notificationService = NotificationService();
  final _inputController = TextEditingController();

  List<WordItem> _words = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  void _loadWords() async {
    _words = await _wordService.loadWords();
    setState(() {});
  }

  void _checkAnswer() async {
    if (_words.isEmpty) return;

    final currentWord = _words[_currentIndex];
    final answer = _inputController.text.trim().toLowerCase();
    final correctAnswer = currentWord.meaning.trim().toLowerCase();

    bool isCorrect = answer.isNotEmpty &&
        (answer == correctAnswer ||
            correctAnswer.contains(answer) ||
            answer.contains(correctAnswer));

    if (isCorrect) {
      _correctCount++;
    } else {
      _wrongCount++;
      // Nếu số từ sai là bội số của 3 thì bắn notification
      if (_wrongCount % 3 == 0) {
        await _notificationService.showSimpleNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Cảnh báo ôn tập!',
          body: 'Bạn đã trả lời sai $_wrongCount lần. Hãy dành thời gian xem lại từ vựng nhé!',
        );
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCorrect
                ? 'Chính xác! "${currentWord.word}" = "${currentWord.meaning}"'
                : 'Sai rồi! "${currentWord.word}" có nghĩa là "${currentWord.meaning}"',
          ),
          backgroundColor: isCorrect ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    _inputController.clear();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return const Center(child: Text("Chưa có từ vựng nào. Hãy thêm ở Trang chính!"));
    }

    final currentWord = _words[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Hai ô điểm số đúng / sai
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "✓ $_correctCount từ",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "✗ $_wrongCount từ",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Từ hiển thị
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                currentWord.word,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Ô nhập nghĩa
          TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              hintText: "Nhập nghĩa tiếng Việt",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Nút Check
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            onPressed: _checkAnswer,
            child: const Text("Check"),
          ),
        ],
      ),
    );
  }
}

// ================= TAB 3: TRẮC NGHIỆM ĐÚNG / SAI =================
class VocabQuizTab extends StatefulWidget {
  const VocabQuizTab({super.key});

  @override
  State<VocabQuizTab> createState() => _VocabQuizTabState();
}

class _VocabQuizTabState extends State<VocabQuizTab> {
  final _wordService = WordService();
  List<WordItem> _words = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;

  String _displayMeaning = "";
  bool _isActualPair = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  void _loadWords() async {
    _words = await _wordService.loadWords();
    _setupQuestion();
    setState(() {});
  }

  void _setupQuestion() {
    if (_words.isEmpty) return;
    final current = _words[_currentIndex];
    // 50% cơ hội hiển thị đúng nghĩa, 50% hiển thị nghĩa từ khác
    _isActualPair = (_currentIndex % 2 == 0);
    if (_isActualPair || _words.length == 1) {
      _displayMeaning = current.meaning;
      _isActualPair = true;
    } else {
      final otherWord = _words[(_currentIndex + 1) % _words.length];
      _displayMeaning = otherWord.meaning;
    }
  }

  void _answer(bool userChoice) {
    bool isCorrect = (userChoice == _isActualPair);
    if (isCorrect) {
      _correctCount++;
    } else {
      _wrongCount++;
    }

    if (_currentIndex + 1 >= _words.length) {
      // Đã trả lời hết tất cả các câu
      _showResultDialog();
    } else {
      setState(() {
        _currentIndex++;
        _setupQuestion();
      });
    }
  }

  void _showResultDialog() {
    final total = _correctCount + _wrongCount;
    final percent = total > 0 ? ((_correctCount / total) * 100).toStringAsFixed(1) : "0";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Kết thúc bài kiểm tra", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Tổng số câu: $total"),
            const SizedBox(height: 8),
            Text("✓ Đúng: $_correctCount", style: const TextStyle(color: Colors.green)),
            Text("✗ Sai: $_wrongCount", style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            Text("Tỉ lệ đúng: $percent %", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentIndex = 0;
                _correctCount = 0;
                _wrongCount = 0;
                _setupQuestion();
              });
            },
            child: const Text("Làm lại"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Thoát"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return const Center(child: Text("Chưa có dữ liệu từ vựng!"));
    }

    final currentWord = _words[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("Đúng: $_correctCount", style: const TextStyle(color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("Sai: $_wrongCount", style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Text(
            currentWord.word,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Text(
            _displayMeaning,
            style: const TextStyle(fontSize: 22, color: Colors.grey),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _answer(true),
                  icon: const Icon(Icons.check),
                  label: const Text("✓ Đúng"),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _answer(false),
                  icon: const Icon(Icons.close),
                  label: const Text("✗ Sai"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ================= TAB 4: LỊCH NHẮC (PENDING NOTIFICATIONS) =================
class VocabPendingRemindersTab extends StatefulWidget {
  const VocabPendingRemindersTab({super.key});

  @override
  State<VocabPendingRemindersTab> createState() => _VocabPendingRemindersTabState();
}

class _VocabPendingRemindersTabState extends State<VocabPendingRemindersTab> {
  final NotificationService _notificationService = NotificationService();
  List<PendingNotificationRequest> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() async {
    final list = await _notificationService.getPendingNotifications();
    setState(() {
      _requests = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_requests.isEmpty) {
      return const Center(
        child: Text("Hiện tại không có lịch nhắc nào đang chờ."),
      );
    }

    return ListView.builder(
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final req = _requests[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.alarm, color: Colors.blue),
            title: Text(req.title ?? "Lịch nhắc"),
            subtitle: Text(req.body ?? ""),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _notificationService.cancel(req.id);
                _fetchRequests();
              },
            ),
          ),
        );
      },
    );
  }
}
