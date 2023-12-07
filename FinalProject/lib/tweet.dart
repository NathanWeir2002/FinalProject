import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Tweet{
  DocumentReference? posterReference;
  DocumentReference? tweetReference;
  String? userLongName;
  String? userShortName;
  String? description;
  String? imageURL;
  String? pfpURL;
  DateTime timestamp = DateTime.now();

  int numComments = Random().nextInt(50);
  int numRetweets = Random().nextInt(100);
  int numLikes = Random().nextInt(150);

  Tweet.fromMap(var map){
    posterReference = map['posterReference'];
    tweetReference = map['tweetReference'];
    userLongName = map['userLongName'];
    userShortName = map['userShortName'];
    description = map['description'];
    imageURL = map['imageURL'];
    pfpURL = map['pfpURL'];
    timestamp = (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    numComments = map['numComments'] ?? Random().nextInt(50);
    numRetweets = map['numRetweets'] ?? Random().nextInt(100);
    numLikes =  map['numLikes'] ?? Random().nextInt(150);
  }

  Map<String, dynamic> toMap() {
    return {
      'posterReference': posterReference,
      'tweetReference': tweetReference,
      'userLongName': userLongName,
      'userShortName': userShortName,
      'description': description,
      'imageURL': imageURL,
      'pfpURL': pfpURL,
      'timestamp': timestamp,
      'numComments': numComments,
      'numRetweets': numRetweets,
      'numLikes': numLikes,
    };
  }

  void updateLike(bool isLiked) {
    tweetReference?.update({
      'numLikes': isLiked ? numLikes + 1 : numLikes - 1,
    });
  }

  void updateRetweet(bool isRetweeted) {
    tweetReference?.update({
      'numRetweets': isRetweeted ? numRetweets + 1 : numRetweets - 1,
    });
  }
}