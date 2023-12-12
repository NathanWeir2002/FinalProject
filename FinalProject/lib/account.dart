import 'package:cloud_firestore/cloud_firestore.dart';

class Account{
  DocumentReference? accReference;

  List <dynamic> likedPosts = [];
  List <dynamic> retweetedPosts = [];
  List <dynamic> hiddenPosts = [];
  List <dynamic> myPosts = [];
  String? accDescription;
  String? accSettings;
  String? userShortName;
  String? userLongName;
  String? password;
  String? imageURL;
  List <dynamic> followingAccs = [];

  Account.fromMap(var map){
    accReference = map['accReference'];
    likedPosts = map['likedPosts'];
    retweetedPosts = map['retweetedPosts'];
    hiddenPosts = map['hiddenPosts'];
    myPosts = map['myPosts'];
    accDescription = map['accDescription'];
    accSettings = map['accSettings'];
    userShortName = map['userShortName'];
    userLongName = map['userLongName'];
    password = map['password'];
    imageURL = map['imageURL'];
    followingAccs = map['followingAccs'];
  }

  Map<String, Object?> toMap(){
    return {
      'accReference': accReference,
      'likedPosts': likedPosts,
      'retweetedPosts': retweetedPosts,
      'hiddenPosts': hiddenPosts,
      'myPosts': myPosts,
      'accDescription': accDescription,
      'accSettings': accSettings,
      'userShortName': userShortName,
      'userLongName': userLongName,
      'password': password,
      'imageURL': imageURL,
      'followingAccs': followingAccs
    };
  }

  void updateLikes(DocumentReference tweetRef) {
    if (likedPosts.contains(tweetRef) == true) {
      likedPosts.remove(tweetRef);
      accReference?.update({'likedPosts': FieldValue.arrayRemove([tweetRef])});
    } else {
      likedPosts.add(tweetRef);
      accReference?.update({'likedPosts': FieldValue.arrayUnion([tweetRef])});
    }
  }
  void updateRetweets(DocumentReference tweetRef) {
    if (retweetedPosts.contains(tweetRef) == true) {
      retweetedPosts.remove(tweetRef);
      accReference?.update({'retweetedPosts': FieldValue.arrayRemove([tweetRef])});
    } else {
      retweetedPosts.add(tweetRef);
      accReference?.update({'retweetedPosts': FieldValue.arrayUnion([tweetRef])});
    }
  }
  void updateHidden(DocumentReference tweetRef) {
    if (hiddenPosts.contains(tweetRef) == true) {
      hiddenPosts.remove(tweetRef);
      accReference?.update({'hiddenPosts': FieldValue.arrayRemove([tweetRef])});
    } else {
      hiddenPosts.add(tweetRef);
      accReference?.update({'hiddenPosts': FieldValue.arrayUnion([tweetRef])});
    }
  }

  bool checkLikes(DocumentReference tweetRef) {
    return likedPosts.contains(tweetRef);
  }

  bool checkRetweets(DocumentReference tweetRef) {
    return retweetedPosts.contains(tweetRef);
  }

  bool checkHidden(DocumentReference tweetRef) {
    return hiddenPosts.contains(tweetRef);
  }
}