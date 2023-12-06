import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:lab_extension/tweet_list.dart';
import 'package:lab_extension/sign_in_form.dart';
import 'package:lab_extension/new_acc_form.dart';
import 'package:lab_extension/account.dart';
import 'package:lab_extension/nav_bar.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  // Ensures there's a connection to the database before the stream begins
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot){
          if (snapshot.hasError){
            print("Error initializing Firebase");
            return Container();
          }
          if (snapshot.connectionState == ConnectionState.done){
            print ("Successfully connected to Firebase");
            return MaterialApp(
              title: "Cloud Storage",
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              themeMode: ThemeMode.dark,
              //home: TweetList(title: "Home page", account: account)
              home: const CheckIfLoggedIn(),
            );
          }
          else{
            return const CircularProgressIndicator();
          }
        }
    );
  }
}

class CheckIfLoggedIn extends StatefulWidget {
  const CheckIfLoggedIn({super.key});

  @override
  State<CheckIfLoggedIn> createState() => _CheckIfLoggedInState();
}

class _CheckIfLoggedInState extends State<CheckIfLoggedIn> {
  final _signInPages = [const SignInForm(), const NewAccForm()];
  final _signInController = PageController();

  int _selectedItem = 0;
  int _homeNumber = 0;
  /*
  Account account = Account.fromMap({
    'userShortName': "GoogaBooga",
    'userLongName': "YeehawCowboy420",
    'password': "password123",
  });
   */

  Account? account;

  @override
  void initState() {
    super.initState();
    if (account == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final updatedAccount = await showDialog<Account?>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return PageView(
              onPageChanged: (index) {
                setState(() {
                  _selectedItem = index;
                });
              },
              controller: _signInController,
              children: _signInPages,
            );
          },
        );

        if (updatedAccount != null) {
          setState(() {
            account = updatedAccount;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (account != null) {
      final homePages = [
        TweetList(account: account!, following: false),
        TweetList(account: account!, following: true),
      ];
      final homeController = PageController();

      return Scaffold(
        body: Stack(
          children: [
            Scaffold(
              drawer: NavBar(account: account!),
              appBar: AppBar(
                title: Text(_homeNumber == 0 ? 'For you' : 'Following'),
              ),
              body: PageView(
                onPageChanged: (index) {
                  setState(() {
                    print(index);
                    _homeNumber = index;
                  });
                },
                controller: homeController,
                children: homePages,
              ),
            ),
          ],
        ),
      );
    }
    return const Scaffold(
      body: Center(
        child: Text(
          'Welcome to not-Twitter!',
          textAlign: TextAlign.center, // Center align the text
          style: TextStyle(
            fontSize: 24.0, // Adjust the font size as needed
            fontWeight: FontWeight.bold, // Adjust the font weight if desired
            // Add more text styling properties as needed
          ),
        ),
      ),
    );
  }
}