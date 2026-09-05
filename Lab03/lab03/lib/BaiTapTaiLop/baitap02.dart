import 'package:flutter/material.dart';

class BaiTap02 extends StatelessWidget {
  const BaiTap02({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Thông tin đề tài đồ án',
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: Colors.blue[900],
          leading: const Icon(Icons.book),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Center(
                child: Text(
                  "ĐỀ TÀI KHÓA LUẬN",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              SizedBox(height: 30),

              Text("Mã đề tài: DT001",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              Text("Tên đề tài: Xây dựng ứng dụng quản lý sinh viên",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),

              Text("Số lượng sinh viên tối đa: 3",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),

              Text("Chuyên ngành: Công nghệ phần mềm",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),

              Text("Giảng viên hướng dẫn: Trần Thị A",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),

              Text(
                "Yêu cầu đề tài:\n"
                "- Có giao diện Flutter\n"
                "- Lưu trữ dữ liệu\n"
                "- Có đăng nhập",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
