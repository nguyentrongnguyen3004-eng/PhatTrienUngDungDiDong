import 'package:flutter/material.dart';
import 'contacts_list_screen.dart';

class BT5 extends StatelessWidget {
  const BT5({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ContactsListScreen(),
    );
  }
}