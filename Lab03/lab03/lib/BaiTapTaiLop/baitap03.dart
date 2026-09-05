import 'package:flutter/material.dart';

class BaiTap03 extends StatelessWidget {
  const BaiTap03({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Thông tin sản phẩm',
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: Colors.blue[900],
          leading: const Icon(Icons.shopping_cart),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 3 hình ảnh sản phẩm
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Image(
                    image: AssetImage("lib/BaiTapTaiLop/assets/images/sp1.jpg"),
                    width: 100,
                    height: 100,
                  ),
                  Image(
                    image: AssetImage("lib/BaiTapTaiLop/assets/images/sp2.jpg"),
                    width: 100,
                    height: 100,
                  ),
                  Image(
                    image: AssetImage("lib/BaiTapTaiLop/assets/images/sp3.jpg"),
                    width: 100,
                    height: 100,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Mã sản phẩm: SP001",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Tên sản phẩm: Giày thể thao Nike",
                  style: TextStyle(fontSize: 20),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Nhà sản xuất: Nike",
                  style: TextStyle(fontSize: 20),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Giá bán: 2.500.000 VNĐ",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Mô tả sản phẩm:\n"
                  "Giày thể thao cao cấp, êm chân, phù hợp chạy bộ "
                  "và hoạt động thể thao.",
                  style: TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    "Mua ngay",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
