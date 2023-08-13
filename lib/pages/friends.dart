import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/user.dart'; // Import the User model
import 'package:groupchat_firebase/pages/chat_screen.dart';
import 'package:groupchat_firebase/services/database.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart'; // Import the Chat model

/*class Friendship {
  final UserModel user;
  final bool isFriend;

  Friendship({required this.user, this.isFriend = false});
}*/

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  List<UserModel> _friendsList = []; // List to store the user's friends
  List<UserModel> _searchResults = []; // List to store search results
  TextEditingController _searchController = TextEditingController();

  getfriends() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("friendship")
          .doc(user.uid)
          .collection("friends")
          .get();
      if (snap.docs.isNotEmpty) {
        List<DocumentSnapshot> docs = snap.docs;
        for (DocumentSnapshot document in docs) {
          UserModel user =
              UserModel.fromJson(document.data() as Map<String, dynamic>);
          _searchController.text = "";
          _friendsList.add(user);
          setState(() {});
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the friends list here or fetch it from your database
    //_loadFriendsList();
    getfriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /*Future<void> _loadFriendsList() async {
    // Mock data for demonstration purposes
    // Replace this with actual data retrieval from your database
    // In this example, we're assuming the current user has a userId of '1'
    // and we'll populate the friends list with users based on their following and followers
    String currentUserId =
        '1'; // Replace this with the actual current user's ID

    // Get the list of users the current user is following
    List<String>? followingList =
        await UserModel.getFollowingList(currentUserId);

    // Get the list of users who are following the current user
    List<String>? followersList =
        await UserModel.getFollowersList(currentUserId);

    // Now, check who are the users that are on both lists (mutual friends)
    List<UserModel> allUsers = await UserModel.getAllUsers();
    _friendsList = allUsers
        .map((user) => Friendship(
              user: user,
              isFriend: followingList != null &&
                  followersList != null &&
                  followingList.contains(user.userId) &&
                  followersList.contains(user.userId),
            ))
        .toList();
  }*/

  void _handleSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults.clear();
      } else {
        // Filter friends list based on the search query
        _searchResults = _friendsList
            .where((friendship) =>
                friendship.userName
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ??
                false)
            .toList();
      }
    });
  }

  void _startChat(UserModel user, UserModel receiver) async {
    // Create a new chat or fetch existing chat with the user
    // Add logic to handle sending messages to this user
    // For demonstration purposes, we'll just print the user's name for now
    late String chatRoomId;
    getChatRoomIdByUsernames(String a, String b) {
      if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
        return "$b\_$a";
      } else {
        return "$a\_$b";
      }
    }

    getChatRoomId() async {
      chatRoomId = getChatRoomIdByUsernames(receiver.userName!, user.userName!);
    }

    getChatRoomId();

    print('Starting chat with ${user.userName ?? "Unknown User"}');
    Map<String, dynamic> chatRoomInfoMap = {
      "users": [user.userName, receiver.userName],
      "createdAt": DateTime.now(),
      "expireAt": DateTime.now().add(const Duration(hours: 12)),
      "sender": user.toJson(),
      "receiver": receiver.toJson()
    };
    await Database().createChatRoom(chatRoomId, chatRoomInfoMap);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => ChatScreen(
                  receiver: receiver,
                  sender: user,
                )));
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    var state = Provider.of<AuthState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _friendsList.length != 0 && _searchResults.length != 0
                ? ListView.builder(
                    itemCount: _searchController.text == ""
                        ? _friendsList.length
                        : _searchResults.length,
                    itemBuilder: (context, index) {
                      final friendship = _searchController.text == ""
                          ? _friendsList[index]
                          : _searchResults[index];
                      return ListTile(
                        contentPadding: EdgeInsets.all(8),
                        leading: friendship.profilePic == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    height: 70,
                                    imageUrl: state
                                            .profileUserModel?.profilePic ??
                                        "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg"))
                            : CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Image.network(friendship.profilePic!)),
                        title: Text(friendship.displayName ?? 'Unknown User'),
                        onTap: () {
                          _startChat(authState.userModel!, friendship);
                        },
                      );
                    },
                  )
                : Center(child: Text("No friends to show")),
          ),
        ],
      ),
    );
  }
}
