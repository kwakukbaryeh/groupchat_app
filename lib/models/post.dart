// ignore_for_file: avoid_print

import 'package:flutter/src/widgets/basic.dart';
import 'package:groupchat_firebase/models/groupchat.dart';

import 'user.dart';

class PostModel {
  String? key;
  String? imageFrontPath;
  String? imageBackPath;
  String? bio;
  late String createdAt;
  UserModel? user;
  List<String?>? comment;
  List<UserModel>? taggedUsers;
  GroupChat? groupChat;

  PostModel(
      {this.key,
      required this.createdAt,
      this.imageFrontPath,
      this.bio,
      this.imageBackPath,
      this.user,
      this.groupChat,
      this.taggedUsers});

  toJson() {
    return {
      "key": key,
      "createdAt": createdAt,
      "bio": bio,
      "imageBackPath": imageBackPath,
      "imageFrontPath": imageFrontPath,
      "user": user == null ? null : user!.toJson(),
      "groupChat": groupChat == null ? null : groupChat!.toJson(),
      "taggedUsers": taggedUsers != null
          ? taggedUsers!.map((e) => e.toJson()).toList()
          : null
    };
  }

  PostModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    bio = map['bio'];
    imageBackPath = map['imageBackPath'];
    createdAt = map['createdAt'];
    imageFrontPath = map['imageFrontPath'];
    user = UserModel.fromJson(map['user']);
    taggedUsers = map["taggedUsers"] != null
        ? (map["taggedUsers"] as List)
            .map((e) => UserModel.fromJson(e))
            .toList()
        : null;
    groupChat = map.containsKey('groupChat') && map['groupChat'] != null
        ? GroupChat.fromJson(map['groupChat'].cast<String, dynamic>())
        : null;
  }

  // ... Your existing code ...
  map(Stack Function(dynamic model) param0) {}
}
