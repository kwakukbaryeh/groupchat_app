// ignore_for_file: avoid_print

import 'package:flutter/src/widgets/basic.dart';
import 'user.dart';

class PostModel {
  String? key;
  String? imageFrontPath;
  String? imageBackPath;
  String? bio;
  late String createdAt;
  UserModel? user;
  List<String?>? comment;
  String? groupChatId; // Add the groupChatId property

  PostModel({
    this.key,
    required this.createdAt,
    this.imageFrontPath,
    this.bio,
    this.imageBackPath,
    this.user,
    this.groupChatId, // Initialize the groupChatId property
  });

  toJson() {
    return {
      "createdAt": createdAt,
      "bio": bio,
      "imageBackPath": imageBackPath,
      "imageFrontPath": imageFrontPath,
      "user": user == null ? null : user!.toJson(),
      "groupChatId": groupChatId, // Include groupChatId in toJson()
    };
  }

  PostModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    bio = map['bio'];
    imageBackPath = map['imageBackPath'];
    createdAt = map['createdAt'];
    imageFrontPath = map['imageFrontPath'];
    user = UserModel.fromJson(map['user']);
    groupChatId = map['groupChatId']; // Get the groupChatId from the map
  }

  map(Stack Function(dynamic model) param0) {}
}
