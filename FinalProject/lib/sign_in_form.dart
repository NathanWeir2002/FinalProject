import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/account.dart';

// Form to sign into a new account. Similar to new_acc_form.
// Probably only needed one of these forms. Oh, well.
class SignInForm extends StatefulWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController _userLongName = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // Account that will be found in the database.
  Account? account;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign in"),
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
              controller: _password,
              decoration: const InputDecoration(labelText: 'Enter account password'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                saveInfo();
              },
              child: const Text("Sign in"),
            ),
          ],
        ),
      ),
    );
  }

  // Sets up the data to be checked in the database.
  void saveInfo() async {
    final String userLongName = _userLongName.text;
    final String password = _password.text;

    // Will only leave page if data is entered,
    // otherwise nothing happens when "save" button is clicked
    if (userLongName.isNotEmpty || password.isNotEmpty) {
      print("Checking accounts...");

      await _checkAccount(userLongName, password);
    } else {
      print("Enter a username and password.");
    }
  }

  // Searches through the 'accounts' section to see if any account
  // matches the provided userLongName and password.
  Future _checkAccount(String userLongName, String password) async{
    var collection = FirebaseFirestore.instance.collection('accounts');
    var querySnapshot = await collection.get();

    for (var doc in querySnapshot.docs) {
      // Check if the document contains the field and its value
      if (doc.data().containsKey('userLongName') &&
          doc.data()['userLongName'] == userLongName &&
          doc.data().containsKey('password') &&
          doc.data()['password'] == password) {
        account = Account.fromMap(doc.data());
        // Exits form.
        Navigator.pop(context, account);
      }
    }
    if (account == null) {
      _showSnackBar('No matching account found for ${_userLongName.text}. Create account?');
    }
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

