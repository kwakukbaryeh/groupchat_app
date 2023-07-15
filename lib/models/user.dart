import 'package:equatable/equatable.dart';
import 'package:groupchat_firebase/models/groupchat.dart';

// ignore: must_be_immutable
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
  List<String>? followersList;
  List<String>? followingList;
  String? birthdate;
  String? name;
  String? username;
  String? phoneNumber;
  List<GroupChat>? groupChats;

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
    this.name,
    this.username,
    this.phoneNumber, // Initialize the property here
    this.groupChats,
  });

  UserModel.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) {
      return;
    }
    followersList ??= [];
    email = json['email'];
    userId = json['userId'];
    userName = json['userName'];
    displayName = json['displayName'];
    localisation = json['localisation'];
    bio = json['bio'];
    profilePic = json['profilePic'];
    key = json['key'];
    createAt = json['createAt'];
    fcmToken = json['fcmToken'];
    if (json['followerList'] != null) {
      followersList = <String>[];
      json['followerList'].forEach((value) {
        followersList!.add(value);
      });
    }
    if (json['followingList'] != null) {
      followingList = <String>[];
      json['followingList'].forEach((value) {
        followingList!.add(value);
      });
    }
    if (json['groupChats'] != null) {
      groupChats = (json['groupChats'] as List<dynamic>)
          .map((chatMap) => GroupChat.fromJson(chatMap))
          .toList() as List<GroupChat>?; // Add the type cast here
    }
    birthdate = json['birthdate'];
    name = json['name'];
    username = json['username'];
    phoneNumber = json['phoneNumber']; // Assign the value to the property here
  }

  toJson() {
    return {
      'key': key,
      'userId': userId,
      'userName': userName,
      'bio': bio,
      'localisation': localisation,
      'email': email,
      'displayName': displayName,
      'createAt': createAt,
      'profilePic': profilePic,
      'fcmToken': fcmToken,
      'followerList': followersList,
      'followingList': followingList,
      'birthdate': birthdate,
      'name': name,
      'username': username,
      'phoneNumber': phoneNumber, // Include the property in the JSON output
      'groupChats': groupChats,
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
    List<String>? followingList,
    List<String>? followersList,
    String? birthdate,
    String? name,
    String? username,
    String? phoneNumber, // Include the property in the copyWith method
    List<GroupChat>? groupChats,
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
      followersList: followersList ?? this.followersList,
      followingList: followingList ?? this.followingList,
      birthdate: birthdate ?? this.birthdate,
      name: name ?? this.name,
      username: username ?? this.username,
      phoneNumber: phoneNumber ??
          this.phoneNumber, // Include the property in the copyWith method
      groupChats: groupChats ?? this.groupChats,
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
        profilePic,
        followersList,
        followingList,
        birthdate,
        name,
        username,
        phoneNumber, // Include the property in the props list
        groupChats,
      ];
}
