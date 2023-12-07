import 'package:flutter/material.dart';
import 'package:final_project/account.dart';

// Creates a form with all the settings.
// Currently, only allows for changes to the user's profile picture.
class SettingsForm extends StatefulWidget {
  // Needs the currently signed-in account.
  const SettingsForm({Key? key, required this.account}) : super(key: key);

  final Account account;
  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  // Gets a new profile picture URL
  final TextEditingController _imageURL = TextEditingController();

  // Gets the current profile picture associated to the account if there is one.
  @override
  void initState() {
    super.initState();
    if (widget.account.imageURL != null) {
      Map<String, dynamic> data = widget.account.toMap();
      _imageURL.text = data['imageURL']!;
    }
  }

  // Updates the database with the changes.
  void _saveChanges() {
    setState(() {
      widget.account.imageURL = _imageURL.text;
      _updateAccountInfo(widget.account);
      _showSnackBar("Updated settings!");
    });
  }

  // Has section to enter profile picture URL, and has section to save.
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

  // Sets account info to the database.
  Future _updateAccountInfo(Account account) async {
    await account.accReference!.set(account.toMap());
  }

  // Yep, I yoinked this function. Thanks!
  // Shows a messsage in the snackbar.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}