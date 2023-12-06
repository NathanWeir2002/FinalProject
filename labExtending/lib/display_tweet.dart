import 'package:lab_extension/tweet.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class DisplayTweet extends StatefulWidget {
  const DisplayTweet({Key? key, required this.tweet}) : super(key: key);

  final Tweet tweet;

  @override
  State<DisplayTweet> createState() => _DisplayTweetState();
}

class _DisplayTweetState extends State<DisplayTweet> {
  void _handleRetweet() {
    setState(() {
      widget.tweet.isRetweeted = !widget.tweet.isRetweeted;
      widget.tweet.updateRetweet(widget.tweet.isRetweeted);
    });
  }

  void _handleLike() {
    setState(() {
      widget.tweet.isLiked = !widget.tweet.isLiked;
      widget.tweet.updateLike(widget.tweet.isLiked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildTweet(context, widget.tweet, _handleRetweet, _handleLike);
  }
}

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

Widget buildTweet(BuildContext context, Tweet tweet, VoidCallback handleRetweet, VoidCallback handleLike) {
  var generatedColor = Random().nextInt(Colors.primaries.length);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        backgroundColor: Colors.primaries[generatedColor],
        radius: 25.0,
        child: Text(
          // Uses the first letter of userLongName it in the user's icon
          tweet.userLongName![0],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ),
      const SizedBox(width: 10.0),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    tweet.userLongName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    // If too long, will replace text with "..."
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    ' @${tweet.userShortName}',
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
                  formatTimeDifference(tweet.timestamp),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),

                // UNDER CONSTRUCTION
                // Pop-up functionality works! Remove tweet functionality does not.
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
                                  Navigator.of(context).pop();
                                  // CALL REMOVE FUNCTION HERE
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
              tweet.description!,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            if (tweet.imageURL != "")
              Column(
                children: [
                  const SizedBox(height: 10.0),
                  Image.network(
                    tweet.imageURL!,
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
                    Text(tweet.numComments.toString()),
                  ],
                ),
                // Likes icon, then number of likes
                // Can be clicked on!
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        handleRetweet();
                      },
                      child: Icon(
                        tweet.isRetweeted ? Icons.repeat : Icons.repeat,
                        size: 20.0,
                        color: tweet.isRetweeted ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(tweet.numRetweets.toString()),
                  ],
                ),
                // Retweets icon, then number of retweets
                // Can be clicked on!
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        handleLike();
                      },
                      child: Icon(
                        tweet.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20.0,
                        color: tweet.isLiked ? Colors.red : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(tweet.numLikes.toString()),
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

