import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';

import 'add_contact_screen.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({
    super.key,
  });

  @override
  State<ContactsListScreen> createState() =>
      _ContactsListScreenState();
}

class _ContactsListScreenState
    extends State<ContactsListScreen> {
  List<ContactInfo> _contacts = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<ContactInfo> contacts =
          await FlutterContactsService.getContacts();

      debugPrint('========== CONTACTS ==========');

      for (final contact in contacts) {
        debugPrint(
          'Tên: ${contact.displayName}',
        );

        debugPrint(
          'GivenName: ${contact.givenName}',
        );

        debugPrint(
          'Phone: ${contact.phones?.map((e) => e.value).toList()}',
        );

        debugPrint(
          'Email: ${contact.emails?.map((e) => e.value).toList()}',
        );

        debugPrint(
          'Avatar: ${contact.avatar?.length ?? 0} bytes',
        );

        debugPrint('------------------------------');
      }

      if (!mounted) return;

      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Lỗi tải danh bạ: $e',
      );

      if (!mounted) return;

      setState(() {
        _contacts = [];
        _isLoading = false;
      });
    }
  }

  String _getName(ContactInfo contact) {
    if (contact.displayName != null &&
        contact.displayName!.trim().isNotEmpty) {
      return contact.displayName!;
    }

    if (contact.givenName != null &&
        contact.givenName!.trim().isNotEmpty) {
      return contact.givenName!;
    }

    return 'Không có tên';
  }

  String _getPhone(ContactInfo contact) {
    if (contact.phones == null ||
        contact.phones!.isEmpty) {
      return 'Không có số';
    }

    final String? phone =
        contact.phones!.first.value;

    if (phone == null ||
        phone.trim().isEmpty) {
      return 'Không có số';
    }

    return phone;
  }

  String _getEmail(ContactInfo contact) {
    if (contact.emails == null ||
        contact.emails!.isEmpty) {
      return 'Không có email';
    }

    final String? email =
        contact.emails!.first.value;

    if (email == null ||
        email.trim().isEmpty) {
      return 'Không có email';
    }

    return email;
  }

  Widget _buildAvatar(ContactInfo contact) {
    final avatar = contact.avatar;

    if (avatar == null || avatar.isEmpty) {
      return const CircleAvatar(
        child: Icon(
          Icons.person,
        ),
      );
    }

    return CircleAvatar(
      child: ClipOval(
        child: Image.memory(
          avatar,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return const Icon(
              Icons.person,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh bạ',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: _loadContacts,
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AddContactScreen(),
                ),
              );

              _loadContacts();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _contacts.isEmpty
              ? const Center(
                  child: Text(
                    'Không có danh bạ nào.',
                  ),
                )
              : ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final ContactInfo contact =
                        _contacts[index];

                    return ListTile(
                      leading: _buildAvatar(
                        contact,
                      ),
                      title: Text(
                        _getName(contact),
                      ),
                      subtitle: Text(
                        '${_getPhone(contact)}\n'
                        '${_getEmail(contact)}',
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
    );
  }
}