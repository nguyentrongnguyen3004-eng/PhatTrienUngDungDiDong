import 'package:flutter/material.dart';


class baitap2 extends StatelessWidget {
  const baitap2({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FacilityHomePage(),
    );
  }
}

class FacilityHomePage extends StatefulWidget {
  const FacilityHomePage({super.key});

  @override
  State<FacilityHomePage> createState() => _FacilityHomePageState();
}

class _FacilityHomePageState extends State<FacilityHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    LabPage(),
    LibraryPage(),
    ContactPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HUIT - Cơ sở vật chất",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Giới thiệu",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: "Phòng thí nghiệm",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_library),
            label: "Thư viện",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone),
            label: "Liên hệ",
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          Icon(Icons.school, size: 100, color: Colors.blue),
          SizedBox(height: 15),
          Text(
            "Trường Đại học Công Thương TP. Hồ Chí Minh (HUIT)",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "HUIT là cơ sở đào tạo đa ngành, đa lĩnh vực với hệ thống cơ sở vật chất hiện đại, đáp ứng tốt nhu cầu học tập và nghiên cứu của sinh viên.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class LabPage extends StatelessWidget {
  const LabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        FacilityItem(
          icon: Icons.computer,
          title: "Phòng máy tính",
          description: "Trang bị đầy đủ máy tính phục vụ học tập CNTT.",
        ),
        FacilityItem(
          icon: Icons.biotech,
          title: "Phòng thí nghiệm hóa – sinh",
          description: "Phục vụ nghiên cứu và thực hành chuyên ngành.",
        ),
        FacilityItem(
          icon: Icons.precision_manufacturing,
          title: "Xưởng thực hành",
          description: "Trang thiết bị hiện đại cho sinh viên kỹ thuật.",
        ),
      ],
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          Icon(Icons.local_library, size: 100, color: Colors.green),
          SizedBox(height: 15),
          Text(
            "Thư viện HUIT",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Thư viện được trang bị nhiều đầu sách, tài liệu điện tử và không gian học tập hiện đại cho sinh viên.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Liên hệ",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.location_on),
              SizedBox(width: 10),
              Expanded(
                child: Text("140 Lê Trọng Tấn, Q. Tân Phú, TP.HCM"),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.phone),
              SizedBox(width: 10),
              Text("(028) 3816 1673"),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.email),
              SizedBox(width: 10),
              Text("info@huit.edu.vn"),
            ],
          ),
        ],
      ),
    );
  }
}

class FacilityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FacilityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
      ),
    );
  }
}
