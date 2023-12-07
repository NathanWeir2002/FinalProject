import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/account.dart';

// Form to create a new account. Similar to sign_in_form.
// Probably only needed one of these forms. Oh, well.
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
              // If the form is saving the new account, button will not be
              // functional and will display circularprogressindicator.
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

  // Ensures the data is ready to be sent to the database.
  void saveInfo() async {
    setState(() {
      loading = true; // Set loading to true to show CircularProgressIndicator
    });

    final String userLongName = _userLongName.text;
    final String userShortName = _userShortName.text;
    final String password = _password.text;

    // Makes sure that all forms have been filled out before saving account info
    if (userLongName.isNotEmpty && password.isNotEmpty && userShortName.isNotEmpty) {
      await _saveAccount(userLongName, userShortName, password);
    } else {
      _showSnackBar("Enter a username, short username and password.");
      setState(() {
        loading = false; // Reset loading to false on error
      });
    }
  }

  // Actually saves the account to the database.
  Future _saveAccount(String userLongName, String userShortName, String password) async {
    try {
      // Gets docRef of new location for data
      DocumentReference docRef = FirebaseFirestore.instance.collection('accounts').doc();
      print("Attemping...");

      // Sets up the provided data into an Account datatype.
      account = Account.fromMap({
        'accReference': docRef,
        'likedPosts': <DocumentReference>[],
        'retweetedPosts': <DocumentReference>[],
        'hiddenPosts': <DocumentReference>[],
        'userShortName': userShortName,
        'userLongName': userLongName,
        'password': password,
        'followingAccs': <String>[]
      });
      await docRef.set(account!.toMap()); // Sets the data to the database.
      print("Account added!");
      setState(() {
        loading = false; // Reset loading to false after successful save
      });
      Navigator.pop(context, account); // Exits the form
    } catch (e) {
      _showSnackBar('Error writing to Firestore: $e');
      setState(() {
        loading = false; // Reset loading to false on error
      });
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
