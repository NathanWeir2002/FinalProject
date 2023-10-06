import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(Twitter());

class Twitter extends StatelessWidget {

  // List of all tweets, with information
  // Randomizes comments, retweets, and likes
  List<TweetWidget> feedList = [
    TweetWidget(
      userShortName: 'Doglover123',
      userLongName: 'Bob Jenkins',
      description: 'Hey guys! Check out this awesome dog!',
      imageURL: 'https://images.unsplash.com/photo-1517849845537-4d257902454a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1035&q=80',
      numComments: Random().nextInt(50),
      numRetweets: Random().nextInt(100),
      numLikes: Random().nextInt(500),
    ),
    TweetWidget(
      userShortName: 'REALLY_LONG_SHORTNAME',
      userLongName: 'This Dog Owners userLongName is really long!!',
      description: 'My dog is so cool.',
      imageURL: 'https://thumbs.dreamstime.com/b/drunk-dog-drinking-cocktail-cool-french-bulldog-cheering-toast-martini-drink-looking-up-to-owner-isolated-white-150129563.jpg',
      numComments: Random().nextInt(50),
      numRetweets: Random().nextInt(100),
      numLikes: Random().nextInt(500),
    ),
    TweetWidget(
      userShortName: 'SwagBones',
      userLongName: 'Goongis Pizzaman',
      description: 'My dog is the best! My dog is the best! My dog is the best! My dog is the best! My dog is the best! My dog is the best!',
      imageURL: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fGRvZ3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
      numComments: Random().nextInt(50),
      numRetweets: Random().nextInt(100),
      numLikes: Random().nextInt(500),
    ),
  ];

  /* UNDER CONSTRUCTION
  void removeTweet(TweetWidget tweet) {
    if (feedList.contains(tweet)) {
      feedList.remove(tweet);
    }
  }
   */

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lab 03 and 04'),
        ),
        body: ListView(
          padding: EdgeInsets.all(15.0),
          children: [
            for (var tweet in feedList)
              Column(
                children: [
                  TweetWidget(
                    userShortName: tweet.userShortName,
                    userLongName: tweet.userLongName,
                    description: tweet.description,
                    imageURL: tweet.imageURL,
                    numComments: tweet.numComments,
                    numRetweets: tweet.numRetweets,
                    numLikes: tweet.numLikes,
                  ),
                  SizedBox(height: 10),
                  Divider(
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                ]
              )
          ],
        ),
      ),
    );
  }
}

class TweetWidget extends StatefulWidget {
  final String userShortName;
  final String userLongName;
  final String description;
  final String imageURL;

  int numComments;
  int numRetweets;
  int numLikes;

  //UNDER CONSTRUCTION
  //final Function(TweetWidget) removeTweet;

  TweetWidget({
    required this.userShortName,
    required this.userLongName,
    required this.description,
    required this.imageURL,
    required this.numComments,
    required this.numRetweets,
    required this.numLikes,
  });

  @override
  _TweetWidgetState createState() => _TweetWidgetState();
}

class _TweetWidgetState extends State<TweetWidget> {

  // Randomizes color of icons
  var generatedColor = Random().nextInt(Colors.primaries.length);

  bool isLiked = false;
  bool isRetweeted = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.primaries[generatedColor],
          child: Text(
            // Uses the first letter of userLongName it in the user's icon
            widget.userLongName[0],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          radius: 25.0,
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      widget.userLongName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      // If too long, will replace text with "..."
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      ' @${widget.userShortName}',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      // If too long, will replace text with "..."
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Icon(
                    Icons.access_time,
                    size: 14.0,
                    color: Colors.grey,
                  ),
                  Text(
                    '2m',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Spacer(),

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
                              title: Text('Hide Tweet'),
                              content: Text('Are you sure you want to hide this tweet?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // CALL REMOVE FUNCTION HERE
                                  },
                                  child: Text('Hide'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.expand_more,
                        size: 20.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                widget.description,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 10.0),
              Image.network(
                widget.imageURL,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Comments icon, then number of comments
                  Container(
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 20.0,
                          color: Colors.grey,
                        ),
                        SizedBox(width:5),
                        Text(widget.numComments.toString()),
                      ],
                    ),
                  ),
                  // Likes icon, then number of likes
                  // Can be clicked on!
                  Container(
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isRetweeted = !isRetweeted;
                              if (isRetweeted) {
                                widget.numRetweets++;
                              } else {
                                widget.numRetweets--;
                              }
                            });
                          },
                          child: Icon(
                            isRetweeted ? Icons.repeat : Icons.repeat,
                            size: 20.0,
                            color: isRetweeted ? Colors.green : Colors.grey,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(widget.numRetweets.toString()),
                      ],
                    ),
                  ),
                  // Retweets icon, then number of retweets
                  // Can be clicked on!
                  Container(
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isLiked = !isLiked;
                              if (isLiked) {
                                widget.numLikes++;
                              } else {
                                widget.numLikes--;
                              }
                            });
                          },
                          child: Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20.0,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(widget.numLikes.toString()),
                      ],
                    ),
                  ),
                  Icon(
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