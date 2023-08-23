import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import '../helper/utility.dart';
import '../models/groupchat.dart'; // Import the GroupChat model
import '../models/post.dart';
import '../models/user.dart';
import 'appState.dart';

class PostState extends AppStates {
  bool isBusy = false;
  Map<String, List<PostModel>?> groupChatPostMap = {}; // Existing code
  Map<String, dabase.Query?> groupChatQueryMap = {}; // Existing code
  Map<String, bool> hasPostedInGroup =
      {}; // New field to track if user has posted in each group chat

  PostModel? _postToReplyModel;

  PostModel? get postToReplyModel => _postToReplyModel;

  set setPostToReply(PostModel model) {
    _postToReplyModel = model;
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

  Future<bool> databaseInit(List<GroupChat> groupChats) {
    try {
      if (groupChatQueryMap.isEmpty) {
        for (var groupChat in groupChats) {
          groupChatQueryMap[groupChat.key!] =
              kDatabase.child("posts").child(groupChat.key!);
          groupChatQueryMap[groupChat.key!]!
              .onChildAdded
              .listen((event) => onPostAdded(groupChat.key!, event));
        }
      }
      print("Queries initialized successfully.");
      return Future.value(true);
    } catch (error) {
      print("Error initializing queries: $error");
      return Future.value(false);
    }
  }

  Future<void> getDataFromDatabaseForGroupChat(String groupChatId) async {
    try {
      isBusy = true;
      notifyListeners();
      await kDatabase
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
            print("Data fetched for group chat: $groupChatId");
          }
        } else {
          print("No data found for group chat: $groupChatId");
        }
        hasPostedInGroup[groupChatId] =
            groupChatPostMap[groupChatId]?.isNotEmpty ?? false;
        isBusy = false;
        notifyListeners();
        print("Data fetching completed for group chat: $groupChatId");
      });
    } catch (error) {
      isBusy = false;
      print("Error fetching data for group chat: $groupChatId, Error: $error");
    }
  }

  void onPostAdded(String groupChatId, DatabaseEvent event) {
    PostModel post = PostModel.fromJson(event.snapshot.value as Map);
    post.key = event.snapshot.key!;
    post.groupChat!.key = groupChatId;
    groupChatPostMap[groupChatId] ??= [];
    if (!groupChatPostMap[groupChatId]!.any((x) => x.key == post.key)) {
      groupChatPostMap[groupChatId]!.add(post);
      print("Post added to groupChatPostMap: $post");
    } else {
      print("Post already exists in groupChatPostMap: $post");
    }
    hasPostedInGroup[groupChatId] =
        groupChatPostMap[groupChatId]?.isNotEmpty ?? false;
    isBusy = false;
    notifyListeners();
  }

  // Add a new method to handle when posts are deleted
  void onPostsDeleted(String groupChatId) {
    hasPostedInGroup[groupChatId] =
        groupChatPostMap[groupChatId]?.isEmpty ?? true;
    notifyListeners();
  }
}
