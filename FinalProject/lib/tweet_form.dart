import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/tweet.dart';
import 'package:final_project/account.dart';
import 'dart:math';

class TweetForm extends StatefulWidget {
  const TweetForm({Key? key, required this.account}) : super(key: key);

  final Account account;

  @override
  State<TweetForm> createState() => _TweetFormState();
}

class _TweetFormState extends State<TweetForm> {
  final TextEditingController _description = TextEditingController();
  final TextEditingController _imageURL = TextEditingController();

  bool loading = false;
  Tweet? tweet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Tweet"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Tweet Description'),
            ),
            TextFormField(
              controller: _imageURL,
              decoration: const InputDecoration(labelText: 'Image link'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                saveTweet();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
  void saveTweet() async {
    setState(() {
      loading = true; // Set loading to true to show CircularProgressIndicator
    });

    final String description = _description.text;
    final String imageURL = _imageURL.text;

    // Will only leave page if data is entered,
    // otherwise nothing happens when "save" button is clicked
    if (description.isNotEmpty) {
      await _saveTweet(description, imageURL);
    } else {
      _showSnackBar("Enter a description.");
      setState(() {
        loading = false; // Reset loading to false on error
      });
    }
  }

  // Gets a new location for the tweet, updates the tweet with it's own
  // location, then adds it to the database. It is timestamped at the time
  // it is created, and comments/retweets/likes are all randomized.
  // Can be set to 0 if needs to be realistic, but having it originally
  // randomized makes it seem like other people are using the app.
  // Still works even if another account is using the app at the same time.
  Future _saveTweet(String description, String imageURL) async{
    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection('tweets').doc();
      tweet = Tweet.fromMap({
        'posterReference': widget.account.accReference,
        'tweetReference': docRef,
        'userShortName': widget.account.userShortName,
        'userLongName': widget.account.userLongName,
        'description': description,
        'imageURL': imageURL,
        'pfpURL': widget.account.imageURL,
        'numComments': Random().nextInt(50),
        'numRetweets': Random().nextInt(100),
        'numLikes': Random().nextInt(100),
      });
      await docRef.set(tweet!.toMap());
      widget.account.myPosts.add(docRef);
      await widget.account.accReference?.update({'myPosts': FieldValue.arrayUnion([docRef])});
      print("Account added!");
      setState(() {
        loading = false; // Reset loading to false after successful save
      });
      Navigator.pop(context, tweet);
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