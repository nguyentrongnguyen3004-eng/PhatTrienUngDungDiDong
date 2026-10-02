import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  File? _avatar;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: source,
    );

    if (pickedFile == null) {
      return;
    }

    setState(() {
      _avatar = File(pickedFile.path);
    });
  }

  Future<void> _saveContact() async {
    final String name =
        _nameController.text.trim();

    final String phone =
        _phoneController.text.trim();

    final String email =
        _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập tên!',
          ),
        ),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập số điện thoại!',
          ),
        ),
      );
      return;
    }

    final PermissionStatus permission =
        await Permission.contacts.request();

    if (!permission.isGranted) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng cấp quyền truy cập danh bạ!',
          ),
        ),
      );

      return;
    }

    try {
      final List<ValueItem> phones = [
        ValueItem(
          label: 'mobile',
          value: phone,
        ),
      ];

      final List<ValueItem> emails = [];

      if (email.isNotEmpty) {
        emails.add(
          ValueItem(
            label: 'work',
            value: email,
          ),
        );
      }

      final ContactInfo contact = ContactInfo(
        givenName: name,
        phones: phones,
        emails: emails,
        avatar: _avatar != null
            ? await _avatar!.readAsBytes()
            : null,
      );

      debugPrint('==============================');
      debugPrint('CONTACT TRƯỚC KHI LƯU');
      debugPrint('Tên: ${contact.givenName}');
      debugPrint(
        'Phone: ${contact.phones?.map((e) => e.value).toList()}',
      );
      debugPrint(
        'Email: ${contact.emails?.map((e) => e.value).toList()}',
      );
      debugPrint('==============================');

      await FlutterContactsService.addContact(
        contact,
      );

      debugPrint('ĐÃ GỌI addContact()');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Danh bạ đã được lưu thành công!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint(
        'LỖI ADD CONTACT: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi khi lưu danh bạ: $e',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm danh bạ',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                _pickImage(
                  ImageSource.gallery,
                );
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _avatar != null
                    ? FileImage(_avatar!)
                    : null,
                child: _avatar == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 50,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _emailController,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveContact,
                child: const Text(
                  'Lưu',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

