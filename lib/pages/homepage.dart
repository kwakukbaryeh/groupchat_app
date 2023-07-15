import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/state/post_state.dart';
import 'package:groupchat_firebase/state/search_state.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quiver/async.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/user.dart';
import 'group_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;
  late TabController _tabController;
  bool _isScrolledDown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initPosts();
      initSearch();
      initProfile();
      getGroupChatDataFromDatabase();
    });
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 3, vsync: this);
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
    var authState = Provider.of<AuthState>(context, listen: false);
    authState.databaseInit();
  }

  void initPosts() {
    var postState = Provider.of<PostState>(context, listen: false);
    postState.databaseInit();
    postState.getDataFromDatabase();
  }

  void getGroupChatDataFromDatabase() {
    var groupChatState = Provider.of<GroupChatState>(context, listen: false);
    groupChatState.getDataFromDatabase();
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
    String formattedTimeRemaining = formatTimeRemaining(widget.timeRemaining);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupScreen(groupName: widget.groupName),
          ),
        );
      },
      child: Container(
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
                widget.groupName,
                style: TextStyle(color: Colors.black, fontSize: 16),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 8),
              Text(
                'Time remaining: $formattedTimeRemaining',
                style: TextStyle(color: Colors.black),
              ),
              Text(
                '${widget.participantCount} active',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  List<GroupChat> _groupChats = []; // maintain a list of group chats
  MobileScannerController _scannerController = MobileScannerController();
  UserModel _user = UserModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _loadUserData();
      // Fetch group chats from Firebase Realtime Database
      // and add them to the _groupChats list
      // Example code: _fetchGroupChatsFromDatabase();
    });
  }

  Future<void> _loadUserData() async {
    _user = await HelperFunctions.getUser() ?? UserModel();
    setState(() {
      // Update UI if needed with user data
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _addNewGroupChat() {
    setState(() {
      var newGroupChat = GroupChat(
        groupName: 'placeholder groupchat',
        timeRemaining: Duration(hours: 12),
        participantCount: 1,
      );
      _groupChats.add(newGroupChat);
      // Save new group chat to Firebase Realtime Database
      // Example code: _saveGroupChatToDatabase(newGroupChat);
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupScreen(groupName: 'placeholder groupchat'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App title'),
        leading: IconButton(
          icon: Icon(Icons.message),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: _groupChats.isEmpty
          ? const Center(
              child: Text(
                'Wow it\'s really empty in here.... Start a group chat!',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: _groupChats.length,
              itemBuilder: (BuildContext context, int index) {
                final groupChat = _groupChats[index];
                final totalHeight = MediaQuery.of(context).size.height;
                final groupChatHeight = totalHeight / _groupChats.length;

                return Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: groupChatHeight,
                    width: MediaQuery.of(context).size.width,
                    child: groupChat,
                  ),
                );
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
                        decoration: const InputDecoration(
                          hintText: 'Enter groupchat name',
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            height: 200,
                            width: 200,
                            color: Colors.grey,
                            child: Center(
                              child: QrImageView(
                                data: '123456789',
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Create new group chat with entered name and 12-hour duration
                          // Save the new group chat to Firebase Realtime Database
                          // Example code: _createAndSaveGroupChat();
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
}
