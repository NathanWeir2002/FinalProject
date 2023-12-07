import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:final_project/tweet_list.dart';
import 'package:final_project/sign_in_form.dart';
import 'package:final_project/new_acc_form.dart';
import 'package:final_project/account.dart';
import 'package:final_project/nav_bar.dart';

void main() async {
  runApp(const MyApp());
}

// Gets connection with Firebase before starting app.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize connection
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

              // Forces the app to open a sign-in page before starting.
              home: const CheckIfLoggedIn(),
            );
          }
          else{

            // Displays while connecting to Firebase
            return MaterialApp(home: defaultPage("Connecting..."));
          }
        }
    );
  }
}

// Forces the user to either sign in or create an account.
// Swipe to move between screens.
class CheckIfLoggedIn extends StatefulWidget {
  const CheckIfLoggedIn({super.key});

  @override
  State<CheckIfLoggedIn> createState() => _CheckIfLoggedInState();
}

class _CheckIfLoggedInState extends State<CheckIfLoggedIn> {
  // Holds sign in page and new account page
  final _signInPages = [
    const SignInForm(),
    const NewAccForm()
  ];
  // Holds which page we are on
  final _signInController = PageController();

  // Holds the page index for the sign in/create account
  int _signInNumber = 0;
  // Holds the page index for the home pages
  int _homeNumber = 0;

  // Account that is currently signed in
  Account? account;

  //Forces user to either sign in or create account
  @override
  void initState() {
    super.initState();
    // It will always be null to start, code provides functionality to
    // instead hard-code account information to be uploaded
    if (account == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Pull up sign in/create account pages, returns account
        // that is currently signed into or created.
        final updatedAccount = await showDialog<Account?>(
          // Doesn't let you leave until you are signed in
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            // PageView - can swipe between pages
            return PageView(
              onPageChanged: (index) {
                setState(() {
                  _signInNumber = index;
                });
              },
              // Controls each page
              controller: _signInController,
              children: _signInPages,
            );
          },
        );

        // Updates signed-in account.
        if (updatedAccount != null) {
          setState(() {
            account = updatedAccount;
          });
        }
      });
    }
  }

  // Once the account is signed into, starts homepage.
  @override
  Widget build(BuildContext context) {
    if (account != null) {
      // following: indicates whether or not this is the "following" tab,
      // or if it's a standard "For You" page with all posts.
      final homePages = [
        TweetList(account: account!, following: false),
        TweetList(account: account!, following: true),
      ];
      final homeController = PageController();

      // Creates the home page.
      return Scaffold(
        body: Stack(
          children: [
            Scaffold(
              // Swipe from left side of the screen to see the cool drawer!
              drawer: NavBar(account: account!),
              // Depending on page, changes the page title.
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
    // This will display once the app has connected to Firebase,
    // but hasn't signed in. It will not display for long - it's just a
    // background while the sign-in page loads.
    return defaultPage('Welcome to not-Twitter!');
  }
}

// A default-looking page to return to. Displays whatever text is inputted
// in the middle of the screen.
Widget defaultPage(String text) {
  return Scaffold(
    body: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          // Add more text styling properties as needed
        ),
      ),
    ),
  );
}