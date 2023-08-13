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
  List<UserModel> _friendsList = [];
  List<UserModel> _taggedUsers = [];
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  Future<void> addPostToDatabase(PostModel post) async {
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
        title: Text("Share moment"),
      ),
      body: Stack(
        children: [
          Container(
              color: Colors.black,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                  ),
                  GestureDetector(
                      onTap: switcherFunc,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                              height: MediaQuery.of(context).size.height / 1.63,
                              width: MediaQuery.of(context).size.width,
                              child: Stack(
                                children: [
                                  FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              1.63,
                                          child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: switcher
                                                  ? widget
                                                      .postModel.imageFrontPath
                                                      .toString()
                                                  : widget
                                                      .postModel.imageBackPath
                                                      .toString()))),
                                  Padding(
                                      padding: EdgeInsets.all(20),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  6,
                                              width:
                                                  MediaQuery.of(context)
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
                crossAxisAlignment: CrossAxisAlignment.start,
              )),
          Positioned(
              top: MediaQuery.of(context).size.height / 1.73,
              left: 50,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      builder: (BuildContext ctx) {
                        return Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Tag Your Friends",
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: GridView.builder(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 30),
                                  itemCount: _friendsList.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
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
                                                    BorderRadius.circular(100),
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
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          _taggedUsers.length.toString(),
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    )),
              )),
          Positioned(
              bottom: 100,
              left: 150,
              child: InkWell(
                onTap: () {
                  widget.postModel.taggedUsers =
                      _taggedUsers.isEmpty ? null : _taggedUsers;
                  addPostToDatabase(widget.postModel);
                  Navigator.pop(context);
                },
                child: Container(
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
    );
  }
}