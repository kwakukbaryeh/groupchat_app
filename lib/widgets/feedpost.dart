import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/pages/comments.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/physics.dart';

import '../pages/profile_page.dart';
import '../services/user_tile_page.dart';

class FeedPostWidget extends StatefulWidget {
  final PostModel postModel;

  FeedPostWidget({required this.postModel, Key? key}) : super(key: key);

  @override
  State<FeedPostWidget> createState() => _FeedPostWidgetState();
}

class _FeedPostWidgetState extends State<FeedPostWidget>
    with SingleTickerProviderStateMixin {
  bool switcher = false;
  late AnimationController _animationController;
  Offset _offset = Offset(20, 20); // Initialize to 20 pixels from top and left

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void switcherFunc() {
    setState(() {
      switcher = !switcher;
    });
  }

  void _runAnimation() {
    final spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(
      spring,
      0,
      1,
      0,
    );

    _animationController.animateWith(simulation);

    _animationController.addListener(() {
      setState(() {
        final endOffset = _getFinalOffset();
        final double dx = _offset.dx +
            (endOffset.dx - _offset.dx) * _animationController.value;
        final double dy = _offset.dy +
            (endOffset.dy - _offset.dy) * _animationController.value;
        _offset = Offset(dx, dy);
      });
    });
  }

  Offset _getFinalOffset() {
    double imageScreenWidth = MediaQuery.of(context)
        .size
        .width; // Replace with actual width of the image screen
    double imageScreenHeight = MediaQuery.of(context).size.height /
        1.63; // Replace with actual height of the image screen

    double halfWidth = imageScreenWidth / 2;
    double halfHeight = imageScreenHeight / 2;

    double selfieBoxWidth = MediaQuery.of(context).size.width / 4;
    double selfieBoxHeight = MediaQuery.of(context).size.height / 6;

    double dx = _offset.dx < halfWidth
        ? 20 // 20 pixels away from the left
        : imageScreenWidth -
            selfieBoxWidth -
            20; // 20 pixels away from the right

    double dy = _offset.dy < halfHeight
        ? 20 // 20 pixels away from the top
        : imageScreenHeight -
            selfieBoxHeight -
            20; // 20 pixels away from the bottom

    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    String localisation;
    if (widget.postModel.user?.localisation.toString().replaceAll("null", "") ==
        "") {
      localisation = "";
    } else {
      localisation = "${widget.postModel.user!.localisation} •";
    }

    DateTime now = DateTime.now();
    DateTime createdAt = DateTime.parse(widget.postModel.createdAt);
    Duration difference = now.difference(createdAt);

    String timeAgo;

    if (difference.inSeconds < 60) {
      timeAgo = 'A few seconds ago';
    } else if (difference.inMinutes < 60) {
      int minutes = difference.inMinutes;
      timeAgo = '$minutes minute${minutes > 1 ? 's' : ''} ago';
    } else {
      int hours = difference.inHours;
      timeAgo = '$hours hour${hours > 1 ? 's' : ''} ago';
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("friendship")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("friends")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return CircularProgressIndicator(); // Loading
        }

        List ids = [];
        List docs = snapshot.data!.docs;
        for (DocumentSnapshot doc in docs) {
          ids.add(doc["userId"]);
        }
        bool isadded = ids.contains(widget.postModel.user?.userId);

        print("username in StreamBuilder: ${widget.postModel.user?.userName}");

        return Stack(
          children: [
            Container(
              color: Colors.black,
              height: MediaQuery.of(context).size.height / 1.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          print(
                              "isadded in StreamBuilder: $isadded"); // Debugging print
                          print(
                              "userId in StreamBuilder: ${widget.postModel.user?.userId}");
                          print(
                              "username in StreamBuilder: ${widget.postModel.user?.userName}");

                          // Navigate to user's profile page
                          Navigator.push(
                            context,
                            ProfilePage.getRoute(
                              profileId: widget.postModel.user!.userId ??
                                  'default_value',
                              isadded: isadded,
                              user: widget.postModel.user!,
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: SizedBox(
                            height: 35,
                            width: 35,
                            child: CachedNetworkImage(
                              imageUrl: widget.postModel.user?.profilePic ??
                                  "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg",
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to user's profile page
                          Navigator.push(
                            context,
                            ProfilePage.getRoute(
                              profileId: widget.postModel.user!.userId ??
                                  'default_value',
                              isadded: isadded,
                              user: widget.postModel.user!,
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "${widget.postModel.user!.displayName}\n",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: "$localisation $timeAgo",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                      ),
                      Icon(Icons.more_horiz, color: Colors.white),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: switcherFunc,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height / 1.63,
                            width: MediaQuery.of(context).size.width,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: switcher
                                  ? widget.postModel.imageFrontPath.toString()
                                  : widget.postModel.imageBackPath.toString(),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Positioned(
                              left: _offset.dx,
                              top: _offset.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _offset += details.delta;
                                  });
                                },
                                onPanEnd: (details) {
                                  _runAnimation();
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 6,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: !switcher
                                          ? widget.postModel.imageFrontPath
                                              .toString()
                                          : widget.postModel.imageBackPath
                                              .toString(),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            widget.postModel.taggedUsers == null
                ? Container()
                : Positioned(
                    top: MediaQuery.of(context).size.height / 1.43,
                    left: 20,
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
                                    "Tagged Friends",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Expanded(
                                    child: GridView.builder(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 30),
                                        itemCount: widget
                                            .postModel.taggedUsers!.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 30,
                                        ),
                                        itemBuilder: (ctx, index) {
                                          return widget
                                                      .postModel
                                                      .taggedUsers![index]
                                                      .profilePic !=
                                                  null
                                              ? InkWell(
                                                  onTap: () {},
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Image.network(widget
                                                        .postModel
                                                        .taggedUsers![index]
                                                        .profilePic!),
                                                  ),
                                                )
                                              : InkWell(
                                                  onTap: () {},
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
                                widget.postModel.taggedUsers!.length.toString(),
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          )),
                    )),
            Positioned(
                top: MediaQuery.of(context).size.height / 1.41,
                left: widget.postModel.taggedUsers == null ? 15 : 90,
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) =>
                                  CommentScreen(widget.postModel)));
                    },
                    child: Text("View Comments")))
          ],
        );
      },
    );
  }
}
