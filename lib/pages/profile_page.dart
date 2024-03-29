// ignore_for_file: deprecated_member_use, unnecessary_null_comparison
import 'dart:developer';
import 'dart:ui';
import 'package:awesome_icons/awesome_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/state/post_state.dart';
import 'package:groupchat_firebase/state/profile_state.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:groupchat_firebase/pages/chat_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(
      {Key? key,
      required this.profileId,
      required this.isadded,
      required this.user,
      this.scaffoldKey})
      : super(key: key);
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String profileId;
  final bool isadded;
  final UserModel user;

  static PageRouteBuilder getRoute(
      {required String profileId,
      required bool isadded,
      required UserModel user}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Provider(
          create: (_) => ProfileState(profileId),
          child: ChangeNotifierProvider(
            create: (BuildContext context) => ProfileState(profileId),
            builder: (_, child) => ProfilePage(
              profileId: profileId,
              isadded: isadded,
              user: user,
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isMyProfile = false;
  int pageIndex = 0;
  int counter = 3;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var authstate = Provider.of<ProfileState>(context, listen: false);
      isMyProfile = authstate.isMyProfile;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  final controller = ScrollController();

  double rateScroll = 0;
  double opacity = -5;

  void _shareText(String name) {
    Share.share(
      "https://keepUp/$name",
      subject: "Join keepUp with $name.",
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 10, 10),
    );
  }

  Widget floatingButton() {
    return rateScroll >= -855
        ? Container()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 35),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.animateTo(0,
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut);
                      });
                    },
                    child: Container(
                        color: Colors.white,
                        height: 50,
                        width: 50,
                        child: const Icon(
                          FontAwesomeIcons.angleUp,
                        )),
                  ),
                ),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<PostState>(context);
    var authstate = Provider.of<ProfileState>(context);

    List<PostModel>? list;
    String id = widget.profileId;
    DateTime now = DateTime.now();

    if (state.groupChatPostMap != null && state.groupChatPostMap.isNotEmpty) {
      log(state.groupChatPostMap.toString());
      list = state.groupChatPostMap.values
          .expand((postList) => postList!) // Flatten the list of lists
          .where(
              (x) => now.difference(DateTime.parse(x.createdAt)).inHours < 104)
          .toList();
    }
    list ??= [];
    list.insert(
        0,
        PostModel(
          imageFrontPath:
              "https://htmlcolorcodes.com/assets/images/colors/black-color-solid-background-1920x1080.png",
          imageBackPath:
              "https://htmlcolorcodes.com/assets/images/colors/black-color-solid-background-1920x1080.png",
          createdAt: "",
          bio: "",
          user: UserModel(
            displayName: "",
          ),
        ));
    DateTime? createdAt;

    if (list.last.createdAt.isNotEmpty) {
      createdAt = DateTime.parse(list.last.createdAt);
    }
    String? timeAgo;
    if (createdAt != null) {
      Duration difference = now.difference(createdAt);

      if (difference.inSeconds < 60) {
        timeAgo = 'A few seconds ago';
      } else if (difference.inMinutes < 60) {
        int minutes = difference.inMinutes;
        timeAgo = 'Il y a $minutes minute${minutes > 1 ? 's' : ''}';
      } else {
        int hours = difference.inHours;
        timeAgo = 'Il y a $hours heure${hours > 1 ? 's' : ''}';
      }
    }
    return authstate.isbusy
        ? Container()
        : WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
                floatingActionButton: floatingButton(),
                key: scaffoldKey,
                backgroundColor: Colors.black,
                body: NestedScrollView(
                    controller: controller,
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    headerSliverBuilder: (context, value) {
                      return [
                        SliverAppBar(
                          leading: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: Colors.white,
                                size: 30,
                              )),
                          actions: [
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                                size: 30,
                              ),
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'block',
                                  child: ListTile(
                                    leading: Icon(Icons.block),
                                    title: Text('Block'),
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'removeFriendship',
                                  child: ListTile(
                                    leading: Icon(Icons.remove),
                                    title: Text('Remove Friendship'),
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'report',
                                  child: ListTile(
                                    leading: Icon(Icons.report),
                                    title: Text('Report'),
                                  ),
                                ),
                              ],
                              onSelected: (String value) {
                                // Handle the selected option here
                                if (value == 'share') {
                                  // Implement share profile action
                                } else if (value == 'block') {
                                  // Implement block action
                                } else if (value == 'removeFriendship') {
                                  // Implement remove friendship action
                                } else if (value == 'report') {
                                  // Implement report action
                                }
                              },
                            ),
                            Container(
                              width: 10,
                            ),
                          ],
                          centerTitle: true,
                          pinned: true,
                          stretch: true,
                          elevation: 0,
                          onStretchTrigger: () {
                            return Future<void>.value();
                          },
                          title:
                              Text(widget.user.userName!.replaceAll("@", "")),
                          backgroundColor: Colors.black.withOpacity(0),
                          expandedHeight:
                              MediaQuery.of(context).size.height / 2.2,
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.pin,
                            stretchModes: const <StretchMode>[
                              StretchMode.zoomBackground,
                            ],
                            centerTitle: true,
                            expandedTitleScale: 3,
                            titlePadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            background: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height / 2,
                                  padding: const EdgeInsets.only(top: 0),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: authstate
                                            .profileUserModel.profilePic ??
                                        'https://firebasestorage.googleapis.com/v0/b/nfts-a5f24.appspot.com/o/files%2Fbackground.png?alt=media&token=89375e94-d52e-4e69-8f97-94cf665f43ba',
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 150),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomRight,
                                        end: Alignment.topRight,
                                        colors: [
                                          for (double i = 1; i > 0; i -= 0.01)
                                            Colors.black.withOpacity(i),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 0,
                                    top: MediaQuery.of(context).size.height /
                                        2.25,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        authstate.profileUserModel.displayName!,
                                        style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 38,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.96,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Container(
                                        width: 100,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _shareText(authstate
                                              .userModel.userName!
                                              .replaceAll("@", ""));
                                        },
                                        child: Container(
                                          height: 35,
                                          width: 35,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            CupertinoIcons.share,
                                            color: Colors.black,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          print("Send icon tapped!");
                                          User? firebaseUser =
                                              FirebaseAuth.instance.currentUser;
                                          print("Firebase User: $firebaseUser");
                                          if (firebaseUser != null) {
                                            UserModel? userModel =
                                                await UserModel.fromDatabase(
                                                    firebaseUser.uid);
                                            print("User Model: $userModel");
                                            if (userModel != null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatScreen(
                                                    sender: userModel,
                                                    receiver: widget.user,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          height: 35,
                                          width: 35,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.send,
                                            color: Colors.black,
                                            size: 18,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            <Widget>[
                              Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    authstate.profileUserModel.bio ?? "",
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 0.96,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.left,
                                  )),
                              isMyProfile
                                  ? Container()
                                  : widget.isadded
                                      ? Container()
                                      : Center(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 20, 0, 0),
                                            child: GestureDetector(
                                                onTap: () async {
                                                  User? user = FirebaseAuth
                                                      .instance.currentUser;
                                                  if (user != null) {
                                                    print("called");
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            "friendship")
                                                        .doc(user.uid)
                                                        .set({"d": "d"});
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            "friendship")
                                                        .doc(user.uid)
                                                        .collection("friends")
                                                        .add({
                                                      "email":
                                                          widget.user.email,
                                                      "userId":
                                                          widget.user.userId,
                                                      "userName":
                                                          widget.user.userName,
                                                      "displayName": widget
                                                          .user.displayName,
                                                      "localisation": widget
                                                          .user.localisation,
                                                      "bio": widget.user.bio,
                                                      "profilePic": widget
                                                          .user.profilePic,
                                                      "key": widget.user.key,
                                                      "createAt":
                                                          widget.user.createAt,
                                                      "fcmToken":
                                                          widget.user.fcmToken
                                                    });
                                                  }
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Container(
                                                      color: Colors.white,
                                                      height: 45,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.1,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            CupertinoIcons
                                                                .person_crop_circle_badge_plus,
                                                            color: Colors.black,
                                                            size: 20,
                                                          ),
                                                          Container(
                                                            width: 9,
                                                          ),
                                                          const Text(
                                                            'Add',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 9,
                                                          ),
                                                        ],
                                                      )),
                                                )),
                                          ),
                                        ),
                              Container(
                                height: 7,
                              ),
                              isMyProfile
                                  ? Container()
                                  : widget.isadded
                                      ? Container()
                                      : Text(
                                          'Add your friends on App Title.',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                              isMyProfile
                                  ? Container()
                                  : widget.isadded
                                      ? Container()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 20, left: 20),
                                              child: Text(
                                                'FRIENDS IN COMMON ()',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 231, 231, 231),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 100,
                                                child: ListView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  children: const [],
                                                ))
                                          ],
                                        )
                            ],
                          ),
                        ),
                      ];
                    },
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 20, sigmaY: 20),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: SizedBox(
                                          height: 150,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.2,
                                          child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: list.last.imageFrontPath
                                                  .toString()),
                                        )))),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 20, sigmaY: 20),
                                    child: Container(
                                      height: 155,
                                      width: MediaQuery.of(context).size.width /
                                          1.2,
                                      color: Colors.transparent,
                                    ))),
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                ),
                                Stack(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                            height: 125,
                                            width: 90,
                                            child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: list
                                                    .last.imageBackPath
                                                    .toString()))),
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 5, sigmaY: 5),
                                            child: Container(
                                              height: 125,
                                              width: 90,
                                              color: Colors.transparent,
                                            ))),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      timeAgo == null
                                          ? ""
                                          : "   BeReal of The Day",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      timeAgo == null ? "" : "   $timeAgo",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: 80,
                                    ),
                                    Text(
                                      "   ${list.last.bio ?? ""}",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      textAlign: TextAlign.left,
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ))));
  }
}

class Choice {
  const Choice(
      {required this.title, required this.icon, this.isEnable = false});
  final bool isEnable;
  final IconData icon;
  final String title;
}

const List<Choice> choices = <Choice>[
  Choice(title: 'Share', icon: Icons.directions_car, isEnable: true),
  Choice(title: 'QR code', icon: Icons.directions_railway, isEnable: true),
];
