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
    print('User model set: ${_userModel?.toJson()}');
    // Fetch user's group chat data
    _userModel?.groupChats = _groupChats;
    print('Group chat state: ${_userModel?.groupChats?.length}');
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

                // Check if the group chat has expired
                if (model.expiryDate?.isAfter(DateTime.now()) ?? false) {
                  _groupChatList!.add(model);
                } else {
                  // Group chat has expired, delete it from the database
                  kDatabase.child('groupchats').child(key).remove();
                }
              }
            });

            _groupChatList!.sort((x, y) => x.createdAt.compareTo(y.createdAt));

            // Update the groupChats property of the user with the fetched group chats
            var authState = Provider.of<AuthState>(_context!, listen: false);
            UserModel userModel = authState.userModel!;
            userModel.groupChats = _groupChatList;

            // Assign the fetched group chats to the _groupChats property
            _groupChats = _groupChatList;
          }
        }

        isBusy = false;
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

      // Calculate the expiry date
      DateTime expiryDate = DateTime.now().add(Duration(hours: 12));

      // Create a new group chat object with updated properties
      GroupChat newGroupChat = GroupChat(
        key: groupChatId,
        groupName: groupChat.groupName,
        participantCount: groupChat.participantCount,
        createdAt: DateTime.now(),
        expiryDate: expiryDate,
      );

      // Save the group chat to the database
      await groupChatRef.set(newGroupChat.toJson());

      // Update the user's group chats in the database
      UserModel userModel = authState.userModel!;
      userModel.groupChats ??= [];
      userModel.groupChats!.add(newGroupChat);
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
