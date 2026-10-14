import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class ScreenNotiEx extends StatelessWidget {
  const ScreenNotiEx({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService notificationservice = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen Noti Example"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nút 1: Gửi thông báo ngay tức thì
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  notificationservice.showSimpleNotification(
                    id: 1,
                    title: 'Nhắc học Ngoại ngữ',
                    body: 'Bạn đã học 5 từ mới hôm nay chưa?',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã gửi thông báo nhắc học Ngoại ngữ!')),
                  );
                },
                child: const Text("Gửi thông báo nhắc học Ngoại ngữ"),
              ),
              const SizedBox(height: 20),

              // Nút 2: Hẹn thông báo nhắc uống nước sau 2 phút
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  notificationservice.scheduleNotificationAfter(
                    id: 2,
                    delay: const Duration(minutes: 2),
                    channelId: 'drink_water_channel',
                    channelName: 'Uống nước',
                    channelDescription: 'Nhắc uống nước đúng giờ',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã hẹn thông báo nhắc uống nước sau 2 phút!')),
                  );
                },
                child: const Text("Gửi thông báo nhắc uống nước sau 2 phút"),
              ),
              const SizedBox(height: 20),

              // Nút 3: Sinh viên tự viết - Hẹn giờ gửi thông báo học Ngoại ngữ sau 10 phút
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  notificationservice.scheduleNotificationAfter(
                    id: 3,
                    delay: const Duration(minutes: 10),
                    channelId: 'learn_english_channel',
                    channelName: 'Học Ngoại ngữ',
                    channelDescription: 'Đã đến giờ học 5 từ mới tiếng Anh rồi!',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã hẹn giờ nhắc học Ngoại ngữ sau 10 phút!')),
                  );
                },
                child: const Text("Hẹn giờ gửi thông báo học Ngoại ngữ sau 10 phút"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
