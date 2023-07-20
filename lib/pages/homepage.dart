import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:groupchat_firebase/pages/feed.dart';
import 'package:groupchat_firebase/pages/myprofile.dart';
import 'package:provider/provider.dart';
import 'package:groupchat_firebase/models/groupchat.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/state/groupchatState.dart';
import 'package:groupchat_firebase/state/search_state.dart';
import 'group_screen.dart';
import 'dart:core';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  bool _isScrolledDown = false;
  TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
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
    _groupNameController.dispose();
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
    print('User model: ${authState.userModel}');
    if (authState.userModel != null) {
      groupChatState.setUserModel(authState.userModel!, context);
    }
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
              ],
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[700],
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
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey[700], // Set background color
                        ),
                        onPressed: () async {
                          var groupName = _groupNameController.text;
                          if (groupName.isNotEmpty) {
                            var groupChatState = Provider.of<GroupChatState>(
                              context,
                              listen: false,
                            );
                            var groupChat = GroupChat(
                              groupName: groupName,
                              participantCount: 1,
                              createdAt: DateTime.now(),
                              expiryDate:
                                  DateTime.now().add(const Duration(hours: 12)),
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
                      SizedBox(height: 16),
                      Container(
                        child: QrImageView(
                          data:
                              'placeholder', // Use the group chat key as the QR code data
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MobileScanner(
                                onDetect: (capture) {
                                  final List<Barcode> barcodes =
                                      capture.barcodes;
                                  final Uint8List? image = capture.image;

                                  for (final barcode in barcodes) {
                                    String scannedData = barcode.rawValue
                                        as String; // Extract the raw value as a string

                                    // Use the scannedData variable as needed
                                    // For example, you can pass it to a function or navigate to a new page:
                                    navigateToGroupChatPage(
                                        context, scannedData);

                                    debugPrint('Barcode found! $scannedData');
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        child: Text('Scan'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
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
        groupChat.updateRemainingTime(); // Update remaining time

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
                  if (groupChat.remainingTime !=
                      null) // Access remainingTime from groupChat object
                    Text(
                      'Time remaining: ${formatTimeRemaining(groupChat.remainingTime!)}', // Access remainingTime from groupChat object
                      style: TextStyle(color: Colors.black),
                    )
                  else
                    Text(
                      'Expired',
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

  void navigateToGroupChatPage(BuildContext context, String groupChatKey) {
    String groupName = "Placeholder's Groupchat";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupScreen(
          groupChat: GroupChat(
            key: groupChatKey,
            createdAt: DateTime.now(),
            groupName: groupName,
            participantCount: 2,
          ),
        ),
      ),
    );
  }

  String formatTimeRemaining(Duration remainingTime) {
    String formattedTime = remainingTime.toString().split('.').first;
    return formattedTime;
  }
}
