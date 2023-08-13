import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:groupchat_firebase/helper/utility.dart';
import 'package:groupchat_firebase/models/user.dart';
import '../models/groupchat.dart';

class GroupChatState extends ChangeNotifier {
  bool isBusy = false;
  List<GroupChat>? _groupChats;
  Timer? _timer;
  User? _currentUser;
  String? _userId; // New property to store the user ID
  List<GroupChat>? get groupChats => _groupChats;
  String? get userId => _userId; // Getter for the user ID

  /*List<GroupChat>? getGroupChats() {
    return _groupChats;
  }*/

  /*void setCurrentUser(User user) {
    _userId = user.uid; // Set the user ID when the current user is fetched
    _currentUser = user;
    notifyListeners();
  }*/

  void startTimer() {
    stopTimer(); // Stop the timer if it's already running
    // Schedule a timer to update the remaining time every second
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      updateRemainingTime();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void updateRemainingTime() {
    _groupChats?.forEach((groupChat) {
      groupChat.updateRemainingTime();
    });
    notifyListeners();
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

  Future<void> saveGroupChatToDatabase(
      GroupChat groupChat, Function(String groupKey) returnKey) async {
    try {
      print("save called");
      // Create a new group chat node in the database
      DatabaseReference groupChatRef = kDatabase.child('groupchats').push();
      String groupChatId = groupChatRef.key!;
      returnKey.call(groupChatId);

      // Calculate the expiry date
      DateTime expiryDate = DateTime.now().add(Duration(hours: 12));

      // Create a new group chat object with updated properties
      GroupChat newGroupChat = GroupChat(
        key: groupChatId,
        creatorId: groupChat.creatorId,
        groupName: groupChat.groupName,
        participantCount: groupChat.participantCount,
        participantIds: groupChat.participantIds,
        participantFcmTokens: groupChat.participantFcmTokens,
        createdAt: DateTime.now(),
        expiryDate: expiryDate,
      );

      // Save the group chat to the database
      await groupChatRef.set(newGroupChat.toJson());

      // Update the local group chats list
      _groupChats ??= [];
      _groupChats!.add(newGroupChat);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateGroutChatParticipant(GroupChat groupChat) async {
    try {
      DatabaseReference groupChatRef =
          kDatabase.child('groupchats').child(groupChat.key!);

      // Save the group chat to the database
      await groupChatRef.update({
        "participantIds": groupChat.participantIds,
        "participantFcmTokens": groupChat.participantFcmTokens
      });

      // Update the local group chats list
      _groupChats!.removeWhere((element) => element.key == groupChat.key);
      _groupChats!.add(groupChat);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Implement methods to fetch, create, update, and delete group chats
  // For example: _fetchUserGroupChats(), _createGroupChat(), etc.

  // Other methods and logic related to group chats

  GroupChat? getGroupChatByKey(String groupChatKey) {
    if (_groupChats != null) {
      for (var groupChat in _groupChats!) {
        if (groupChat.key == groupChatKey) {
          return groupChat;
        }
      }
    }
    return null;
  }

  /*getAllUsersInGroup(String groupId) {
    if (_groupChats!.isNotEmpty) {
      for (GroupChat groupChat in _groupChats!) {
        if (groupChat.key == groupId) {
          List<String> participants = groupChat.participantIds;
          for(String participant in participants){
                try {
      isBusy = true;
      kDatabase.child('profile').child(participant).once().then(
        (DatabaseEvent event) {
          final snapshot = event.snapshot;
          if (snapshot.value != null) {
            var map = snapshot.value as Map?;
            if (map != null) {
              map.forEach((key, value) {
                var model = UserModel.fromJson(value);
                model.key = key;
              });
            }
          } else {
            _userlist = null;
          }
          isBusy = false;
        },
      );
    } catch (error) {
      isBusy = false;
      print(error);
    }
          }
        }
      }
    }
  }*/

  /*User? getCurrentUser() {
    return _currentUser;
  }*/
}