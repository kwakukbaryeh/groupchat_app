import 'dart:developer';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:groupchat_firebase/camera/camera.dart';
import 'package:groupchat_firebase/helper/utility.dart';
import 'package:groupchat_firebase/models/groupchat.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/pages/group_users.dart';
import 'package:groupchat_firebase/pages/homepage.dart';
import 'package:groupchat_firebase/pages/shareqr.dart';
import 'package:groupchat_firebase/services/user_tile_page.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/state/groupchatState.dart';
import 'package:groupchat_firebase/state/post_state.dart';
import 'package:groupchat_firebase/state/search_state.dart';
import 'package:groupchat_firebase/widgets/feedpost.dart';
import 'package:groupchat_firebase/widgets/gridpost.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatefulWidget {
  final GroupChat groupChat;

  const GroupScreen({Key? key, required this.groupChat}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledDown = false;
  bool _isGrid = false;
  DatabaseReference postsRef =
      FirebaseDatabase.instance.reference().child('posts');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
    postsRef.onChildRemoved.listen((event) {
      print("Post Removed: ${event.snapshot.key}");
      // If a child (post) is removed, reset the state
      _resetGroupScreenState(event.snapshot);
    });
  }

  void _resetGroupScreenState(DataSnapshot event) {
    var postState = Provider.of<PostState>(context, listen: false);
    postState.removePostFromState(
        widget.groupChat.key!, event.key!); // adjusted this line
  }

  Future<void> _initData() async {
    var authState = Provider.of<AuthState>(context, listen: false);
    var postState = Provider.of<PostState>(context, listen: false);
    var searchState = Provider.of<SearchState>(context, listen: false);

    authState.getCurrentUser();
    authState.databaseInit();

    await postState.databaseInit([widget.groupChat], authState.userModel);
    await postState.getDataFromDatabaseForGroupChat(
        widget.groupChat.key!,
        widget.groupChat.participantIds ??
            []); // Assuming GroupChat has a participantIds field

    searchState.getDataFromDatabase();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      setState(() {
        _isScrolledDown = true;
      });
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      setState(() {
        _isScrolledDown = false;
      });
    }
  }

  Future _bodyView() async {
    if (_isGrid) {
      setState(() {
        _isGrid = false;
      });
    } else {
      setState(() {
        _isGrid = true;
      });
    }
  }

  int tab = 0;

  Widget empty(List<PostModel>? groupList) {
    print("Checking condition: groupList == null || groupList.isEmpty");
    print("groupList: $groupList");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "No one in your group has posted, post something to break the ice!",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraPage(
                    groupChat: widget.groupChat,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
            ),
            child: const Text("Post a photo"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    final state = Provider.of<SearchState>(context);
    final groupChatsState = Provider.of<GroupChatState>(context);
    final postState =
        Provider.of<PostState>(context); // Add this line to access PostState

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: AnimatedOpacity(
        opacity: tab == 1 ? 0 : 1,
        duration: const Duration(milliseconds: 301),
        child: Container(
          height: 150,
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Conditionally show or hide the circle button
              if (!(postState.hasPostedInGroup[
                      '${widget.groupChat.key}_${authState.userId}'] ??
                  false))
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraPage(
                          groupChat: widget.groupChat,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Container(
                height: 40,
              ),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
        ),
        toolbarHeight: 37,
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 40),
              child: PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      10.0), // This will give the popup menu rounded corners
                ),
                onSelected: (String result) async {
                  // Handle the selected menu item
                  print('Selected: $result');
                  if (result == "0") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) =>
                                ShareQr(groupChat: widget.groupChat)));
                  }
                  if (result == "1" &&
                      authState.userId == widget.groupChat.creatorId) {
                    if (state.userlist != null) {
                      List<UserModel> users = state.userlist!
                          .where((element) => widget.groupChat.participantIds
                              .contains(element.userId))
                          .toList();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => GroupUsers(
                                    groupUsers: users,
                                    groupChat: widget.groupChat,
                                  )));
                    }
                  }
                  if (result == "2" &&
                      authState.userId == widget.groupChat.creatorId) {
                    kDatabase
                        .child("groupchats")
                        .child(widget.groupChat.key!)
                        .remove();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.blue,
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Group deleted successfully",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )));
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (ctx) => HomePage()),
                        (route) => false);
                  }
                  if (result == "3") {
                    DatabaseEvent event = await kDatabase
                        .child("groupchats")
                        .child(widget.groupChat.key!)
                        .child("participantIds")
                        .once();

                    if (event.snapshot.value is List) {
                      List<String> list = (event.snapshot.value as List)
                          .map((e) => e.toString())
                          .toList();
                      List<String> newlist = [];

                      // Remove the current user's ID from the list
                      for (var id in list) {
                        if (id != authState.userId) {
                          newlist.add(id);
                        }
                      }

                      // Update the participantIds in the database with the new list
                      event.snapshot.ref.set(newlist);

                      // Remove the user's FCM token from the participantFcmTokens
                      final fcmTokenEvent = await kDatabase
                          .child("groupchats")
                          .child(widget.groupChat.key!)
                          .child("participantFcmTokens")
                          .once();

                      if (fcmTokenEvent.snapshot.value is List) {
                        List<String> fcmTokens =
                            (fcmTokenEvent.snapshot.value as List)
                                .map((e) => e.toString())
                                .toList();
                        fcmTokens.remove(authState
                            .userFcmToken); // assuming you have the user's FCM token in authState
                        fcmTokenEvent.snapshot.ref.set(fcmTokens);
                      }
                      // Decrease participantCount by 1
                      final countEvent = await kDatabase
                          .child("groupchats")
                          .child(widget.groupChat.key!)
                          .child("participantCount")
                          .once();

                      if (countEvent.snapshot.value != null) {
                        int currentCount =
                            int.parse(countEvent.snapshot.value.toString());
                        countEvent.snapshot.ref.set(currentCount - 1);
                      }

                      // Optional: Refresh group chats data (if necessary in your application)
                      groupChatsState.getDataFromDatabase();

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Colors.blue,
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "You left group successfully",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )));

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (ctx) => HomePage()),
                          (route) => false);
                    }
                  }
                },
                itemBuilder: (BuildContext context) {
                  List<PopupMenuEntry<String>> menuItems = [];

                  // Helper function to determine if the item is the last one
                  bool isLastItem(int index, int totalItems) {
                    return index == totalItems - 1;
                  }

                  // Helper function to get border for each item
                  BoxDecoration getItemDecoration(int index, int totalItems) {
                    if (isLastItem(index, totalItems)) {
                      return BoxDecoration();
                    }
                    return BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    );
                  }

                  // Add "Share Qr code" option for all users
                  menuItems.add(PopupMenuItem<String>(
                    value: '0',
                    child: InkWell(
                      onTap: () {}, // Empty onTap to make InkWell work
                      child: Container(
                        decoration: getItemDecoration(0, 4),
                        child: const Text('Share QR Code'),
                      ),
                    ),
                  ));

                  // Add "Remove User" and "Delete Group" options only for the creator
                  if (authState.userId == widget.groupChat.creatorId) {
                    menuItems.add(PopupMenuItem<String>(
                      value: '1',
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: getItemDecoration(1, 4),
                          child: const Text('Remove User'),
                        ),
                      ),
                    ));
                    menuItems.add(PopupMenuItem<String>(
                      value: '2',
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: getItemDecoration(2, 4),
                          child: const Text('Delete Group'),
                        ),
                      ),
                    ));
                  }

                  // Add "Leave Group" option for all users
                  menuItems.add(PopupMenuItem<String>(
                    value: '3',
                    child: InkWell(
                      onTap: () {},
                      child: const Text('Leave Group'),
                    ),
                  ));

                  return menuItems;
                },
                child: const IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: null, // null onPressed to disable the IconButton
                ),
              ),
            )
          ],
        ),
        bottom: _isScrolledDown && tab != 1 || _isGrid
            ? null
            : TabBar(
                onTap: (index) {
                  setState(() {
                    tab = index;
                  });
                  HapticFeedback.mediumImpact();
                },
                controller: _tabController,
                isScrollable: false,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[800],
                indicatorColor: Colors.transparent,
                indicatorWeight: 1,
                tabs: [
                  FadeInUp(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Tab(
                        child: Text(
                          widget.groupChat.groupName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FadeInUp(
                    child: const Padding(
                      padding: EdgeInsets.only(right: 0),
                      child: Tab(
                        child: Text(
                          'Who\'s Who',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        elevation: 0,
        title: Image.asset(
          "assets/logo/logo.png",
          height: 40,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: FadeIn(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 500),
          child: _isGrid
              ? TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    // Tab 1: Group Chat Posts

                    if (groupChatsState.groupChats != null)
                      for (var groupChat in groupChatsState.groupChats!)
                        Consumer<PostState>(
                          builder: (context, state, child) {
                            final String currentGroupChatId =
                                widget.groupChat.key!;
                            print(
                                "Current Group Chat ID: ${widget.groupChat.key!}");

                            final List<PostModel>? allPosts =
                                postState.getPostLists(
                                    authState.userModel, widget.groupChat.key);

                            // Filter posts by current group chat ID
                            final List<PostModel>? filteredPosts = allPosts
                                ?.where((post) =>
                                    post.groupChat?.key == currentGroupChatId)
                                .toList();

                            // Debugging
                            print("Debug: allPosts is $allPosts");
                            print(
                                "Debug: allPosts is null: ${allPosts == null}");
                            print(
                                "Debug: allPosts is empty: ${allPosts?.isEmpty ?? false}");
                            print("Debug: filteredPosts is $filteredPosts");

                            return filteredPosts == null ||
                                    filteredPosts.isEmpty
                                ? empty(filteredPosts)
                                : RefreshIndicator(
                                    color: Colors.transparent,
                                    backgroundColor: Colors.transparent,
                                    onRefresh: () {
                                      HapticFeedback.mediumImpact();
                                      return _bodyView();
                                    },
                                    child: AnimatedOpacity(
                                      opacity: _isGrid ? 1 : 0,
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 0.8,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                          ),
                                          controller: _scrollController,
                                          itemCount: filteredPosts?.length,
                                          itemBuilder: (context, index) {
                                            return GridPostWidget(
                                              postModel: filteredPosts![index],
                                            );
                                          },
                                          physics:
                                              AlwaysScrollableScrollPhysics(), // <-- This will make it always scrollable
                                        ),
                                      ),
                                    ),
                                  );
                          },
                        ),

                    if (groupChatsState.groupChats == null)
                      const Center(
                        child: Text(
                            'Loading...'), // Placeholder or any other widget
                      ),
                  ],
                )
              : TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    // Tab 2: Group User posts
                    Consumer<PostState>(
                      builder: (context, state, child) {
                        final List<PostModel>? list = postState.getPostLists(
                            authState.userModel, widget.groupChat.key);

                        return RefreshIndicator(
                          color: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          onRefresh: () {
                            HapticFeedback.mediumImpact();
                            return _bodyView();
                          },
                          child: AnimatedOpacity(
                            opacity: !_isGrid ? 1 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: list?.length ?? 0,
                              itemBuilder: (context, index) {
                                return FeedPostWidget(
                                  postModel: list![index],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 1.1,
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              state.userlist == null
                                  ? Container()
                                  : StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection("friendship")
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection("friends")
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        return snapshot.data == null
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                color: Colors.black,
                                              ))
                                            : SizedBox(
                                                height: 300,
                                                child: ListView.builder(
                                                  physics:
                                                      const ScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    bool isadded = false;
                                                    List ids = [];
                                                    List docs =
                                                        snapshot.data!.docs;
                                                    for (DocumentSnapshot doc
                                                        in docs) {
                                                      ids.add(doc["userId"]);
                                                    }
                                                    isadded = ids.contains(state
                                                        .userlist![index]
                                                        .userId);

                                                    // Skip rendering if the user is the current user
                                                    if (state.userlist![index]
                                                            .userId ==
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid) {
                                                      return Container();
                                                    }

                                                    return widget.groupChat
                                                            .participantIds
                                                            .contains(state
                                                                .userlist![
                                                                    index]
                                                                .userId)
                                                        ? SizedBox(
                                                            height: 60,
                                                            child: UserTilePage(
                                                              user: state
                                                                      .userlist![
                                                                  index],
                                                              isadded: isadded,
                                                            ),
                                                          )
                                                        : Container();
                                                  },
                                                  itemCount:
                                                      state.userlist!.length,
                                                ),
                                              );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
