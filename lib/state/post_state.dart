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

  List<PostModel>? getPostLists(UserModel? userModel, String? groupChatId) {
    if (userModel == null || groupChatId == null) {
      return null;
    }

    List<PostModel>? list;

    if (!isBusy && groupChatPostMap.isNotEmpty) {
      list = groupChatPostMap[
          groupChatId]; // Fetch posts only for the specific groupChatId
      if (list != null && list.isEmpty) {
        list = null;
      }
    }
    return list;
  }

  Future<bool> databaseInit(List<GroupChat> groupChats, UserModel? user) {
    try {
      if (groupChatQueryMap.isEmpty) {
        String? userId = user?.userId; // Assuming UserModel has a userId field
        if (userId == null) {
          print("Error: userId is null");
          return Future.value(false);
        }
        for (var groupChat in groupChats) {
          groupChatQueryMap[groupChat.key!] =
              kDatabase.child("posts").child(groupChat.key!);
          List<String> participantIds = groupChat.participantIds ??
              []; // Assuming GroupChat has a participantIds field

          // Listener for added posts
          groupChatQueryMap[groupChat.key!]!.onChildAdded.listen(
              (event) => onPostAdded(groupChat.key!, participantIds, event));

          // Listener for removed posts
          groupChatQueryMap[groupChat.key!]!
              .onChildRemoved
              .listen((event) => onPostDeleted(groupChat.key!, event));
        }
      }
      print("Queries initialized successfully.");
      return Future.value(true);
    } catch (error) {
      print("Error initializing queries: $error");
      return Future.value(false);
    }
  }

  void onPostDeleted(String groupChatId, DatabaseEvent event) async {
    // Fetch the post that is about to be deleted
    PostModel postToBeDeleted = PostModel.fromJson(event.snapshot.value as Map);
    postToBeDeleted.key = event.snapshot.key;

    // Copy this post to the history node
    DatabaseReference historyRef =
        kDatabase.child('history_posts').child(postToBeDeleted.key!);
    await historyRef.set(postToBeDeleted.toJson());

    // Remove the post from the active posts node
    removePostFromState(groupChatId, event.snapshot.key!);
  }

  Future<void> getDataFromDatabaseForGroupChat(
      String groupChatId, List<String> participantIds) async {
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
          }
        }

        for (String participantId in participantIds) {
          String newKey = '${groupChatId}_$participantId';
          hasPostedInGroup[newKey] = groupChatPostMap[groupChatId]
                  ?.any((post) => post.user?.userId == participantId) ??
              false;
        }

        isBusy = false;
        notifyListeners();
      });
    } catch (error) {
      isBusy = false;
      print("Error fetching data for group chat: $groupChatId, Error: $error");
    }
  }

  void onPostAdded(
      String groupChatId, List<String> participantIds, DatabaseEvent event) {
    PostModel post = PostModel.fromJson(event.snapshot.value as Map);
    post.key = event.snapshot.key!;
    post.groupChat!.key = groupChatId;
    groupChatPostMap[groupChatId] ??= [];
    if (!groupChatPostMap[groupChatId]!.any((x) => x.key == post.key)) {
      groupChatPostMap[groupChatId]!.add(post);
    }

    for (String participantId in participantIds) {
      String newKey = '${groupChatId}_$participantId';
      hasPostedInGroup[newKey] = groupChatPostMap[groupChatId]
              ?.any((post) => post.user?.userId == participantId) ??
          false;
    }

    // Add a new method to handle when posts are deleted
    void onPostsDeleted(String groupChatId, List<String> participantIds) {
      for (String participantId in participantIds) {
        String newKey = '${groupChatId}_$participantId';
        hasPostedInGroup[newKey] = groupChatPostMap[groupChatId]
                ?.any((post) => post.user?.userId == participantId) ??
            false;
      }
      notifyListeners();
    }
  }

  void removePostFromState(String groupChatId, String postId) {
    if (groupChatPostMap[groupChatId] != null) {
      groupChatPostMap[groupChatId]!.removeWhere((post) => post.key == postId);
    }
    notifyListeners(); // Notify UI about the change
  }
}
