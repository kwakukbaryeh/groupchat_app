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
  GroupChat? groupChat;

  PostModel({
    this.key,
    required this.createdAt,
    this.imageFrontPath,
    this.bio,
    this.imageBackPath,
    this.user,
    this.groupChat,
  });

  toJson() {
    return {
      "createdAt": createdAt,
      "bio": bio,
      "imageBackPath": imageBackPath,
      "imageFrontPath": imageFrontPath,
      "user": user == null ? null : user!.toJson(),
      "groupChat": groupChat == null ? null : user!.toJson(),
    };
  }

  PostModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    bio = map['bio'];
    imageBackPath = map['imageBackPath'];
    createdAt = map['createdAt'];
    imageFrontPath = map['imageFrontPath'];
    user = UserModel.fromJson(map['user']);
    groupChat = GroupChat.fromJson(map['groupChat']);
  }

  // ... Your existing code ...

  map(Stack Function(dynamic model) param0) {}
}
