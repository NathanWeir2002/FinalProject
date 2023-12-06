import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab_extension/account.dart';

class NewAccForm extends StatefulWidget {
  const NewAccForm({Key? key}) : super(key: key);

  @override
  State<NewAccForm> createState() => _NewAccFormState();
}

class _NewAccFormState extends State<NewAccForm> {
  final TextEditingController _userLongName = TextEditingController();
  final TextEditingController _userShortName = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool loading = false;
  Account? account;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _userLongName,
              decoration: const InputDecoration(labelText: 'Enter account long name'),
            ),
            TextFormField(
              controller: _userShortName,
              decoration: const InputDecoration(labelText: 'Enter account short name'),
            ),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Enter account password'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: loading ? null : saveInfo,
              child: loading
                  ? const CircularProgressIndicator() // Show CircularProgressIndicator when loading is true
                  : const Text("Sign in"),
            ),
          ],
        ),
      ),
    );
  }

  void saveInfo() async {
    setState(() {
      loading = true; // Set loading to true to show CircularProgressIndicator
    });

    final String userLongName = _userLongName.text;
    final String userShortName = _userShortName.text;
    final String password = _password.text;

    if (userLongName.isNotEmpty || password.isNotEmpty) {
      await _saveAccount(userLongName, userShortName, password);
    } else {
      _showSnackBar("Enter a username and password.");
      setState(() {
        loading = false; // Reset loading to false on error
      });
    }
  }

  Future _saveAccount(String userLongName, String userShortName, String password) async {
    account = Account.fromMap({
      'userShortName': userShortName,
      'userLongName': userLongName,
      'password': password,
      'followingAccs': <String>[]
    });

    try {
      await FirebaseFirestore.instance.collection('accounts').doc().set(account!.toMap());
      print("Account added!");
      setState(() {
        loading = false; // Reset loading to false after successful save
      });
      Navigator.pop(context, account);
    } catch (e) {
      _showSnackBar('Error writing to Firestore: $e');
      setState(() {
        loading = false; // Reset loading to false on error
      });
    }
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
