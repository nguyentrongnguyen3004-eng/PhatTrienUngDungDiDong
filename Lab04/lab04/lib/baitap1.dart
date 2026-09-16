import 'package:flutter/material.dart';


class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Standard", style: TextStyle(fontWeight: FontWeight.bold)),

        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Icon(Icons.history, size: 28),
          )
        ],
      ),

    
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            SizedBox(
              height: 100,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            
   
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Text("Calculator", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            _buildDrawerItem(Icons.grid_view, "Standard", isSelected: true), 
            _buildDrawerItem(Icons.science, "Scientific"),
            _buildDrawerItem(Icons.show_chart, "Graphing"),
            _buildDrawerItem(Icons.code, "Programmer"),
            _buildDrawerItem(Icons.calendar_today, "Date calculation"),

            const Divider(),

      
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Text("Converter", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            _buildDrawerItem(Icons.monetization_on_outlined, "Currency"),
            _buildDrawerItem(Icons.view_in_ar, "Volume"),
            _buildDrawerItem(Icons.straighten, "Length"),
            _buildDrawerItem(Icons.scale, "Weight and mass"),
            _buildDrawerItem(Icons.thermostat, "Temperature"),
            _buildDrawerItem(Icons.bolt, "Energy"),
            
            const Divider(),
             _buildDrawerItem(Icons.settings, "Settings"),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: const Text(
                "0",
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                buildButtonRow(["%", "CE", "C", "⌫"]),
                buildButtonRow(["1/x", "x²", "√x", "÷"]),
                buildButtonRow(["7", "8", "9", "×"]),
                buildButtonRow(["4", "5", "6", "-"]),
                buildButtonRow(["1", "2", "3", "+"]),
                buildButtonRow(["+/-", "0", ".", "="], isLastRow: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[300] : Colors.transparent, 
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        onTap: () {

        },
      ),
    );
  }


  Widget buildButtonRow(List<String> buttons, {bool isLastRow = false}) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((text) {
          Color bgColor = Colors.white; 
          Color textColor = Colors.black;
          FontWeight weight = FontWeight.normal;


          if (text == "=") {
            bgColor = Colors.blue.shade800; 
            textColor = Colors.white;
          } else if (int.tryParse(text) != null || text == "+/-" || text == ".") {
            bgColor = Colors.white; 
            weight = FontWeight.bold;
          } else {
            bgColor = Colors.grey.shade100; 
          }

          return Expanded(
            child: Container(
              margin: const EdgeInsets.all(1),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor,
                  elevation: 0, 
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                onPressed: () {},
                child: Text(
                  text,
                  style: TextStyle(fontSize: 22, color: textColor, fontWeight: weight),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}