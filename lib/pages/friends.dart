import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/pages/chat_screen.dart';
import 'package:groupchat_firebase/services/database.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final List<UserModel> _friendsList = [];
  List<UserModel> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

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
          _friendsList.add(user);
        }
        _friendsList.sort((a, b) => a.userName!.compareTo(b.userName!));
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getfriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults.clear();
      } else {
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
    late String chatRoomId;
    getChatRoomIdByUsernames(String a, String b) {
      if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
        return "${b}_$a";
      } else {
        return "${a}_$b";
      }
    }

    getChatRoomId() async {
      chatRoomId = getChatRoomIdByUsernames(receiver.userName!, user.userName!);
    }

    getChatRoomId();

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

    List<UserModel> listToShow =
        _searchController.text.isEmpty ? _friendsList : _searchResults;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Colors.black,
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
            child: listToShow.isNotEmpty
                ? ListView.builder(
                    itemCount: listToShow.length,
                    itemBuilder: (context, index) {
                      final friendship = listToShow[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.all(8),
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
                : const Center(
                    child: Text(
                    "No friends to show",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )),
          ),
        ],
      ),
    );
  }
}
