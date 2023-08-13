import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/pages/comments.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';

class FeedPostWidget extends StatefulWidget {
  PostModel postModel;

  FeedPostWidget({required this.postModel, super.key});

  @override
  State<FeedPostWidget> createState() => _FeedPostWidgetState();
}

class _FeedPostWidgetState extends State<FeedPostWidget> {
  bool switcher = false;

  void switcherFunc() {
    setState(() {
      switcher = !switcher;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Rendering FeedPostWidget: ${widget.postModel.key}");
    var state = Provider.of<AuthState>(context);
    String localisation;
    if (widget.postModel.user?.localisation.toString().replaceAll("null", "") ==
        "") {
      localisation = "";
    } else {
      localisation = widget.postModel.user!.localisation.toString() + " •";
    }

    DateTime now = DateTime.now();
    DateTime createdAt = DateTime.parse(widget.postModel.createdAt);
    Duration difference = now.difference(createdAt);

    String timeAgo;

    if (difference.inSeconds < 60) {
      timeAgo = 'A few seconds ago';
    } else if (difference.inMinutes < 60) {
      int minutes = difference.inMinutes;
      timeAgo = 'Few $minutes minute${minutes > 1 ? 's' : ''} ago';
    } else {
      int hours = difference.inHours;
      timeAgo = 'Few $hours heure${hours > 1 ? 's' : ''} ago';
    }
    return Stack(
      children: [
        Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height / 1.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 35,
                        width: 35,
                        child: CachedNetworkImage(
                          imageUrl: widget.postModel.user?.profilePic ??
                              "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg",
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                widget.postModel.user!.displayName.toString() +
                                    "\n",
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
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                    ),
                    Icon(Icons.more_horiz, color: Colors.white)
                  ],
                ),
                Container(
                  height: 10,
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
                                        height:
                                            MediaQuery.of(context).size.height /
                                                1.63,
                                        child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: switcher
                                                ? widget
                                                    .postModel.imageFrontPath
                                                    .toString()
                                                : widget.postModel.imageBackPath
                                                    .toString()))),
                                Padding(
                                    padding: EdgeInsets.all(20),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
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
                                                    : widget
                                                        .postModel.imageBackPath
                                                        .toString())))),
                              ],
                            )))),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            )),
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
                                    itemCount:
                                        widget.postModel.taggedUsers!.length,
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
                                                backgroundColor: Colors.white,
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
                          builder: (ctx) => CommentScreen(widget.postModel)));
                },
                child: Text("View Comments")))
      ],
    );
  }
}
