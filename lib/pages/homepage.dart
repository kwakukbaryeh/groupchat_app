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
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  bool _isScrolledDown = false;
  TextEditingController _groupNameController = TextEditingController();
  late DatabaseReference _groupChatRef;
  bool hasAddedGroupChat = false;
  String? _qrCodeData;
  bool _isFetchingQR = false;

  @override
  void initState() {
    super.initState();
    handleDynamicLinks();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 1, vsync: this);
    _groupChatRef = FirebaseDatabase.instance.reference().child('groupchats');

    // Print the value of _groupChatRef
    print("_groupChatRef: $_groupChatRef");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch initial data from the database when the widget is built
      Provider.of<GroupChatState>(context, listen: false).getDataFromDatabase();

      Provider.of<GroupChatState>(context, listen: false).startTimer();
    });

    // Set up a listener for changes to the group chats
    _groupChatRef.onChildChanged.listen((event) {
      // Handle changes to group chats here
      // You can call fetchUpdatedData to refresh the data
      print("onChildChanged: $event");
      fetchUpdatedData();
    });

    _groupChatRef.onChildAdded.listen((event) {
      if (hasAddedGroupChat) {
        hasAddedGroupChat = false; // Reset the flag for future operations
        return; // Skip this trigger since we just added the group chat
      }
      print("onChildAdded: $event");
      fetchUpdatedData();
    });

    AuthState authState = Provider.of<AuthState>(context, listen: false);
    authState.checkUserExistence(context);
  }

  // Function to fetch updated data
  void fetchUpdatedData() async {
    try {
      final groupChatState =
          Provider.of<GroupChatState>(context, listen: false);
      groupChatState.getDataFromDatabase(); // Fetch updated data
      setState(() {}); // Trigger a rebuild of the UI
    } catch (e) {
      print('Error fetching updated data: $e');
    }
  }

  Future<void> fetchQrCodeData() async {
    AuthState auth = Provider.of<AuthState>(context, listen: false);
    GroupChatState groupChatState =
        Provider.of<GroupChatState>(context, listen: false);

    String data = "${auth.userId} ${auth.userModel!.fcmToken}";

    if (groupChatState.groupChats != null &&
        groupChatState.groupChats!.isNotEmpty) {
      final userGroupChats = groupChatState.groupChats!
          .where((groupChat) => groupChat.creatorId == auth.userId)
          .toList();

      // If there's a group chat created by the user
      if (userGroupChats.isNotEmpty) {
        final userGroupChatKey = userGroupChats
            .first.key; // Assuming one group per user, modify if needed
        data = "$data $userGroupChatKey"; // Append the group key to the data
      }
    }

    _qrCodeData = await createDynamicLink(data);
    setState(() {});
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

  Future<String> createDynamicLink(String data) async {
    print('Received data for Dynamic Link creation: $data');
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://groupchatfirebase.page.link',
      link: Uri.parse(
          'https://www.keepupapp.com/joinGroup?data=${Uri.encodeComponent(data)}'),
      androidParameters: const AndroidParameters(
        packageName: 'com.your.package.name',
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.your.bundle.id',
        minimumVersion: '1.0',
        appStoreId: 'your_app_store_id',
      ),
    );

    final ShortDynamicLink shortLink =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    print('Generated Short Link: ${shortLink.shortUrl}');
    print('Dynamic Link Data: ${Uri.encodeComponent(data)}');
    return shortLink.shortUrl.toString();
  }

  void handleDynamicLinks() async {
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink?.link != null) {
      handleLink(initialLink!.link);
    }

    FirebaseDynamicLinks.instance.onLink.listen(
      (PendingDynamicLinkData? dynamicLink) {
        if (dynamicLink?.link != null) {
          handleLink(dynamicLink!.link);
        }
      },
      onError: (error) {
        print('Error handling dynamic link: $error');
      },
    );
  }

  void handleLink(Uri link) {
    // Extract data from the link
    final data = link.queryParameters['data'];
    print('Received Data from Dynamic Link: $data');
    print('Full data: $data');

    if (data != null) {
      List<String> extractedData = data.split(" ");
      print('Extracted data: $extractedData');
      if (extractedData.length == 2) {
        // This means only userId and fcmToken are present
        // You may decide to create a new group chat or some other logic
        // You can use the navigateToGroupChatPage function for this purpose.
        navigateToGroupChatPage(context, data);
      } else if (extractedData.length == 3) {
        // This means userId, fcmToken and groupChatKey are present
        navigateToGroupChatPage(context, data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthState auth = Provider.of<AuthState>(context, listen: false);
    return Consumer<GroupChatState>(
      builder: (context, groupChatState, _) {
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
                              .where((groupChat) => groupChat.participantIds
                                  .contains(auth.userId))
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
                  ],
                ),
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(
                right: 20.0), // Add 20 pixels of space to the right
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                backgroundColor: Colors.grey[400],
                onPressed: () async {
                  if (_qrCodeData == null && !_isFetchingQR) {
                    _isFetchingQR = true;
                    await fetchQrCodeData();
                    _isFetchingQR = false;
                  }
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
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
                                  Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        SizedBox(height: 100),
                                        Center(
                                          child: Consumer<GroupChatState>(
                                            builder: (context, groupChatState,
                                                child) {
                                              fetchQrCodeData(); // Fetch the latest data every time the state changes
                                              return _qrCodeData != null
                                                  ? SizedBox(
                                                      width: 300,
                                                      height: 300,
                                                      child: QrImageView(
                                                        data: _qrCodeData!,
                                                        version:
                                                            QrVersions.auto,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                    )
                                                  : CircularProgressIndicator();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
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
                                              for (final barcode in barcodes) {
                                                String scannedData =
                                                    barcode.rawValue as String;

                                                if (scannedData.contains(
                                                    "https://groupchatfirebase.page.link")) {
                                                  // If the scanned data contains a Firebase Dynamic Link prefix, resolve it
                                                  FirebaseDynamicLinks.instance
                                                      .getDynamicLink(Uri.parse(
                                                          scannedData))
                                                      .then((dynamicLink) {
                                                    if (dynamicLink?.link !=
                                                        null) {
                                                      handleLink(
                                                          dynamicLink!.link);
                                                    }
                                                  });
                                                } else {
                                                  // Else, directly navigate using the scanned data
                                                  navigateToGroupChatPage(
                                                      context, scannedData);
                                                }
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
                child: Icon(
                    Icons.group), // This should be inside FloatingActionButton
              ),
            ),
          ),
        );
      },
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
                      style: TextStyle(color: Colors.white, fontSize: 16),
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

    // Check if the group chat with the scanned key exists
    final existingGroupChat = groupChatState.getGroupChatByKey(groupChatKey);

    if (existingGroupChat != null) {
      // If the group chat exists and the user is NOT already a participant
      if (!existingGroupChat.participantIds.contains(auth.userId)) {
        // Add the user as a participant
        existingGroupChat.participantIds.add(auth.userId);
        existingGroupChat.participantFcmTokens.add(auth.userModel!.fcmToken!);
        await groupChatState.updateGroutChatParticipant(existingGroupChat);
      }

      // Navigate to the existing group chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupScreen(
            groupChat: existingGroupChat,
          ),
        ),
      );
    } else {
      // If the group chat does not exist, create a new one
      UserModel? userModel = await auth.getUserDetail(data.split(" ")[0]);
      if (userModel != null) {
        String groupName =
            "${userModel.displayName?.split(" ")[0]}'s GroupChat";
        var newGroupChat = GroupChat(
          creatorId: data.split(" ")[0],
          groupName: groupName,
          participantIds: [data.split(" ")[0], auth.userId],
          participantFcmTokens: [data.split(" ")[1], auth.userModel!.fcmToken!],
          participantCount: 2,
          createdAt: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(hours: 12)),
        );

        hasAddedGroupChat = true;

        // Save the new group chat to the database
        await groupChatState.saveGroupChatToDatabase(
          newGroupChat,
          (groupKey) {
            newGroupChat.key = groupKey;
          },
        );

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
