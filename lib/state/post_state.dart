import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import '../helper/utility.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/groupchat.dart'; // Import the GroupChat model
import 'appState.dart';

class PostState extends AppStates {
  bool isBusy = false;
  Map<String, List<PostModel>?> groupChatPostMap =
      {}; // Use a map to store posts for each group chat
  Map<String, dabase.Query?> groupChatQueryMap =
      {}; // Use a map to store queries for each group chat
  PostModel? _postToReplyModel;
  PostModel? get postToReplyModel => _postToReplyModel;
  set setPostToReply(PostModel model) {
    _postToReplyModel = model;
  }

  List<PostModel>? getPostList(UserModel? userModel) {
    final now = DateTime.now();

    if (userModel == null) {
      return null;
    }

    List<PostModel>? list;
    if (!isBusy && groupChatPostMap.isNotEmpty) {
      list = [];
      groupChatPostMap.forEach((groupChatId, postList) {
        if (postList != null) {
          list!.addAll(postList.where((x) {
            if ((x.user!.userId == userModel.userId ||
                    (userModel.followingList != null &&
                        userModel.followingList!.contains(x.user!.userId))) &&
                now.difference(DateTime.parse(x.createdAt)).inHours < 24) {
              return true;
            } else {
              return false;
            }
          }));
        }
      });
      if (list.isEmpty) {
        list = null;
      }
    }
    return list;
  }

  List<PostModel>? getPostLists(UserModel? userModel) {
    if (userModel == null) {
      return null;
    }

    List<PostModel>? list;

    if (!isBusy && groupChatPostMap.isNotEmpty) {
      list = [];
      groupChatPostMap.forEach((groupChatId, postList) {
        if (postList != null) {
          list!.addAll(postList);
        }
      });
      if (list.isEmpty) {
        list = null;
      }
    }
    return list;
  }

  void setFeedModel(PostModel model) {
    String groupChatId = model.groupChatId ??
        'default'; // Use 'default' as a fallback if groupChatId is null or empty
    groupChatPostMap[groupChatId] ??= [];
    groupChatPostMap[groupChatId]!.add(model);
    notifyListeners();
  }

  Future<bool> databaseInit(List<GroupChat> groupChats) {
    try {
      // Initialize queries for each group chat
      if (groupChatQueryMap.isEmpty) {
        for (var groupChat in groupChats) {
          groupChatQueryMap[groupChat.key!] =
              kDatabase.child("posts").child(groupChat.key!);
          groupChatQueryMap[groupChat.key!]!
              .onChildAdded
              .listen((event) => onPostAdded(groupChat.key!, event));
        }
      }
      return Future.value(true);
    } catch (error) {
      return Future.value(false);
    }
  }

  void getDataFromDatabase() {
    try {
      isBusy = true;
      groupChatPostMap.clear();
      notifyListeners();
      kDatabase.child('posts').once().then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          var map = snapshot.value as Map<dynamic, dynamic>?;
          if (map != null) {
            map.forEach((groupChatId, value) {
              var postMap = value as Map<dynamic, dynamic>;
              if (postMap != null) {
                List<PostModel> postList = [];
                postMap.forEach((key, value) {
                  var model = PostModel.fromJson(value);
                  model.key = key;
                  postList.add(model);
                });
                postList.sort((x, y) => DateTime.parse(x.createdAt)
                    .compareTo(DateTime.parse(y.createdAt)));
                groupChatPostMap[groupChatId] = postList;
              }
            });
          }
        }
        isBusy = false;
        notifyListeners();
      });
    } catch (error) {
      isBusy = false;
    }
  }

  void getDataFromDatabaseForGroupChat(String groupChatId) {
    try {
      isBusy = true;
      groupChatPostMap[groupChatId] = null;
      notifyListeners();
      kDatabase
          .child('posts')
          .child(groupChatId)
          .once()
          .then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          var postMap = snapshot.value as Map<dynamic, dynamic>?;
          if (postMap != null) {
            List<PostModel> postList = [];
            postMap.forEach((key, value) {
              var model = PostModel.fromJson(value);
              model.key = key;
              postList.add(model);
            });
            postList.sort((x, y) => DateTime.parse(x.createdAt)
                .compareTo(DateTime.parse(y.createdAt)));
            groupChatPostMap[groupChatId] = postList;
          }
        }
        isBusy = false;
        notifyListeners();
      });
    } catch (error) {
      isBusy = false;
    }
  }

  void onPostAdded(String groupChatId, DatabaseEvent event) {
    PostModel post = PostModel.fromJson(event.snapshot.value as Map);
    post.key = event.snapshot.key!;
    post.groupChatId = groupChatId;
    groupChatPostMap[groupChatId] ??= [];
    if (!groupChatPostMap[groupChatId]!.any((x) => x.key == post.key)) {
      groupChatPostMap[groupChatId]!.add(post);
    }
    isBusy = false;
    notifyListeners();
  }
}
