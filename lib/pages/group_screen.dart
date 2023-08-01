import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:groupchat_firebase/camera/camera.dart';
import 'package:groupchat_firebase/models/groupchat.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/pages/homepage.dart';
import 'package:groupchat_firebase/pages/myprofile.dart';
import 'package:groupchat_firebase/services/user_tile_page.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/state/post_state.dart';
import 'package:groupchat_firebase/state/search_state.dart';
import 'package:groupchat_firebase/widgets/custom/rippleButton.dart';
import 'package:groupchat_firebase/widgets/feedpost.dart';
import 'package:groupchat_firebase/widgets/gridpost.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatefulWidget {
  final String userId; // Add this property to store the user ID
  final List<GroupChat>?
      groupChats; // Add this property to store the list of group chats

  const GroupScreen({Key? key, required this.userId, required this.groupChats})
      : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ScrollController _scrollController = ScrollController();
  bool _isScrolledDown = false;
  bool _isGrid = false;
  List<PostModel>? list;

  @override
  void initState() {
    var authState = Provider.of<AuthState>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authState.getCurrentUser();
      initPosts();
      initSearch();
      initProfile();
    });
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void initSearch() {
    var searchState = Provider.of<SearchState>(context, listen: false);
    searchState.getDataFromDatabase();
  }

  void initProfile() {
    var state = Provider.of<AuthState>(context, listen: false);
    state.databaseInit();
  }

  void initPosts() {
    var state = Provider.of<PostState>(context, listen: false);

    if (widget.groupChats != null) {
      state.databaseInit(widget.groupChats!);

      for (var groupChat in widget.groupChats!) {
        state.getDataFromDatabaseForGroupChat(groupChat.key!);
      }
    }
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
    print("List: $list");
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
                  builder: (context) => CameraPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary:
                  Colors.grey[700], // Set the background color to grey[700]
            ),
            child: const Text("Take your BeReal"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    final state = Provider.of<SearchState>(context);

    print("Building GroupScreen...");

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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraPage(),
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
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back,
            size: 30,
          ),
        ),
        toolbarHeight: 37,
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 59),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyProfilePage(),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    height: 30,
                    width: 30,
                    child: CachedNetworkImage(
                      imageUrl: authState.profileUserModel?.profilePic
                              ?.toString() ??
                          "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg",
                    ),
                  ),
                ),
              ),
            ),
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
                          'My Friends',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FadeInUp(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 0),
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
          height: 100,
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
                    if (widget.groupChats != null)
                      for (var groupChat in widget.groupChats!)
                        Consumer<PostState>(
                          builder: (context, state, child) {
                            final String groupChatId = groupChat.key!;
                            final List<PostModel>? groupList =
                                state.groupChatPostMap[groupChatId];

                            // Add any additional logic here, if needed
                            print("Debug: groupList is ${groupList}");
                            print(
                                "Debug: groupList is null: ${groupList == null}");
                            print(
                                "Debug: groupList is empty: ${groupList?.isEmpty ?? false}");

                            return groupList == null || groupList.isEmpty
                                ? empty(groupList)
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
                                          itemCount: groupList.length,
                                          itemBuilder: (context, index) {
                                            return GridPostWidget(
                                              postModel: groupList[index],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                          },
                        ),
                    if (widget.groupChats == null)
                      Center(
                        child: Text(
                            'Loading...'), // Placeholder or any other widget
                      ),
                  ],
                )
              : TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    // Tab 2: All User's Posts (Assuming you need to show all user posts here)
                    Consumer<PostState>(
                      builder: (context, state, child) {
                        final List<PostModel>? list =
                            state.getPostLists(authState.userModel);

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
                          height: 140,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.1,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  left: 10,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    height: 25,
                                    width: 40,
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "NEW",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 10,
                                ),
                                child: const Text(
                                  "DISCOVER YOUR\nFRIENDS OF FRIENDS",
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                height: 300,
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      height: 60,
                                      child: UserTilePage(
                                        user: state.userlist![index],
                                        isadded: true,
                                      ),
                                    );
                                  },
                                  itemCount: 2,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  bottom: 20,
                                  right: 15,
                                ),
                                child: RippleButton(
                                  splashColor: Colors.transparent,
                                  child: Container(
                                    height: 55,
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Share your BeReal",
                                        style: TextStyle(
                                          fontFamily: "icons.ttf",
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {},
                                ),
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
