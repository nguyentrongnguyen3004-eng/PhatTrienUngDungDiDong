import 'package:flutter/material.dart';

class baitap01_1 extends StatelessWidget{
    const baitap01_1({super.key});
    @override
    Widget build(BuildContext context){
        return MaterialApp(
            title: 'Khoa Công nghệ thông tin',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.blue,
            ),
            home: Scaffold(
                appBar: AppBar(
                    title: const Text(
                        'Thông tin sinh viên',
                        style: TextStyle(
                            color: Color.fromARGB(255, 32, 35, 32), fontSize: 18),
                        ),
                        backgroundColor: Colors.blue[900],
                        leading: IconButton(
                            icon: const Icon(Icons.home),
                            onPressed: () {},
                        ),
                    ),
                    body: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const SizedBox(height: 40),
                                const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text("",
                                        style: TextStyle(
                                            color: Color.fromARGB(255, 235, 19, 19),
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center),
                                    ),
                                ),
                               Center(
                                child: CircleAvatar(
                                  radius: 100, 
                                  backgroundImage: AssetImage("lib/BaiTapTaiLop/assets/images/avatar1.png"),
                                ),
                              ),

                                const Padding(
                                    padding: EdgeInsets.only(top: 30, left: 8),
                                    child: Text("Họ và tên: Nguyễn Văn A",
                                        style: TextStyle(
                                            color: Color.fromARGB(255, 138, 2, 249),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center),
                                ),
                                const SizedBox(height: 2),
                                const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("MSSV: 2001221234",
                                        style: TextStyle(
                                            color: Color.fromARGB(255, 244, 63, 54),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left),
                                        ),
                                const SizedBox(height: 2),
                                const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Lớp: 13DHTH02",
                                        style: TextStyle(
                                            color: Color.fromARGB(255, 244, 63, 54),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left),
                                        ),
                                const SizedBox(height: 2),
                                const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Khóa: 13 Đại học",
                                        style: TextStyle(
                                            color: Color.fromARGB(255, 244, 63, 54),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left),
                                        ),
                                const SizedBox(height: 2),
                                const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Ngành: Công nghệ thông tin ",
                                        style: TextStyle(
                                            color: Color.fromARGB(255, 244, 63, 54),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left),
                                        ),
                                const SizedBox(height: 2),
                                const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Trường: Đại học Công Thương Thành phố Hồ Chí Minh",
                                        style: TextStyle(
                                            color: Color.fromARGB(255, 244, 63, 54),
                                            fontSize: 20),
                                        textAlign: TextAlign.left),
                                        ),
                                const SizedBox(height: 40),
                            Center(
                            child: SizedBox(
                                height: 50,
                                width: 200,
                                child: ElevatedButton(
                                onPressed: () {},
                                child: const Text("Trở về",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                  )),
                                ),
                            ),
                            
                            ],
                        )
                    )
                )
            );
    }
}