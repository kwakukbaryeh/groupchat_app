import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:groupchat_firebase/pages/feed.dart';
import 'package:groupchat_firebase/pages/myprofile.dart';
import 'package:provider/provider.dart';
import 'package:groupchat_firebase/models/groupchat.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/state/groupchatState.dart';
import 'package:groupchat_firebase/state/post_state.dart';
import 'package:groupchat_firebase/state/search_state.dart';
import 'group_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  bool _isScrolledDown = false;
  TextEditingController _groupNameController =
      TextEditingController(); // Add this line

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initPosts();
      initSearch();
      initProfile();
      getGroupChatDataFromDatabase();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabController.dispose();
    _groupNameController.dispose(); // Add this line
    super.dispose();
  }

  void initSearch() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      var searchState = Provider.of<SearchState>(context, listen: false);
      searchState.getDataFromDatabase();
    });
  }

  void initProfile() {
    var authState = Provider.of<AuthState>(context, listen: false);
    authState.databaseInit();
    var groupChatState = Provider.of<GroupChatState>(context, listen: false);

    // Check if authState.userModel is not null
    if (authState.userModel != null) {
      groupChatState.setUserModel(authState.userModel!, context);
    }
  }

  void initPosts() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      var postState = Provider.of<PostState>(context, listen: false);
      postState.databaseInit();
      postState.getDataFromDatabase();
    });
  }

  void getGroupChatDataFromDatabase() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      var groupChatState = Provider.of<GroupChatState>(context, listen: false);
      groupChatState.getDataFromDatabase();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App title'),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FeedPage(),
              ),
            );
          },
          child: Transform(
            transform: Matrix4.identity()..scale(-1.0, 1.0, -1.0),
            alignment: Alignment.center,
            child: const Icon(
              Icons.people,
              size: 30,
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<GroupChatState>(
        builder: (context, groupChatState, _) {
          if (groupChatState.isBusy) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (groupChatState.groupChats == null) {
            return Center(
              child: Text('Wow it\'s empty here... Add some groups!'),
            );
          } else {
            final groupChats = groupChatState.groupChats!;
            return ListView(
              children: [
                SizedBox(height: 16.0),
                _buildGroupChatButtons(groupChats),
                SizedBox(height: 16.0),
                _buildCreateJoinButton(),
              ],
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return FractionallySizedBox(
                heightFactor: 0.9,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _groupNameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter group chat name',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          var groupName = _groupNameController.text;
                          if (groupName.isNotEmpty) {
                            var groupChatState = Provider.of<GroupChatState>(
                              context,
                              listen: false,
                            );
                            var groupChat = GroupChat(
                              groupName: groupName,
                              timeRemaining: Duration(hours: 12),
                              participantCount: 1,
                              createdAt: DateTime.now(),
                            );
                            await groupChatState
                                .saveGroupChatToDatabase(groupChat);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GroupScreen(groupChat: groupChat),
                              ),
                            );
                          }
                        },
                        child: const Text('Create GroupChat Now'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        label: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Create'),
            Text('or'),
            Text('Join'),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupChatButtons(List<GroupChat>? groupChats) {
    if (groupChats == null || groupChats.isEmpty) {
      return Center(
        child: Text('Wow it\'s empty here... Add some groups!'),
      );
    }

    final double buttonHeight =
        MediaQuery.of(context).size.height / groupChats.length;

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: groupChats.length,
      itemBuilder: (BuildContext context, int index) {
        final groupChat = groupChats[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupScreen(groupChat: groupChat),
              ),
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: buttonHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    groupChat.groupName,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Time remaining: ${formatTimeRemaining(groupChat.timeRemaining)}',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    '${groupChat.participantCount} active',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateJoinButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return FractionallySizedBox(
                heightFactor: 0.9,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _groupNameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter group chat name',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          var groupName = _groupNameController.text;
                          if (groupName.isNotEmpty) {
                            var groupChatState = Provider.of<GroupChatState>(
                              context,
                              listen: false,
                            );
                            var groupChat = GroupChat(
                              groupName: groupName,
                              timeRemaining: Duration(hours: 12),
                              participantCount: 1,
                              createdAt: DateTime.now(),
                            );
                            await groupChatState
                                .saveGroupChatToDatabase(groupChat);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GroupScreen(groupChat: groupChat),
                              ),
                            );
                          }
                        },
                        child: const Text('Create GroupChat Now'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Text('Create or Join'),
      ),
    );
  }

  String formatTimeRemaining(Duration timeRemaining) {
    // Format the duration as needed
    return '';
  }
}
