import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/tweet.dart';
import 'package:final_project/display_tweet.dart';
import 'package:final_project/tweet_form.dart';
import 'package:final_project/account.dart';

// Creates the list of tweets. This is synched to the Database, so it updates
// in real-time.
class TweetList extends StatefulWidget {
  TweetList({Key? key, required this.account,
    required this.following}) : super(key: key);

  Account account;
  bool following;

  @override
  State<TweetList> createState() => _TweetListState();
}

class _TweetListState extends State<TweetList> {
  // Needed for creating tweets! This does mean that if you change your name,
  // it won't be reflected in the database. Oh, well.
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

  // Opens tweet form to add tweet to database.
  _addTweet(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TweetForm(
        account: widget.account,
      )
    ));
  }

  // Creates the tweet.
  Widget _buildTweet(BuildContext context, Tweet tweet) {
    return DisplayTweet(
      tweet: tweet,
      viewAccount: widget.account,
    );
  }

  // A default page if no tweets are found in both the "For You" and
  // "Following" pages. Will update depending on which page it's on.
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

  // Gets a stream of all tweets. Updates in real-time.
  Stream<QuerySnapshot> _getStream() {
    print("following? ${widget.following}");

    // If on "Following" page
    if (widget.following) {
      if (widget.account.followingAccs!.isEmpty) {
        // If user is not following anyone, searches the database for
        // snapshots that aren't there (will return 0 tweets). Please
        // don't set your userShortName to __INVALID__ to be a dick.
        return FirebaseFirestore.instance
            .collection('tweets')
            .where('userShortName', isEqualTo: '__INVALID__') // A field that doesn't exist, ensuring no documents match
            .snapshots();
      } else {
        // If user is following someone, get tweets found in followingAccs
        // array.
        return FirebaseFirestore.instance
            .collection('tweets')
            .where('userShortName', whereIn: widget.account.followingAccs)
            .orderBy('timestamp', descending: true) // Order by 'timestamp' field
            .snapshots();
      }
    } else {
      // Just returns all tweets - is on the "For You" page.
      return FirebaseFirestore.instance
          .collection('tweets')
          .orderBy('timestamp', descending: true) // Order by 'timestamp' field
          .snapshots();
    }
  }

  // Returns a list of Tweet tiles that updates every time the database is
  // updated.
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
