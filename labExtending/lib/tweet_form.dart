import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab_extension/tweet.dart';

class TweetForm extends StatefulWidget {
  const TweetForm({Key? key, required this.title, this.reference,
    this.tweet, required this.userShortName, required this.userLongName}) : super(key: key);

  final String title; // Will be "Edit data" or "Add data"
  final DocumentReference? reference; // If editing data, will hold reference to that data
  final Tweet? tweet;
  final String? userShortName;
  final String? userLongName;

  @override
  State<TweetForm> createState() => _TweetFormState();
}

class _TweetFormState extends State<TweetForm> {
  final TextEditingController _description = TextEditingController();
  final TextEditingController _imageURL = TextEditingController();

  bool success = false;
  Tweet? newTweet;

  @override
  void initState() {
    super.initState();
    // If adding data, no text will be displayed (only displays data being edited)
    if (widget.tweet != null) {
      Map<String, dynamic> data = widget.tweet!.toMap();
      _description.text = data['description']!;
      _imageURL.text = data['imageURL']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                if (_description.text.isNotEmpty) {
                  Navigator.pop(context, newTweet);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
  void saveTweet() async {
    final String description = _description.text;
    final String imageURL = _imageURL.text;

    // Will only leave page if data is entered,
    // otherwise nothing happens when "save" button is clicked
    if (description.isNotEmpty) {
      print("Adding a new entry...");

      if (widget.tweet == null) {
        newTweet = Tweet.fromMap({
          'userShortName': widget.userShortName,
          'userLongName': widget.userLongName,
          'description': description,
          'imageURL': imageURL,
        });
        newTweet?.timestamp = DateTime.now();
      } else {
        newTweet = widget.tweet;
        newTweet?.timestamp = DateTime.now();
      }

      final Map<String, dynamic> data = newTweet!.toMap();
      await _addToDb(data);
    } else {
      print("Enter a description!");
    }
  }

  Future _addToDb(data) async{
    // If there's no reference, it creates a new document
    // Otherwise, it replaces the data at the reference
    if (widget.reference == null) {
      await FirebaseFirestore.instance.collection('tweets').doc().set(data);
      print("Added data: $data");
    } else {
      await widget.reference!.set(data);
      print("Replaced ${widget.reference} with data: $data");
    }
  }
}