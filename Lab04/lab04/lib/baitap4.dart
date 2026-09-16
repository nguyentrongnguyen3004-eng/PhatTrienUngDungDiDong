import 'package:flutter/material.dart';

class baitap04 extends StatelessWidget {
  const baitap04({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: baitap4(),
    );
  }
}

class baitap4 extends StatelessWidget {
  const baitap4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Text(
                        "My",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        " Cards",
                        style: TextStyle(fontSize: 26),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.grey, 
                      shape: BoxShape.circle
                    ),
                    child: const Icon(Icons.add, size: 30, color: Colors.white,),
                  )
                ],
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[300],
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                     BoxShadow(
                      color: Colors.deepPurple.shade200,
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Balance", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 5),
                    const Text(
                      "\$5250.25",
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("12345678", style: TextStyle(color: Colors.white70)),
                        Text("10/24", style: TextStyle(color: Colors.white70)),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(width: 45, height: 20, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(20))),
                   const SizedBox(width: 10),
                   Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                   const SizedBox(width: 10),
                   Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(Icons.send_rounded, "Send", Colors.orange),
                  _buildActionButton(Icons.credit_card, "Pay", Colors.blue),
                  _buildActionButton(Icons.receipt_long, "Bills", Colors.green),
                ],
              ),

              const SizedBox(height: 30),

              _buildListTile(
                icon: Icons.bar_chart, 
                iconBg: Colors.orange.shade100, 
                iconColor: Colors.orange, 
                title: "Statistics", 
                subtitle: "Payment and Income"
              ),
              const SizedBox(height: 30),
              _buildListTile(
                icon: Icons.attach_money, 
                iconBg: Colors.green.shade100, 
                iconColor: Colors.green, 
                title: "Transactions", 
                subtitle: "Transaction History"
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.pink,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.monetization_on_outlined,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5)
              )
            ]
          ),
          child: Icon(icon, size: 30, color: color), 
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[700]),)
      ],
    );
  }

  Widget _buildListTile({required IconData icon, required Color iconBg, required Color iconColor, required String title, required String subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Icon(icon, color: iconColor, size: 60),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          ],
        ),
        const Icon(Icons.arrow_forward_ios, size: 30, color: Colors.grey,)
      ],
    );
  }
}