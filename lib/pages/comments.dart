import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/helper/utility.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:ui' as ui;

class CommentWidget extends StatelessWidget {
  final Map comment;
  final int level;
  final Function(String) onReplyTap;

  CommentWidget(
      {required this.comment, this.level = 0, required this.onReplyTap});

  @override
  Widget build(BuildContext context) {
    List replies;
    if (comment['replies'] is Map) {
      replies = (comment['replies'] as Map).values.toList();
    } else {
      replies = comment['replies'] ?? [];
    }

    String username = comment['username'] ?? 'Unknown';
    String commentText = comment['comment'] ?? '';
    int likes = comment['likes'] ?? 0;
    bool likedByMe = comment['likedByMe'] ?? false;
    String profilePic = comment['profilePic'] ?? '';

    return Padding(
      padding: EdgeInsets.only(left: 20.0 * level),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Displaying a single comment
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                profilePic.isNotEmpty
                    ? CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Image.network(profilePic),
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person),
                      ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username,
                          style: const TextStyle(color: Colors.white60)),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(commentText, style: const TextStyle(fontSize: 16)),
                      const SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          Text("$likes likes",
                              style: const TextStyle(color: Colors.grey)),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              onReplyTap(comment['key'] ??
                                  ''); // Pass the unique comment ID
                            },
                            child: Text(
                              "Reply",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                likedByMe
                    ? Icon(Icons.favorite, color: Colors.red)
                    : Icon(Icons.favorite_outline, color: Colors.grey),
              ],
            ),
          ),
          // Recursively display replies
          for (var reply in replies)
            CommentWidget(
                comment: reply,
                level: level + 1,
                onReplyTap: onReplyTap // Pass the same callback function
                ),
        ],
      ),
    );
  }
}

class CommentScreen extends StatefulWidget {
  final PostModel postModel;
  const CommentScreen(this.postModel, {super.key});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _scacffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController commentController = TextEditingController(text: '');
  Stream<DatabaseEvent>? commentStream;
  String? username;
  late AuthState auth;
  String? replyToUsername;
  String? replyToCommentID;

  getComments() async {
    commentStream =
        kDatabase.child("Comments").child(widget.postModel.key!).onValue;
    setState(() {});
  }

  bool switcher = false;

  void switcherFunc() {
    setState(() {
      switcher = !switcher;
    });
  }

  String calcTimesAgo(DateTime dt) {
    Duration dur = DateTime.now().difference(dt);
    print(dur.inHours);
    if (dur.inSeconds < 60) {
      return dur.inSeconds == 1
          ? "${dur.inSeconds} sec ago"
          : "${dur.inSeconds} sec ago";
    }
    if (dur.inMinutes >= 1 && dur.inMinutes < 60) {
      return dur.inMinutes == 1
          ? "${dur.inMinutes} min ago"
          : "${dur.inMinutes} mins ago";
    }
    if (dur.inHours >= 1 && dur.inHours < 60) {
      return dur.inHours == 1
          ? "${dur.inHours} hour ago"
          : "${dur.inHours} hours ago";
    }
    if (dur.inHours > 60) {
      DateTime dateNow =
          DateTime.parse(DateTime.now().toString().substring(0, 10));
      DateTime dte = DateTime.parse(dt.toString().substring(0, 10));
      String date = dateNow.compareTo(dte) == 0
          ? "Today"
          : "${dte.year} ${dte.month} ${dte.day}" ==
                  "${dateNow.year} ${dateNow.month} ${(dateNow.day) - 1}"
              ? "Yesterday"
              : formatDate(dte, [M, ' ', dd, ', ', yyyy]);
      return date;
    }
    return "";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = Provider.of<AuthState>(context, listen: false);
    getComments();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return SafeArea(
      child: Scaffold(
        /*appBar: AppBar(
          title: Text("Comments"),
        ),*/
        body: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: Colors.black,
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: switcherFunc,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              child: Stack(
                                children: [
                                  ImageFiltered(
                                    imageFilter: ui.ImageFilter.blur(
                                        sigmaX: 15.0, sigmaY: 15.0),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      imageUrl: switcher
                                          ? widget.postModel.imageFrontPath
                                              .toString()
                                          : widget.postModel.imageBackPath
                                              .toString(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        height: 120,
                                        width: 100,
                                        child: ImageFiltered(
                                          imageFilter: ui.ImageFilter.blur(
                                              sigmaX: 10.0, sigmaY: 10.0),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: !switcher
                                                ? widget
                                                    .postModel.imageFrontPath
                                                    .toString()
                                                : widget.postModel.imageBackPath
                                                    .toString(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(15),
                    height: 250,
                    width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: switcherFunc,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: SizedBox(
                                    height: 220,
                                    width: MediaQuery.of(context).size.width,
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            imageUrl: switcher
                                                ? widget
                                                    .postModel.imageFrontPath
                                                    .toString()
                                                : widget.postModel.imageBackPath
                                                    .toString()),
                                        Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: SizedBox(
                                                    height: 75,
                                                    width: 50,
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
                    ))
              ],
            ),
            Expanded(
              child: Stack(children: [
                StreamBuilder<DatabaseEvent>(
                  stream: commentStream!,
                  builder: (context, snapshot) {
                    List items = [];
                    if (snapshot.hasData) {
                      if (snapshot.data!.snapshot.value != null) {
                        Map itemss = snapshot.data!.snapshot.value as Map;
                        itemss.forEach((key, value) {
                          Map item = value as Map;
                          item["key"] = key;
                          items.add(item);
                        });
                      }
                    }

                    // Sort items based on 'parentCommentID'
                    items.sort((a, b) {
                      String? parentA = a['parentCommentID'];
                      String? parentB = b['parentCommentID'];
                      return (parentA ?? "").compareTo(parentB ?? "");
                    });

                    return snapshot.hasData
                        ? (items.isNotEmpty
                            ? Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: ListView.builder(
                                    padding: const EdgeInsets.only(top: 15),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      // Determine the level based on whether it's a reply or not
                                      int level = items[index]
                                                  ['parentCommentID'] !=
                                              null
                                          ? 1
                                          : 0;
                                      return CommentWidget(
                                          comment: items[index],
                                          level: level,
                                          onReplyTap: (String commentID) {
                                            print(
                                                "Replying to comment with ID: $commentID");
                                            setState(() {
                                              replyToCommentID = commentID;
                                              replyToUsername =
                                                  items[index]['username'];
                                            });
                                          });
                                    }))
                            : SizedBox(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: const Center(
                                    child: Text("No user has commented yet"))))
                        : SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.black)),
                          );
                  },
                ),
                Positioned(
                  bottom: 15,
                  left: 8,
                  right: 8,
                  child: _commentRow(widget.postModel.key!),
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void addReplyToComment(String postID, String parentCommentID, String reply) {
    DatabaseReference ref = kDatabase.child("Comments").child(postID).push();
    ref.set({
      "parentCommentID": parentCommentID,
      "username": auth.userModel!.userName,
      "comment": reply,
      "date": DateTime.now().toUtc().toString(),
      "likes": 0,
      "likedByMe": false,
      "profilePic": auth.userModel!.profilePic,
    });
  }

  Widget _commentRow(String postID) {
    return Container(
      decoration: BoxDecoration(
        //border: Border.all(color: Colors.white),
        color: Colors.grey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              cursorColor: Colors.white,
              controller: commentController,
              decoration: InputDecoration(
                suffixIconColor: Colors.black,
                border: InputBorder.none,
                hintText: replyToUsername != null
                    ? 'Replying to $replyToUsername'
                    : 'Write Your Comment',
                hintStyle: const TextStyle(color: Colors.black45),
                prefix: const Text("  "),
                suffixIcon: GestureDetector(
                  onTap: () async {
                    if (commentController.text.isNotEmpty) {
                      if (replyToCommentID != null) {
                        // Handle the reply here
                        addReplyToComment(widget.postModel.key!,
                            replyToCommentID!, commentController.text);
                        replyToCommentID = null; // Reset the replyToCommentID
                        replyToUsername = null; // Reset the replyToUsername
                      } else {
                        // Handle the normal comment here
                        DatabaseReference ref = kDatabase
                            .child("Comments")
                            .child(widget.postModel.key!)
                            .push();
                        await ref.set({
                          "username": auth.userModel!.userName,
                          "date": DateTime.now().toUtc().toString(),
                          "profilePic": auth.userModel!.profilePic,
                          "comment": commentController.text,
                          "likes": 0,
                          "likedByMe": false,
                          "replies": [] // Initialize an empty replies list
                        });
                      }
                      commentController.text = "";
                    }
                  },
                  child: const Icon(Icons.send),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
