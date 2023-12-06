import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab_extension/tweet.dart';
import 'package:lab_extension/display_tweet.dart';
import 'package:lab_extension/tweet_form.dart';
import 'package:lab_extension/account.dart';

class TweetList extends StatefulWidget {
  TweetList({Key? key, required this.account,
    required this.following}) : super(key: key);

  Account account;
  bool following;

  @override
  State<TweetList> createState() => _TweetListState();
}

class _TweetListState extends State<TweetList> {
  // Holds the list of sids and grades locally (ids not required locally)
  // Needed to send the sid and grade data to the pop-up form when editing
  late String currentShortName;
  late String currentLongName;

  @override
  void initState() {
    super.initState();
    currentShortName = widget.account.userShortName!;
    currentLongName = widget.account.userLongName!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildTweetFeed(context),
      floatingActionButton: FloatingActionButton(
        onPressed:() {
          _addTweet(context);
        },
        tooltip: "Add",
        child: const Icon(Icons.add),
      ),
    );
  }

  _addTweet(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TweetForm(
        account: widget.account,
      )
    ));
  }

  Widget _buildTweet(BuildContext context, Tweet tweet) {
    return DisplayTweet(
      tweet: tweet,
      viewAccount: widget.account,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            !widget.following ? 'No posts found!' : 'Try following some people...',
            style: const TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 10.0),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getStream() {
    print("following? ${widget.following}");

    if (widget.following) {
      if (widget.account.followingAccs!.isEmpty) {
        return FirebaseFirestore.instance
            .collection('tweets')
            .where('userShortName', isEqualTo: '__INVALID__') // A field that doesn't exist, ensuring no documents match
            .snapshots();
      } else {
        return FirebaseFirestore.instance
            .collection('tweets')
            .where('userShortName', whereIn: widget.account.followingAccs)
            .orderBy('timestamp', descending: true) // Order by 'timestamp' field
            .snapshots();
      }
    } else {
      return FirebaseFirestore.instance
          .collection('tweets')
          .orderBy('timestamp', descending: true) // Order by 'timestamp' field
          .snapshots();
    }
  }

  // Returns a list of Tweet tiles that updates every time the database is
  // updated.
  // Note - the list will also update when a tile is tapped (to update the tile
  // colors), and when the edit button is selected.
  Widget _buildTweetFeed(BuildContext context){
    return StreamBuilder(
      stream: _getStream(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if (!snapshot.hasData || snapshot.data.docs.length == 0){
          print("Data is missing from buildTweetList");
          return _buildEmptyState();
        }
        print("Found data!");
        print("Length: ${snapshot.data.docs.length}");
        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot tweetDoc = snapshot.data!.docs[index];
            Tweet tweet = Tweet.fromMap(tweetDoc.data() as Map<String, dynamic>);
            return Column(
              children: [
                _buildTweet(context, tweet),
                const SizedBox(height: 10),
                const Divider(
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
              ]
            );
          },
        );
      }
    );
  }
}
