import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/helper/utility.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';

class CommentScreen extends StatefulWidget {
  final PostModel postModel;
  CommentScreen(this.postModel);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _scacffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController commentController = TextEditingController(text: '');
  Stream<DatabaseEvent>? commentStream;
  String? username;
  late AuthState auth;
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
                Opacity(
                  opacity: 0.2,
                  child: Container(
                      color: Colors.black,
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                              onTap: switcherFunc,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                      height: 200,
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
                                                  : widget
                                                      .postModel.imageBackPath
                                                      .toString()),
                                          Padding(
                                              padding: EdgeInsets.all(15),
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                      height: 100,
                                                      width: 100,
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
                ),
                Container(
                    padding: EdgeInsets.all(15),
                    height: 200,
                    width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: switcherFunc,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                    height: 170,
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
                                            padding: EdgeInsets.all(15),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                    height: 50,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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

                      return snapshot.hasData
                          ? items.isNotEmpty
                              ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: ListView.builder(
                                      padding: EdgeInsets.only(top: 15),
                                      physics: BouncingScrollPhysics(),
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        items.sort((a, b) =>
                                            DateTime.parse(a["date"]).isBefore(
                                                    DateTime.parse(b["date"]))
                                                ? 0
                                                : 1);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              items[index]["profilePic"] != null
                                                  ? CircleAvatar(
                                                      radius: 30,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Image.network(
                                                          items[index]
                                                              ["profilePic"]),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      child: CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          height: 50,
                                                          imageUrl: state
                                                                  .profileUserModel
                                                                  ?.profilePic ??
                                                              "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg")),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "${items[index]["username"]}",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white60)),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                        "${items[index]["comment"]}",
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                        "${items[index]["likes"]} likes",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              items[index]["likedByMe"]
                                                  ? InkWell(
                                                      onTap: () {
                                                        DatabaseReference ref =
                                                            kDatabase
                                                                .child(
                                                                    "Comments")
                                                                .child(widget
                                                                    .postModel
                                                                    .key!)
                                                                .child(items[
                                                                        index]
                                                                    ["key"]);
                                                        ref.child("likes").set(
                                                            items[index]
                                                                    ["likes"] -
                                                                1);
                                                        ref
                                                            .child("likedByMe")
                                                            .set(false);
                                                      },
                                                      child:
                                                          Icon(Icons.favorite))
                                                  : InkWell(
                                                      onTap: () {
                                                        DatabaseReference ref =
                                                            kDatabase
                                                                .child(
                                                                    "Comments")
                                                                .child(widget
                                                                    .postModel
                                                                    .key!)
                                                                .child(items[
                                                                        index]
                                                                    ["key"]);
                                                        ref.child("likes").set(
                                                            items[index]
                                                                    ["likes"] +
                                                                1);
                                                        ref
                                                            .child("likedByMe")
                                                            .set(true);
                                                      },
                                                      child: Icon(Icons
                                                          .favorite_outline))
                                            ],
                                          ),
                                        );
                                      }))
                              : Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                      child: Text("No user has commented yet")))
                          : Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              )));
                    }),
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
                //filled: true,
                //fillColor: Colors.white60,
                suffixIconColor: Colors.black,
                border: InputBorder.none,
                hintText: 'Write Your Comment',
                hintStyle: TextStyle(color: Colors.black45),
                prefix: Text("  "),
                suffixIcon: GestureDetector(
                    onTap: () async {
                      if (commentController.text.isNotEmpty) {
                        DatabaseReference ref =
                            kDatabase.child("Comments").child(postID).push();
                        await ref.set({
                          "username": auth.userModel!.userName,
                          "date": DateTime.now().toUtc().toString(),
                          "profilePic": auth.userModel!.profilePic,
                          "comment": commentController.text,
                          "likes": 0,
                          "likedByMe": false
                        });
                        commentController.text = "";
                      }
                    },
                    child: Icon(Icons.send)),
                /*suffixIconConstraints: BoxConstraints(
                      maxHeight: 35, minHeight: 35, maxWidth: 35, minWidth: 35)*/
              ),
            ),
          ),
        ],
      ),
    );
  }
}
