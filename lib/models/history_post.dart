import 'package:groupchat_firebase/models/groupchat.dart';
import 'package:groupchat_firebase/models/user.dart';

import 'post.dart'; // Assuming HistoryPostModel will use structures from PostModel.

class HistoryPostModel extends PostModel {
  late String deletedAt; // The timestamp when the post was moved to history.
  bool wasFeatured; // Indicates if the post was ever featured in the app.

  HistoryPostModel({
    String? key,
    required String createdAt,
    String? imageFrontPath,
    String? bio,
    String? imageBackPath,
    UserModel? user,
    GroupChat? groupChat,
    List<UserModel>? taggedUsers,
    List<Comment>? comments,
    required this.deletedAt,
    this.wasFeatured = false,
  }) : super(
          key: key,
          createdAt: createdAt,
          imageFrontPath: imageFrontPath,
          bio: bio,
          imageBackPath: imageBackPath,
          user: user,
          groupChat: groupChat,
          taggedUsers: taggedUsers,
        );

  @override
  toJson() {
    var json = super.toJson();
    json.addAll({
      "deletedAt": deletedAt,
      "wasFeatured": wasFeatured,
    });
    return json;
  }

  HistoryPostModel.fromJson(Map<dynamic, dynamic> map)
      : deletedAt = map['deletedAt'],
        wasFeatured = map['wasFeatured'] ?? false,
        super.fromJson(map);

  // If you need to override the map method from PostModel, do so here.
}
