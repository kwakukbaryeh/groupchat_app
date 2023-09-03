// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';

class TagFriends extends StatefulWidget {
  final PostModel postModel;
  const TagFriends({required this.postModel, super.key});

  @override
  State<TagFriends> createState() => _TagFriendsState();
}

class _TagFriendsState extends State<TagFriends> {
  final List<UserModel> _friendsList = [];
  final List<UserModel> _taggedUsers = [];
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  String caption = ""; // Add this line to store the caption

  Future<void> addPostToDatabase(PostModel post) async {
    post.caption = caption; // Add this line to set the caption
    var newPostRef = _databaseRef.child('posts').child(post.key!).push();
    newPostRef.set(post.toJson());
  }

  bool switcher = false;

  void switcherFunc() {
    setState(() {
      switcher = !switcher;
    });
  }

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
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Share moment"),
        backgroundColor: Colors.black, // Add this line
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
                color: Colors.black,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                    ),
                    GestureDetector(
                        onTap: switcherFunc,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 1.63,
                                width: MediaQuery.of(context).size.width,
                                child: Stack(
                                  children: [
                                    FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                1.63,
                                            child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: switcher
                                                    ? widget.postModel
                                                        .imageFrontPath
                                                        .toString()
                                                    : widget
                                                        .postModel.imageBackPath
                                                        .toString()))),
                                    Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    6,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.9,
                                                child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    imageUrl: !switcher
                                                        ? widget.postModel
                                                            .imageFrontPath
                                                            .toString()
                                                        : widget.postModel
                                                            .imageBackPath
                                                            .toString())))),
                                  ],
                                )))),
                  ],
                )),
            Positioned(
                top: MediaQuery.of(context).size.height / 1.73,
                left: 50,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        builder: (BuildContext ctx) {
                          return Column(
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                "Tag Your Friends",
                                style: TextStyle(fontSize: 16),
                              ),
                              Expanded(
                                child: GridView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 30),
                                    itemCount: _friendsList.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 30,
                                    ),
                                    itemBuilder: (ctx, index) {
                                      return _friendsList[index].profilePic !=
                                              null
                                          ? InkWell(
                                              onTap: () {
                                                _taggedUsers
                                                    .add(_friendsList[index]);
                                                setState(() {});
                                              },
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundColor: Colors.white,
                                                child: Image.network(
                                                    _friendsList[index]
                                                        .profilePic!),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                _taggedUsers
                                                    .add(_friendsList[index]);
                                                setState(() {});
                                              },
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      height: 15,
                                                      imageUrl: state
                                                              .profileUserModel
                                                              ?.profilePic ??
                                                          "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg")),
                                            );
                                    }),
                              )
                            ],
                          );
                        });
                  },
                  child: Container(
                      width: 50,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            _taggedUsers.length.toString(),
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      )),
                )),
            Positioned(
              bottom: 220, // Adjust the position as needed
              left: 20,
              right: 20,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    caption =
                        value; // Update the caption whenever the text changes
                  });
                },
                decoration: InputDecoration(
                  hintText: "Add A Caption...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Positioned(
                bottom: 160,
                left: 150,
                child: InkWell(
                  onTap: () {
                    widget.postModel.taggedUsers =
                        _taggedUsers.isEmpty ? null : _taggedUsers;
                    addPostToDatabase(widget.postModel);
                    Navigator.pop(context);
                  },
                  child: const SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        Text(
                          "Send",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(width: 15),
                        Icon(Icons.send)
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
