import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/account.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']); // Scopes define the required access
  // Account that will be found in the database.
  Account? account;

  bool loading = false;

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      GoogleSignInAccount? currentUser = _googleSignIn.currentUser;

      if (currentUser != null) {

        //_checkAccount(currentUser.displayName!);
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
  }

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      // Handle user sign-in changes
      // You can perform actions here when the user signs in or out
    });
    _googleSignIn.signInSilently(); // Tries to sign in silently on app launch
  }

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
      _showSnackBar('No matching account found for ${_userLongName.text}. Create account?');
    }
  }

  Future _checkShortName(String userShortName) async{
    var collection = FirebaseFirestore.instance.collection('accounts');
    var querySnapshot = await collection.get();

    for (var doc in querySnapshot.docs) {
      // Check if the document contains the field and its value
      if (doc.data().containsKey('userShortName') &&
          doc.data()['userShortName'] == userShortName) {
        account = Account.fromMap(doc.data());
        // Exits form.
        Navigator.pop(context, account);
      }
    }
    if (account == null) {
      _saveAccount(userShortName, userShortName, null);
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

