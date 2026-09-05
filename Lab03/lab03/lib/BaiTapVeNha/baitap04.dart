import 'package:flutter/material.dart';

class BaiTap04 extends StatelessWidget {
  const BaiTap04({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Thông tin nhóm"),
          backgroundColor: Colors.blue[900],
          leading: const Icon(Icons.group),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [

              Center(
                child: Text(
                  "NHÓM LẬP TRÌNH FLUTTER",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text("Mã nhóm: N01",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              Text("Tên nhóm: Nhóm Flutter cơ bản",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 8),

              Text("Số lượng thành viên: 3",
                  style: TextStyle(fontSize: 20)),

              SizedBox(height: 20),

              Text(
                "Danh sách thành viên",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),

              SizedBox(height: 10),

              Text("1. MSSV: 200123001",
                  style: TextStyle(fontSize: 18)),
              Text("   Tên: Nguyễn Văn A",
                  style: TextStyle(fontSize: 18)),
              Text("   Vai trò: Nhóm trưởng",
                  style: TextStyle(fontSize: 18)),

              SizedBox(height: 10),

              Text("2. MSSV: 200123002",
                  style: TextStyle(fontSize: 18)),
              Text("   Tên: Trần Thị B",
                  style: TextStyle(fontSize: 18)),
              Text("   Vai trò: Thành viên",
                  style: TextStyle(fontSize: 18)),

              SizedBox(height: 10),

              Text("3. MSSV: 200123003",
                  style: TextStyle(fontSize: 18)),
              Text("   Tên: Lê Văn C",
                  style: TextStyle(fontSize: 18)),
              Text("   Vai trò: Thành viên",
                  style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
