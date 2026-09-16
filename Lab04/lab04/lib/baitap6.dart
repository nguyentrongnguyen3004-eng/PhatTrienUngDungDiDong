import 'package:flutter/material.dart';

class baitap06 extends StatelessWidget {
  const baitap06({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: baitap6(),
    );
  }
}

class baitap6 extends StatelessWidget {
  const baitap6({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.grey[300];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeuBox(child: const Icon(Icons.arrow_back)),
                  Text("P L A Y L I S T", style: TextStyle(color: Colors.grey[700], letterSpacing: 2)),
                  NeuBox(child: const Icon(Icons.menu)),
                ],
              ),

              const SizedBox(height: 40),

              NeuBox(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/zingmp3.png',
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover,
                  ),

                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kota The Friend", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      const SizedBox(height: 6),
                      const Text("Birdie", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Icon(Icons.favorite, color: Colors.red, size: 32)
                ],
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("0:00", style: TextStyle(color: Colors.grey[600], fontSize: 30)),
                  NeuBox(child: const Icon(Icons.shuffle, color: Colors.grey, size: 30)),
                  NeuBox(child: const Icon(Icons.repeat, color: Colors.grey, size: 30)),
                  Text("4:22", style: TextStyle(color: Colors.grey[600], fontSize: 30)),
                ],
              ),
              const SizedBox(height: 10),
              NeuBox(
                padding: const EdgeInsets.all(0),
                child: LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeuBox(child: const Icon(Icons.skip_previous, size: 60)),
                  NeuBox(child: const Icon(Icons.play_arrow, size: 60)),
                  NeuBox(child: const Icon(Icons.skip_next, size: 60)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NeuBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const NeuBox({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            blurRadius: 15,
            offset: const Offset(5, 5),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 15,
            offset: Offset(-5, -5),
          ),
        ],
      ),
      child: child,
    );
  }
}