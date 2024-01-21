import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';

class UserModel extends Equatable {
  String? key;
  String? email;
  String? userId;
  String? bio;
  String? localisation;
  String? userName;
  String? displayName;
  String? profilePic;
  String? createAt;
  String? fcmToken;
  String? birthdate;
  List<String>? followersList;
  List<String>? followingList;

  UserModel({
    this.email,
    this.key,
    this.userName,
    this.localisation,
    this.bio,
    this.userId,
    this.displayName,
    this.profilePic,
    this.createAt,
    this.followingList,
    this.followersList,
    this.fcmToken,
    this.birthdate,
  });

  UserModel.fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return;
    }
    followersList ??= [];
    email = map['email'];
    userId = map['userId'];
    userName = map['userName'];
    displayName = map['displayName'];
    localisation = map['localisation'];
    bio = map['bio'];
    profilePic = map['profilePic'];
    key = map['key'];
    createAt = map['createAt'];
    fcmToken = map['fcmToken'];
    birthdate = map['birthdate'];
    if (map['followingList'] != null) {
      followingList = <String>[];
      map['followingList'].forEach((value) {
        followingList!.add(value);
      });
    }
  }

  toJson() {
    return {
      'key': key,
      "userId": userId,
      "userName": userName,
      "bio": bio,
      "localisation": localisation,
      "email": email,
      'displayName': displayName,
      'createAt': createAt,
      'profilePic': profilePic,
      'fcmToken': fcmToken,
      'birthdate': birthdate,
      'followerList': followersList,
      'followingList': followingList,
    };
  }

  UserModel copyWith({
    String? email,
    String? userId,
    String? userName,
    String? displayName,
    String? profilePic,
    String? createAt,
    String? bio,
    String? localisation,
    String? key,
    String? fcmToken,
    String? birthdate,
    List<String>? followingList,
    List<String>? followersList,
  }) {
    return UserModel(
      email: email ?? this.email,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      displayName: displayName ?? this.displayName,
      profilePic: profilePic ?? this.profilePic,
      createAt: createAt ?? this.createAt,
      bio: bio ?? this.bio,
      localisation: localisation ?? this.localisation,
      key: key ?? this.key,
      fcmToken: fcmToken ?? this.fcmToken,
      birthdate: birthdate ?? this.birthdate,
      followersList: followersList ?? this.followersList,
      followingList: followingList ?? this.followingList,
    );
  }

  @override
  List<Object?> get props => [
        key,
        email,
        bio,
        localisation,
        userName,
        userId,
        createAt,
        displayName,
        fcmToken,
        birthdate,
        profilePic,
        followersList,
        followingList,
      ];

  // Static method to get the list of user IDs that the given user is following
  static Future<List<String>?> getFollowingList(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        Map<String, dynamic>? userData = doc.data() as Map<String, dynamic>?;
        List<String>? followingList =
            userData?['followingList']?.cast<String>();
        return followingList;
      }
    } catch (e) {
      print("Error fetching following list: $e");
    }
    return null;
  }

  // Static method to get the list of user IDs that are following the given user
  static Future<List<String>?> getFollowersList(String userId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('followingList', arrayContains: userId)
          .get();
      List<String> followersList = [];
      for (var doc in snapshot.docs) {
        followersList.add(doc.id);
      }
      return followersList;
    } catch (e) {
      print("Error fetching followers list: $e");
    }
    return null;
  }

  // Static method to get the list of all users from the database
  static Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<UserModel> users = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        UserModel user = UserModel.fromJson(userData);
        users.add(user);
      }
      return users;
    } catch (e) {
      print("Error fetching all users: $e");
    }
    return [];
  }

  static Future<UserModel?> getUserModelFromUID(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user model: $e");
    }
    return null;
  }

  static Future<UserModel?> fromDatabase(String uid) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.reference().child('profile').child(uid);
    DatabaseEvent event = await ref.once();

    print("Snapshot Value: ${event.snapshot.value}");

    if (event.snapshot.value != null) {
      Map<Object?, Object?>? userData =
          event.snapshot.value as Map<Object?, Object?>?;

      if (userData != null) {
        // Now, you can convert specific fields to the expected types
        final String? displayName = userData['displayName'] as String?;
        final String? fcmToken = userData['fcmToken'] as String?;
        final String? userId = userData['userId'] as String?;
        final String? userName = userData['userName'] as String?;
        final String? email = userData['email'] as String?;
        final String? birthdate = userData['birthdate'] as String?;
        final String? key = userData['key'] as String?;

        // Create a UserModel instance with the extracted data
        return UserModel(
          displayName: displayName,
          fcmToken: fcmToken,
          userId: userId,
          userName: userName,
          email: email,
          birthdate: birthdate,
          key: key,
        );
      }
    }
    return null;
  }
}
