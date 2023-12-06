import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Tweet{
  String? userShortName;
  String? userLongName;
  String? description;
  String? imageURL;
  DateTime timestamp = DateTime.now();

  int numComments = Random().nextInt(50);
  int numRetweets = Random().nextInt(100);
  int numLikes = Random().nextInt(150);

  bool isRetweeted = false;
  bool isLiked = false;

  DocumentReference? reference;

  Tweet.fromMap(var map, {this.reference}){
    userShortName = map['userShortName'];
    userLongName = map['userLongName'];
    description = map['description'];
    imageURL = map['imageURL'];
    timestamp = (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    numComments = map['numComments'] ?? Random().nextInt(50);
    numRetweets = map['numRetweets'] ?? Random().nextInt(100);
    numLikes =  map['numLikes'] ?? Random().nextInt(150);
    isRetweeted = map['isRetweeted'] ?? false;
    isLiked = map['isLiked'] ?? false;
  }

  Map<String, dynamic> toMap() {
    return {
      'userShortName': userShortName,
      'userLongName': userLongName,
      'description': description,
      'imageURL': imageURL,
      'timestamp': timestamp,
      'numComments': numComments,
      'numRetweets': numRetweets,
      'numLikes': numLikes,
      'isRetweeted': isLiked,
      'isLiked': isRetweeted
    };
  }

  void updateLike(bool isLiked) {
    reference?.update({
      'isLiked': isLiked,
      'numLikes': isLiked ? numLikes + 1 : numLikes - 1,
    });
  }

  void updateRetweet(bool isRetweeted) {
    reference?.update({
      'isRetweeted': isRetweeted,
      'numRetweets': isRetweeted ? numRetweets + 1 : numRetweets - 1,
    });
  }
}