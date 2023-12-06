import 'package:cloud_firestore/cloud_firestore.dart';

class Account{
  DocumentReference? accReference;

  List <DocumentReference>? postReferences = [];
  String? accDescription;
  String? accSettings;
  String? userShortName;
  String? userLongName;
  String? password;
  String? imageURL;
  List <dynamic>? followingAccs;

  Account.fromMap(var map, {this.accReference}){
    postReferences = map['postReferences'];
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
      'postReferences': postReferences,
      'accDescription': accDescription,
      'accSettings': accSettings,
      'userShortName': userShortName,
      'userLongName': userLongName,
      'password': password,
      'imageURL': imageURL,
      'followingAccs': followingAccs
    };
  }
}