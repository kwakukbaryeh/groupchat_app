import 'dart:core';
import 'dart:math';
import 'dart:typed_data';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:groupchat_firebase/models/groupchat.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/pages/direct_message.dart';
import 'package:groupchat_firebase/pages/myprofile.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/state/groupchatState.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'group_screen.dart';

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
    _tabController = TabController(length: 1, vsync: this);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Fetch initial data from the database when the widget is built
      Provider.of<GroupChatState>(context, listen: false).getDataFromDatabase();

      Provider.of<GroupChatState>(context, listen: false).startTimer();
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

  /*String? generateGroupChatKey() {
    var uuid = Uuid();
    return uuid.v4(); // Generate a version 4 (random) UUID
  }*/

  @override
  Widget build(BuildContext context) {
    AuthState auth = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
      backgroundColor: Color(0x000000),
      appBar: AppBar(
        elevation: 0.0,
        title: Text('keepUp'),
        backgroundColor: Color(0x000000),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DirectMessages(user: auth.userModel!),
              ),
            );
          },
          child: Transform.rotate(
            angle: 3 * pi / 4,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(-1.0, 1.0, -1.0),
              child: Icon(
                Icons.send,
                size: 30,
              ),
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.transparent,
          indicatorWeight: 1,
          tabs: [
            FadeInUp(
              child: Padding(
                padding: const EdgeInsets.all(0), // Adjusted padding
                child: Center(
                  // Centered the text
                  child: Tab(
                    child: Text(
                      'Groups',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            /*
            FadeInUp(
              child: Padding(
                padding: const EdgeInsets.only(right: 0),
                child: Tab(
                  child: Text(
                    'Discovery',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ), */
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // "Groups" Tab
                Consumer<GroupChatState>(
                  builder: (context, groupChatState, _) {
                    if (groupChatState.isBusy) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (groupChatState.groupChats == null ||
                        groupChatState.groupChats!.isEmpty) {
                      return Center(
                        child: Text(
                          'Wow it\'s empty here... Add some groups!',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      final allGroupChats = groupChatState.groupChats!;
                      // Filter the group chats to only include those that the user is a part of
                      final groupChats = allGroupChats
                          .where((groupChat) =>
                              groupChat.participantIds.contains(auth.userId))
                          .toList();
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

                /*
                // "Discovery" Tab
                Center(
                  child: Text(
                    'Coming soon...',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                */
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            right: 20.0), // Add 20 pixels of space to the right
        child: Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
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
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              // Center the QR code and set its size to 250x250
                              Center(
                                child: Consumer<GroupChatState>(
                                    builder: (context, groupChatState, _) {
                                  if (groupChatState.isBusy) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (groupChatState.groupChats ==
                                      null) {
                                    //print("${auth.userId} ${auth.userModel!.fcmToken}");
                                    return Center(
                                      child: SizedBox(
                                        width: 250,
                                        height: 250,
                                        child: QrImageView(
                                          data:
                                              "${auth.userId} ${auth.userModel!.fcmToken}",
                                          version: QrVersions.auto,
                                        ),
                                      ),
                                    );
                                  } else {
                                    final groupChats =
                                        groupChatState.groupChats!;
                                    String data =
                                        "${auth.userId} ${auth.userModel!.fcmToken}";
                                    for (GroupChat groupChat in groupChats) {
                                      if (groupChat.creatorId == auth.userId) {
                                        data =
                                            "${auth.userId} ${auth.userModel!.fcmToken} ${groupChat.key}";
                                      }
                                    }
                                    //print(data);
                                    return SizedBox(
                                      width: 300,
                                      height: 300,
                                      child: QrImageView(
                                        data: data,
                                        version: QrVersions.auto,
                                      ),
                                    );
                                  }
                                }),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 40,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MobileScanner(
                                        controller: MobileScannerController(
                                          detectionSpeed:
                                              DetectionSpeed.noDuplicates,
                                        ),
                                        onDetect: (capture) {
                                          final List<Barcode> barcodes =
                                              capture.barcodes;
                                          final Uint8List? image =
                                              capture.image;

                                          for (final barcode in barcodes) {
                                            String scannedData =
                                                barcode.rawValue as String;
                                            // Use the scannedData variable to navigate to the GroupScreen
                                            navigateToGroupChatPage(
                                                context, scannedData);

                                            debugPrint(
                                                'Barcode found! $scannedData');
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.grey[700],
                                ),
                                child: Text('Scan'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child:
                Icon(Icons.group), // This should be inside FloatingActionButton
          ),
        ),
      ),
    );
  }

  Widget _buildGroupChatButtons(List<GroupChat>? groupChats) {
    if (groupChats == null || groupChats.isEmpty) {
      return Center(
        child: Text(
          'Wow it\'s empty here... Add some groups!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

    final double appBarHeight = kToolbarHeight;
    final double availableHeight =
        MediaQuery.of(context).size.height - (appBarHeight + 154.0);
    final double buttonHeight = availableHeight / groupChats.length;

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: groupChats.length,
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 10.0);
      },
      itemBuilder: (BuildContext context, int index) {
        final groupChat = groupChats.reversed.toList()[index];
        groupChat.updateRemainingTime();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupScreen(
                  groupChat: groupChat,
                ),
              ),
            );
          },
          child: Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: MediaQuery.of(context).size.width - 36.0,
              height: buttonHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: (groupChat.imageBackPath != null
                          ? NetworkImage(groupChat.imageBackPath!)
                          : AssetImage('assets/images/button_background.png'))
                      as ImageProvider<Object>,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      groupChat.groupName,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 8),
                    if (groupChat.remainingTime != null)
                      Text(
                        '${formatTimeRemaining(groupChat.remainingTime!)}',
                        style: TextStyle(color: Colors.white),
                      )
                    else
                      Text(
                        'Expired',
                        style: TextStyle(color: Colors.white),
                      ),
                    Text(
                      '${groupChat.participantCount} active',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> navigateToGroupChatPage(
      BuildContext context, String data) async {
    final groupChatState = Provider.of<GroupChatState>(context, listen: false);
    AuthState auth = Provider.of<AuthState>(context, listen: false);
    String groupChatKey = data.split(" ")[data.split(" ").length - 1];
    //print(groupChatKey);
    // Case 1: Group chat exists for the scanned groupChatKey
    final existingGroupChat = groupChatState.getGroupChatByKey(groupChatKey);
    if (existingGroupChat != null) {
      List<String> participantIds = existingGroupChat.participantIds;
      List<String> participantFcmTokens =
          existingGroupChat.participantFcmTokens;
      participantIds.add(auth.userId);
      participantFcmTokens.add(auth.userModel!.fcmToken!);
      existingGroupChat.participantIds = participantIds;
      existingGroupChat.participantFcmTokens = participantFcmTokens;
      await groupChatState.updateGroutChatParticipant(existingGroupChat);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupScreen(
            groupChat: existingGroupChat,
          ),
        ),
      );
    } else {
      // Case 2: Group chat does not exist for the scanned groupChatKey
      // Create a new group chat
      UserModel? userModel = await auth.getUserDetail(data.split(" ")[0]);
      if (userModel != null) {
        String groupName =
            "${userModel.displayName?.split(" ")[0]}'s GroupChat";

        // You can set the participant count and other properties based on your requirements
        var newGroupChat = GroupChat(
          creatorId: data.split(" ")[0],
          groupName: groupName,
          participantIds: [data.split(" ")[0], auth.userId],
          participantFcmTokens: [data.split(" ")[1], auth.userModel!.fcmToken!],
          participantCount: 2,
          createdAt: DateTime.now(),
          // Set an expiry date if needed
          expiryDate: DateTime.now().add(const Duration(hours: 12)),
        );

        // Save the new group chat to the database
        await groupChatState.saveGroupChatToDatabase(
          newGroupChat,
          (groupKey) {
            newGroupChat.key = groupKey;
          },
        );

        // Navigate to the new group chat passing the required parameters
        //print(newGroupChat);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupScreen(
              groupChat: newGroupChat,
            ),
          ),
        );
      }
    }
  }

  String formatTimeRemaining(Duration remainingTime) {
    String formattedTime = remainingTime.toString().split('.').first;
    return formattedTime;
  }
}
