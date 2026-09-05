import 'package:flutter/material.dart';

class BaiTap05 extends StatelessWidget {
  const BaiTap05({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Giới thiệu ngành học"),
          backgroundColor: Colors.blue[900],
          leading: const Icon(Icons.school),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [

              Center(
                child: Text(
                  "KHOA CÔNG NGHỆ THÔNG TIN",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 10),

              Center(
                child: Text(
                  "Trường Đại học Công Thương TP. Hồ Chí Minh",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 30),

              Text(
                "Ngành Công nghệ Thông tin (CNTT)",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),

              SizedBox(height: 10),

              Text(
                "Ngành CNTT đào tạo sinh viên có kiến thức về "
                "lập trình, phát triển phần mềm, cơ sở dữ liệu, "
                "mạng máy tính và các hệ thống thông tin.",
                style: TextStyle(fontSize: 18),
              ),

              SizedBox(height: 20),

              Text(
                "Ngành An toàn Thông tin (ATTT)",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),

              SizedBox(height: 10),

              Text(
                "Ngành ATTT đào tạo sinh viên chuyên sâu về "
                "bảo mật hệ thống, an ninh mạng, mã hóa dữ liệu, "
                "phòng chống tấn công mạng và bảo vệ thông tin.",
                style: TextStyle(fontSize: 18),
              ),

              SizedBox(height: 30),

              Text(
                "Cơ hội nghề nghiệp",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),

              SizedBox(height: 10),

              Text(
                "- Lập trình viên\n"
                "- Kỹ sư phần mềm\n"
                "- Chuyên viên an ninh mạng\n"
                "- Quản trị hệ thống\n"
                "- Chuyên viên bảo mật",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
