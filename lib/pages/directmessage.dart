import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/user.dart'; // Import the User model
// Import the Chat model

class Friendship {
  final UserModel user;
  final bool isFriend;

  Friendship({required this.user, this.isFriend = false});
}

class DirectMessagePage extends StatefulWidget {
  const DirectMessagePage({super.key});

  @override
  _DirectMessagePageState createState() => _DirectMessagePageState();
}

class _DirectMessagePageState extends State<DirectMessagePage> {
  List<Friendship> _friendsList = []; // List to store the user's friends
  List<Friendship> _searchResults = []; // List to store search results
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the friends list here or fetch it from your database
    _loadFriendsList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendsList() async {
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
  }

  void _handleSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults.clear();
      } else {
        // Filter friends list based on the search query
        _searchResults = _friendsList
            .where((friendship) =>
                friendship.user.userName
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ??
                false)
            .toList();
      }
    });
  }

  void _startChat(UserModel user) {
    // Create a new chat or fetch existing chat with the user
    // Add logic to handle sending messages to this user
    // For demonstration purposes, we'll just print the user's name for now
    print('Starting chat with ${user.userName ?? "Unknown User"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Messages'),
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
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final friendship = _searchResults[index];
                return ListTile(
                  title: Text(friendship.user.userName ?? 'Unknown User'),
                  onTap: () {
                    _startChat(friendship.user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
