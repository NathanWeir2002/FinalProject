import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/account.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Form to sign into a new account. Similar to new_acc_form.
// Probably only needed one of these forms. Oh, well.
class AccountForm extends StatefulWidget {
  const AccountForm({Key? key}) : super(key: key);

  @override
  State<AccountForm> createState() => _AccountForm();
}

class _AccountForm extends State<AccountForm> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']); // Scopes define the required access
  // Account that will be found in the database.
  Account? account;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      // Handle user sign-in changes
      // You can perform actions here when the user signs in or out
    });
    _googleSignIn.signInSilently(); // Tries to sign in silently on app launch
  }

  bool loading = false;
  bool createAccount = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    createAccount ? 'Create Account' : 'Sign in to Account',
                    style: TextStyle(
                      color: createAccount ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Switch(
                        value: createAccount,
                        activeColor: Colors.green,
                        onChanged: (bool value) {
                          setState(() {
                            createAccount = value;
                          });
                        },
                        inactiveThumbColor: Colors.blue,
                        inactiveTrackColor: Colors.blue.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Enter account username'),
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
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleSignIn,
              child: const Text("Sign in with Google"),
            ),
          ],
        ),
      ),
    );
  }

  // Sets up the data to be checked in the database.
  void saveInfo() async {
    final String username = _username.text;
    final String password = _password.text;

    // Will only leave page if data is entered,
    // otherwise nothing happens when "save" button is clicked
    if (username.isNotEmpty || password.isNotEmpty) {
      _showSnackBar("Checking accounts...");

      if (createAccount) {
        await _checkTakenName(username);
      } else {
        await _checkAccount(username, password);
      }
    } else {
      _showSnackBar("Enter a username and password.");
    }
  }

  // Searches through the 'accounts' section to see if any account
  // matches the provided userLongName and password.
  Future _checkAccount(String userShortName, String password) async{
    var collection = FirebaseFirestore.instance.collection('accounts');
    var querySnapshot = await collection.get();

    for (var doc in querySnapshot.docs) {
      // Check if the document contains the field and its value
      if (doc.data().containsKey('userShortName') &&
          doc.data()['userShortName'] == userShortName &&
          doc.data().containsKey('password') &&
          doc.data()['password'] == password) {
        account = Account.fromMap(doc.data());
        // Exits form.
        Navigator.pop(context, account);
      }
    }
    if (account == null) {
      _showSnackBar('No matching account found for ${_username.text}. Create account?');
      setState(() {
        createAccount = true;
      });
    }
  }

  Future _checkTakenName(String userShortName) async{
    var collection = FirebaseFirestore.instance.collection('accounts');
    var querySnapshot = await collection.get();
    bool matchingName = false;

    for (var doc in querySnapshot.docs) {
      // Check if the document contains the field and its value
      if (doc.data().containsKey('userShortName') &&
          doc.data()['userShortName'] == userShortName) {
        matchingName = true;
        _showSnackBar('Username already taken!');
      }
    }
    if (matchingName == false) {
      _saveAccount(userShortName, userShortName, _password.text);
    }
  }

  Future _saveAccount(String userLongName, String userShortName, String? password) async {
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
        'followingAccs': <DocumentReference>[]
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

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      GoogleSignInAccount? currentUser = _googleSignIn.currentUser;

      if (currentUser != null) {
        _username.text = currentUser.displayName!;
        //_checkAccount(currentUser.displayName!);
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
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

