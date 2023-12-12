import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:final_project/tweet.dart';
import 'package:final_project/account.dart';
import 'package:final_project/profile_form.dart';

// Used to provide a frame for a single tweet.
class DisplayTweet extends StatefulWidget {
  // Needs the tweet information, and the signed-in account (the viewer).
  DisplayTweet({Key? key, required this.tweet,
    required this.viewAccount}) : super(key: key);

  final Tweet tweet;
  Account viewAccount; // Signed-in account.

  @override
  State<DisplayTweet> createState() => _DisplayTweetState();
}

class _DisplayTweetState extends State<DisplayTweet> {

  // Will retrieve if the current post has been liked/retweeted/hidden
  // by the current user.
  late bool isLiked;
  late bool isRetweeted;
  late bool isHidden;

  late Account? userInfo;

  String userLongName = "";
  String userShortName = "";
  String? pfpURL;

  bool loadingData = true;

  void fetchUserInfo() async {
    Account? userInfoData = await getUserInfo(widget.tweet.posterReference!.id);
    if (mounted) {
      setState(() {
        if (userInfoData != null) {
          userInfo = userInfoData;
          userLongName = userInfo!.userLongName!;
          userShortName = userInfo!.userShortName!;
          pfpURL = userInfo!.imageURL;
          loadingData = false;
        }
      });
    }
  }

  // Functions to handle likes, retweets, and hiding posts.
  void _handleLike() {
    setState(() {
      isLiked = !isLiked;
      widget.viewAccount.updateLikes(widget.tweet.tweetReference!);
      widget.tweet.updateLike(isLiked);
    });
  }

  void _handleRetweet() {
    setState(() {
      isRetweeted = !isRetweeted;
      widget.viewAccount.updateRetweets(widget.tweet.tweetReference!);
      widget.tweet.updateRetweet(isRetweeted);
    });
  }

  void _handleHidden() {
    setState(() {
      isHidden = !isHidden;
      widget.viewAccount.updateHidden(widget.tweet.tweetReference!);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Retrieves if the signed-in user has liked/retweeted/hidden this
    // post.
    fetchUserInfo();
    isLiked = widget.viewAccount.checkLikes(widget.tweet.tweetReference!);
    isRetweeted = widget.viewAccount.checkRetweets(widget.tweet.tweetReference!);
    isHidden = widget.viewAccount.checkHidden(widget.tweet.tweetReference!);

    late int colorIndex;
    if (userLongName != "") {
      colorIndex = userLongName.codeUnitAt(0) % Colors.primaries.length;
    } else {
      colorIndex = 0;
    }

    // Doesn't display hidden tweets!
    if (isHidden) {
      return Container();
    } else if (loadingData) {
      return const CircularProgressIndicator();
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // If the poster has a pfp, displays that pfp. Otherwise,
          // displays a Google-style circle and letter.
          pfpURL != null
              ? CircleAvatar(
            backgroundImage: NetworkImage(pfpURL!),
            radius: 25.0,
          ) : CircleAvatar(
            backgroundColor: Colors.primaries[colorIndex],
            radius: 25.0,
            child: Text(
              userLongName[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          const SizedBox(width: 10.0),

          // Does magic to shorten people's user name if it's too long,
          // and replaces text with "..." if needed.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onTap: () {
                          if (!loadingData) {
                            _openProfile(userInfo!, widget.viewAccount);
                          }
                        },
                        child: Text(
                          userLongName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        ' @$userShortName',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                        // If too long, will replace text with "..."
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text(
                      ' · ',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const Icon(
                      Icons.access_time,
                      size: 14.0,
                      color: Colors.grey,
                    ),
                    Text(
                      formatTimeDifference(widget.tweet.timestamp),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),

                    // Code to hide a tweet.
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Hide Tweet'),
                                content: const Text(
                                    'Are you sure you want to hide this tweet?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _handleHidden();
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Hide'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Icon(
                          Icons.expand_more,
                          size: 20.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.tweet.description!,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 10.0),

                // If there is no imageURL, it will be saved to the database
                // as "". This is how no provided image is detected.
                if (widget.tweet.imageURL != "")
                  Column(
                    children: [
                      const SizedBox(height: 10.0),
                      Image.network(
                        widget.tweet.imageURL!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Comments icon, then number of comments
                    Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 20.0,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(widget.tweet.numComments.toString()),
                      ],
                    ),
                    // Likes icon, then number of likes
                    // Can be clicked on!
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            _handleRetweet();
                          },
                          child: Icon(
                            isRetweeted ? Icons.repeat : Icons.repeat,
                            size: 20.0,
                            color: isRetweeted ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(widget.tweet.numRetweets.toString()),
                      ],
                    ),
                    // Retweets icon, then number of retweets
                    // Can be clicked on!
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            _handleLike();
                          },
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 20.0,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(widget.tweet.numLikes.toString()),
                      ],
                    ),
                    const Icon(
                        Icons.bookmark_border,
                        size: 20.0,
                        color: Colors.grey
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Future _openProfile(Account account, Account otherAccount) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProfileForm(account: account, otherAccount: otherAccount)
    ));
  }
}

// Calculates the time since the Tweet was posted.
String formatTimeDifference(DateTime dateTime) {
  Duration difference = DateTime.now().difference(dateTime);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}s';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h';
  } else if (difference.inDays < 30) {
    return '${difference.inDays}d';
  } else if (difference.inDays < 365) {
    return '${difference.inDays ~/ 30}m';
  } else {
    return '${difference.inDays ~/ 365}y';
  }
}

Future<Account?> getUserInfo(String posterReference) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
        .collection('accounts') // Replace 'users' with your collection name
        .doc(posterReference)
        .get();

    if (userSnapshot.exists) {
      return Account.fromMap(userSnapshot);
    } else {
      return null; // User with the given accountId does not exist
    }
  } catch (e) {
    print('Error fetching user info: $e');
    return null;
  }
}

