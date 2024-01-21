import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/pages/comments.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/physics.dart';

import '../pages/profile_page.dart';

class FeedPostWidget extends StatefulWidget {
  final PostModel postModel;
  final double scaleFactor; // Add this line

  FeedPostWidget({required this.postModel, this.scaleFactor = 1.0, Key? key})
      : super(key: key);

  @override
  State<FeedPostWidget> createState() => _FeedPostWidgetState();
}

class _FeedPostWidgetState extends State<FeedPostWidget>
    with SingleTickerProviderStateMixin {
  bool switcher = false;
  late AnimationController _animationController;
  TextEditingController captionController = TextEditingController();
  Offset _offset = Offset(20, 20); // Initialize to 20 pixels from top and left

  int commentCount = 0;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    fetchLatestPostData(); // Fetch the latest post data when the widget initializes
    _listenToCommentCount();
  }

  void _listenToCommentCount() {
    DatabaseReference commentsRef = FirebaseDatabase.instance
        .reference()
        .child('Comments')
        .child(widget.postModel.key!);

    commentsRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          commentCount = (event.snapshot.value as Map).length;
        });
      } else {
        setState(() {
          commentCount = 0;
        });
      }
    });
  }

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();

  Future<void> updateCaptionInDatabase(String newCaption) async {
    await _databaseRef
        .child('posts')
        .child(widget.postModel.groupChat!.key!)
        .child(widget.postModel.key!) // Replace with the actual post ID
        .update({'caption': newCaption});
  }

  Future<void> fetchLatestPostData() async {
    // Fetch the latest post data from the database
    // Replace with your actual fetching logic
    DatabaseEvent event = await _databaseRef
        .child('posts')
        .child(widget.postModel.groupChat!.key!)
        .child(widget.postModel.key!) // Replace with the actual post ID
        .once();

    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        widget.postModel.caption = data['caption'];
        captionController.text = data['caption'] ?? "Add A Caption...";
      });
    }
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
        bool isCurrentUserCreator = FirebaseAuth.instance.currentUser!.uid ==
            widget.postModel.user?.userId;

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
                                  "https://i.pinimg.com/550x/80/e8/40/80e8406626428e1d6387061f9783abd1.jpg",
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
                      PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10.0), // This gives the popup menu rounded corners
                        ),
                        icon: Icon(Icons.more_horiz, color: Colors.white),
                        onSelected: (String result) {
                          switch (result) {
                            case 'View profile':
                              Navigator.push(
                                context,
                                ProfilePage.getRoute(
                                  profileId: widget.postModel.user!.userId ??
                                      'default_value',
                                  isadded: isadded,
                                  user: widget.postModel.user!,
                                ),
                              );
                              break;
                            case 'Block this user':
                              // TODO: Block user logic here
                              break;
                            case 'Report this user':
                              // TODO: Report user logic here
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'View profile',
                            child: Text('View profile'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Block this user',
                            child: Text('Block this user'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Report this user',
                            child: Text('Report this user'),
                          ),
                        ],
                      )
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
                            width: MediaQuery.of(context).size.width *
                                widget.scaleFactor,
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
                      builder: (ctx) => CommentScreen(widget.postModel),
                    ),
                  );
                },
                child: Text(
                  commentCount == 0
                      ? "Add a comment..."
                      : commentCount == 1
                          ? "View Comment"
                          : "View all $commentCount comments",
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 1.5, // Adjust as needed
              left: 20,
              child: Container(
                width: MediaQuery.of(context).size.width - 40, // Set width here
                child: isCurrentUserCreator
                    ? TextFormField(
                        controller: captionController,
                        style: TextStyle(color: Colors.grey),
                        onTap: () {
                          captionController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: captionController.text.length));
                        },
                        onFieldSubmitted: (String newCaption) async {
                          // Update the caption in Realtime Database
                          await updateCaptionInDatabase(newCaption);

                          // Re-fetch the post data here to get the updated caption
                          await fetchLatestPostData();
                        },
                        decoration: InputDecoration(
                          hintText: "Add A Caption...", // Add this line
                          hintStyle:
                              TextStyle(color: Colors.grey), // Add this line
                          border: InputBorder.none,
                        ),
                      )
                    : Text(
                        widget.postModel.caption ??
                            "", // Show the caption text if it exists
                        style: TextStyle(color: Colors.grey),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
