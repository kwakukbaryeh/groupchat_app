// ignore_for_file: avoid_print

import 'package:flutter/src/widgets/basic.dart';
import 'package:groupchat_firebase/models/groupchat.dart';

import 'user.dart';

class Comment {
  String username;
  String comment;
  List<Comment>? replies;

  Comment({required this.username, required this.comment, this.replies});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'comment': comment,
      'replies': replies?.map((e) => e.toJson()).toList(),
    };
  }

  Comment.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        comment = json['comment'],
        replies = json['replies'] != null
            ? (json['replies'] as List)
                .map((e) => Comment.fromJson(e as Map<String, dynamic>))
                .toList()
            : null;
}

class PostModel {
  String? key;
  String? imageFrontPath;
  String? imageBackPath;
  String? bio;
  late String createdAt;
  UserModel? user;
  List<Comment>? comments;
  List<UserModel>? taggedUsers;
  GroupChat? groupChat;
  String? caption;

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
      'caption': caption,
      "user": user == null ? null : user!.toJson(),
      "groupChat": groupChat == null ? null : groupChat!.toJson(),
      "taggedUsers": taggedUsers != null
          ? taggedUsers!.map((e) => e.toJson()).toList()
          : null,
      "comments": comments?.map((e) => e.toJson()).toList(),
    };
  }

  PostModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    bio = map['bio'];
    caption = map['caption'];
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
    if (map['comments'] != null) {
      comments = (map['comments'] as List)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  map(Stack Function(dynamic model) param0) {}
}
