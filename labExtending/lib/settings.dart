import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab_extension/account.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key, required this.account}) : super(key: key);

  final Account account;
  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final TextEditingController _imageURL = TextEditingController();

  bool success = false;

  @override
  void initState() {
    super.initState();
    // If adding data, no text will be displayed (only displays data being edited)
    if (widget.account.imageURL != null) {
      Map<String, dynamic> data = widget.account.toMap();
      _imageURL.text = data['imageURL']!;
    }
  }

  void _saveChanges() {
    setState(() {
      widget.account.imageURL = _imageURL.text;
      _updateAccountInfo(widget.account);
      _showSnackBar("Updated settings!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _imageURL,
              decoration: const InputDecoration(
                labelText: 'Profile Picture URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future _updateAccountInfo(Account account) async {
    await account.accReference!.set(account.toMap());
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}