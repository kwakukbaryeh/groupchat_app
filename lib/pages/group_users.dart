import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/helper/utility.dart';
import 'package:groupchat_firebase/models/groupchat.dart';
import 'package:groupchat_firebase/models/user.dart'; // Import the User model
import 'package:groupchat_firebase/pages/homepage.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/state/groupchatState.dart';
import 'package:provider/provider.dart'; // Import the Chat model

/*class Friendship {
  final UserModel user;
  final bool isFriend;

  Friendship({required this.user, this.isFriend = false});
}*/

class GroupUsers extends StatefulWidget {
  @override
  List<UserModel> groupUsers;
  GroupChat groupChat;
  GroupUsers({super.key, required this.groupUsers, required this.groupChat});
  @override
  _GroupUsersState createState() => _GroupUsersState();
}

class _GroupUsersState extends State<GroupUsers> {
  List<UserModel> _groupUsers = []; // List to store the user's friends
  List<UserModel> _searchResults = []; // List to store search results
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Initialize the friends list here or fetch it from your database
    //_loadFriendsList();
    _groupUsers = widget.groupUsers;
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
        _searchResults = _groupUsers
            .where((groupUser) =>
                groupUser.userName
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ??
                false)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    var state = Provider.of<AuthState>(context);
    final groupChatsState = Provider.of<GroupChatState>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Group Users'),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchController.text == ""
                  ? _groupUsers.length
                  : _searchResults.length,
              itemBuilder: (context, index) {
                final groupUser = _searchController.text == ""
                    ? _groupUsers[index]
                    : _searchResults[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: groupUser.profilePic == null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              height: 70,
                              imageUrl: state.profileUserModel?.profilePic ??
                                  "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg"))
                      : CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Image.network(groupUser.profilePic!)),
                  title: Text(groupUser.displayName ?? 'Unknown User'),
                  trailing: InkWell(
                      onTap: () async {
                        DatabaseEvent event = await kDatabase
                            .child("groupchats")
                            .child(widget.groupChat.key!)
                            .child("participantIds")
                            .once();
                        List list = event.snapshot.value as List;
                        List newlist = [];
                        for (var id in list) {
                          if (id != groupUser.userId) {
                            newlist.add(groupUser.userId);
                          }
                        }
                        event.snapshot.ref.set(newlist);
                        groupChatsState.getDataFromDatabase();
                        log(event.snapshot.value.toString());
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                backgroundColor: Colors.blue,
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "User has been removed",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                )));
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (ctx) => HomePage()),
                            (route) => false);
                      },
                      child: const Text("Remove")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
