import 'package:flutter/material.dart';

class baitap05 extends StatelessWidget {
  const baitap05({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: baitap5(),
    );
  }
}

class baitap5 extends StatelessWidget {
  const baitap5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Hello,", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
                        SizedBox(height: 4),
                        Text("Mitch Koko", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[50],
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: const Icon(Icons.person),
                    )
                  ],
                ),

                const SizedBox(height: 25),


                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC0CB), 
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[300], 
                          borderRadius: BorderRadius.circular(12)
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("How do you feel?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                            const SizedBox(height: 8),
                            const Text("Fill out your medical card right now", style: TextStyle(fontSize: 26)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7B51D3), 
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: const Text("Get Started", style: TextStyle(color: Colors.white, fontSize: 14)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: "How can we help you?",
                      hintStyle: TextStyle(color: Colors.grey)
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryItem("Dentist", Icons.medical_services_outlined),
                      const SizedBox(width: 30),
                      _buildCategoryItem("Surgeon", Icons.healing_outlined),
                      const SizedBox(width: 30),
                      _buildCategoryItem("Therapy", Icons.spa_outlined),
                      const SizedBox(width: 30 ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Doctor list", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("See all", style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                  ],
                ),

                const SizedBox(height: 20),

                
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildDoctorCard(
                        "Dr. Mitch Koko", 
                        "Psychologist 7 y.e.", 
                        "assets/doc1.png", 
                        4.4
                      ),
                      const SizedBox(width: 15),
                      _buildDoctorCard(
                        "Dr. Steve Jobs", 
                        "Surgeon 7 y.e.", 
                        "assets/doc2.png", 
                        5.0
                      ),
                      const SizedBox(width: 15),
                      _buildDoctorCard(
                        "Dr. Michael Brown", 
                        "Cardiologist · 10 y.e.", 
                        "assets/doc3.png", 
                        4.9
                      ),
                      const SizedBox(width: 15),
                      _buildDoctorCard(
                        "Dr. Emily Davis", 
                        "Therapist · 6 y.e.", 
                        "assets/doc4.png", 
                        4.3
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(12)
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Widget _buildDoctorCard(
    String name,
    String job,
    String imagePath,
    double rating,
  ) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Text(job,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}