import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/tweet.dart';
import 'package:final_project/display_tweet.dart';
import 'package:final_project/account.dart';
import 'package:final_project/settings.dart';

// If otherAccount is not initialized = "account" is the signed-in account
// If it is, "otherAccount" is the signed-in account, and "account" is the
// account being viewed.
class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key, required this.account, this.otherAccount}) : super(key: key);

  final Account account;
  final Account? otherAccount;

  @override
  State<ProfileForm> createState() => _ProfileForm();
}

class _ProfileForm extends State<ProfileForm> with SingleTickerProviderStateMixin {
  late Color pfp;
  late Color bg;

  late bool viewingAccount;
  bool isFollowing = false;
  @override
  void initState() {
    super.initState();
    int colorIndex = widget.account.userLongName!.codeUnitAt(0) % Colors.primaries.length;
    pfp = Colors.primaries[colorIndex];
    bg = darken(pfp);
    if (widget.otherAccount == null) {
      viewingAccount = false;
    } else {
      viewingAccount = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (viewingAccount) {
      isFollowing =  widget.otherAccount!.followingAccs.contains(widget.account.accReference);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.account.imageURL != null ? CircleAvatar(
                  backgroundImage: NetworkImage(widget.account.imageURL!),
                  radius: 75.0/2,
                ) : CircleAvatar(
                  backgroundColor: pfp,
                  radius: 75.0/2,
                  child: Text(
                    widget.account.userLongName![0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Add spacing between image and text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.account.userLongName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Spacing between username and userShortName
                      Text(
                        '@${widget.account.userShortName!}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (viewingAccount) {
                      _handleFollow();
                    } else {
                      _openSettings(context, widget.account);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    // Adjust button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8.0), // Match the container's border radius
                    ),
                    elevation: 0,
                    // Set button elevation to 0 to remove default shadow
                    backgroundColor: isFollowing? Colors.green : Colors.blue,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        viewingAccount ? isFollowing ? 'Following! ' : 'Follow ' : 'Settings ',
                        style: const TextStyle(fontSize: 16, color: Colors.white,),
                      ),
                      Icon(viewingAccount ? Icons.person_add : Icons.settings),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Container(
              alignment: FractionalOffset.topLeft,
              child: Text(
                '@${widget.account.userShortName} Posts and Retweets',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            const Divider(color: Colors.grey,),
            Expanded(
              child: _buildTweetFeedType(context, widget.account.myPosts, widget.account.retweetedPosts),
            ),
          ],
        ),
      )
    );
  }

  void _handleFollow() async {
    if (isFollowing) {
      var docRef = widget.account.accReference;
      setState(() {
        widget.otherAccount?.followingAccs.remove(docRef);
      });
      await widget.otherAccount?.accReference?.update({'followingAccs': FieldValue.arrayRemove([docRef])});

    } else {
      var docRef = widget.account.accReference!;
      setState(() {
        widget.otherAccount?.followingAccs.add(docRef);
      });
      await widget.otherAccount?.accReference?.update({'followingAccs': FieldValue.arrayUnion([docRef])});
    }

  }

  // Creates the tweet.
  Widget _buildTweet(BuildContext context, Tweet tweet) {
    return DisplayTweet(
      tweet: tweet,
      viewAccount: viewingAccount ? widget.otherAccount! : widget.account,
    );
  }

  // A default page if no tweets are found in both the "For You" and
  // "Following" pages. Will update depending on which page it's on.
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No tweets found...',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 10.0),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildTweetFeedType(BuildContext context, List<dynamic> posts, List<dynamic> morePosts) {
    return StreamBuilder(
      stream: _getStream(posts, morePosts),
      // Use a function to get the stream for liked tweets
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData || snapshot.data.docs.length == 0) {
          print("No tweets found.");
          return _buildEmptyState(); // You can define your empty state widget
        }
        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot likedTweetDoc = snapshot.data!.docs[index];
            Tweet likedTweet = Tweet.fromMap(
              likedTweetDoc.data() as Map<String, dynamic>,
            );
            return Column(
              children: [
                _buildTweet(context, likedTweet),
                const SizedBox(height: 10),
                const Divider(
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getStream(List<dynamic> somethingPosts, List<dynamic> somethingOtherPosts) {
    List<DocumentReference> documentReferences1 = somethingPosts.cast<DocumentReference>();
    List<DocumentReference> documentReferences2 = somethingOtherPosts.cast<DocumentReference>();

    List<String> allPostIDs = [];
    allPostIDs.addAll(documentReferences1.map((ref) => ref.id).toList());
    allPostIDs.addAll(documentReferences2.map((ref) => ref.id).toList());

    if (allPostIDs.isEmpty) {
      return FirebaseFirestore.instance
          .collection('tweets')
          .where('userShortName', isEqualTo: '__INVALID__') // A field that doesn't exist, ensuring no documents match
          .snapshots();
    }
    return FirebaseFirestore.instance
        .collection('tweets')
        .where(FieldPath.documentId, whereIn: allPostIDs)
        .snapshots();
  }
}

// Darkens a provided color by a percentage amount.
Color darken(Color color, [double amount = .2]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

// Retrieves the form for the settings.
Future _openSettings(BuildContext context, Account account) async {
  await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SettingsForm(account: account)
  ));
}
