import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:groupchat_firebase/helper/enum.dart';
import 'package:groupchat_firebase/helper/utility.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/groupchat.dart';

class GroupChatState extends ChangeNotifier {
  bool isBusy = false;
  UserModel? _userModel;
  List<GroupChat>? _groupChats;
  BuildContext? _context;

  void setUserModel(UserModel user, BuildContext context) {
    _userModel = user;
    _context = context;
    // Fetch user's group chat data
    getDataFromDatabase();
    notifyListeners();
  }

  List<GroupChat>? getGroupChats() {
    return _userModel?.groupChats;
  }

  void getDataFromDatabase() {
    try {
      isBusy = true;
      kDatabase.child('groupchats').once().then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        List<GroupChat>? _groupChatList = [];
        if (snapshot.value != null) {
          var map = snapshot.value as Map<dynamic, dynamic>?;

          if (map != null) {
            map.forEach((key, value) {
              var dynamicMap = value as Map<dynamic, dynamic>?;

              if (dynamicMap != null) {
                var stringMap = Map<String, dynamic>.from(dynamicMap);
                var model = GroupChat.fromJson(stringMap);
                model.key = key;
                _groupChatList!.add(model);
              }
            });

            _groupChatList!.sort((x, y) => x.createdAt.compareTo(y.createdAt));
          }
        } else {
          _groupChatList = null;
        }

        isBusy = false;

        // Update the groupChats property of the user with the fetched group chats
        var authState = Provider.of<AuthState>(_context!, listen: false);
        UserModel userModel = authState.userModel!;
        userModel.groupChats = _groupChatList;

        notifyListeners();
      });
    } catch (error) {
      isBusy = false;
      print(error);
    }
  }

  Future<void> saveGroupChatToDatabase(GroupChat groupChat) async {
    try {
      // Check if the user is authenticated
      var authState = Provider.of<AuthState>(_context!, listen: false);
      if (authState.authStatus != AuthStatus.LOGGED_IN) {
        throw Exception('User not logged in');
      }

      // Get the current user's ID
      String userId = authState.userId;

      // Create a new group chat node in the database
      DatabaseReference groupChatRef = kDatabase.child('groupchats').push();
      String groupChatId = groupChatRef.key!;

      // Create a new group chat object with updated properties
      GroupChat newGroupChat = GroupChat(
        key: groupChatId,
        groupName: groupChat.groupName,
        timeRemaining: groupChat.timeRemaining,
        participantCount: groupChat.participantCount,
        createdAt: DateTime.now(),
      );

      // Save the group chat to the database
      await groupChatRef.set(newGroupChat.toJson());

      // Update the user's group chats in the database
      UserModel userModel = authState.userModel!;
      userModel.groupChats ??= [];
      userModel.groupChats!
          .add(newGroupChat); // Add the newGroupChat object, not groupChatId
      kDatabase
          .child('profile')
          .child(userId)
          .child('groupChats')
          .set(userModel.groupChats);

      // Update the local group chats list
      _groupChats ??= [];
      _groupChats!.add(newGroupChat);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Implement methods to fetch, create, update, and delete group chats
  // For example: _fetchUserGroupChats(), _createGroupChat(), etc.

  // Other methods and logic related to group chats
  List<GroupChat>? get groupChats => _groupChats;
}
