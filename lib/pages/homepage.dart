import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../helper/helper_function.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:quiver/async.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/user.dart';
import 'group_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class GroupChat extends StatefulWidget {
  final String groupName;
  final Duration timeRemaining;
  final int participantCount;

  const GroupChat({
    required this.groupName,
    required this.timeRemaining,
    required this.participantCount,
  });

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  late CountdownTimer _countdownTimer;
  late String _timeRemaining;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    final twelveHours = Duration(hours: 12);
    final oneSecond = Duration(seconds: 1);
    _countdownTimer = CountdownTimer(twelveHours, oneSecond);
    _countdownTimer.listen((timer) {
      setState(() {
        _timeRemaining = HelperFunctions.formatTimeRemaining(timer.remaining);
      });
    });
    setState(() {
      _timeRemaining = HelperFunctions.formatTimeRemaining(twelveHours);
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTimeRemaining =
        HelperFunctions.formatTimeRemaining(widget.timeRemaining);

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
  final _birthdateController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  MobileScannerController _scannerController = MobileScannerController();

  UserModel _user = UserModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _loadUserData();
      var groupChat = await HelperFunctions.getGroupChat();
      if (groupChat != null) {
        bool groupChatExists = _groupChats.any(
            (chat) => chat.groupName.toLowerCase() == 'placeholder groupchat');
        if (!groupChatExists) {
          _groupChats.add(GroupChat(
            groupName: groupChat['groupName'],
            timeRemaining: Duration(milliseconds: groupChat['timeRemaining']),
            participantCount: groupChat['participantCount'],
          ));
        }
      }
      _showDetailsDialog();
    });
  }

  Future<void> _loadUserData() async {
    _user = await HelperFunctions.getUser() ?? UserModel();
    setState(() {
      _birthdateController.text = _user.birthdate ?? '';
      _nameController.text = _user.name ?? '';
      _usernameController.text = _user.username ?? '';
    });
  }

  @override
  void dispose() {
    _birthdateController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _showDetailsDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please provide your details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: _birthdateController,
                  decoration: const InputDecoration(hintText: 'Birthdate'),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(hintText: 'Username'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                _user = _user.copyWith(
                  birthdate: _birthdateController.text,
                  name: _nameController.text,
                  username: _usernameController.text,
                );
                await HelperFunctions.saveUser(_user);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewGroupChat() {
    setState(() {
      var newGroupChat = GroupChat(
        groupName: 'placeholder groupchat',
        timeRemaining: Duration(hours: 12),
        participantCount: 1,
      );
      _groupChats.add(newGroupChat);
      HelperFunctions.saveGroupChat(
          newGroupChat.groupName, newGroupChat.timeRemaining.inMilliseconds);
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
                          final Map<String, dynamic>? result =
                              await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return FractionallySizedBox(
                                heightFactor: 0.9,
                                child: MobileScanner(
                                  // fit: BoxFit.contain,
                                  onDetect: (capture) {
                                    Navigator.of(context).pop(capture);
                                  },
                                ),
                              );
                            },
                          );

                          if (result != null) {
                            final List<Barcode> barcodes = result['barcodes'];
                            final Uint8List? image = result['image'];
                            for (final barcode in barcodes) {
                              debugPrint('Barcode found! ${barcode.rawValue}');
                            }
                            if (image != null) {
                              showDialog(
                                context: context,
                                builder: (context) => Image.memory(image),
                              );
                              Future.delayed(const Duration(seconds: 5), () {
                                Navigator.pop(context);
                              });
                            }

                            final String groupName = result['groupChatName'];
                            const Duration timeRemaining = Duration(hours: 12);
                            const int participantCount = 1;

                            _navigateToGroupChat(
                                groupName, timeRemaining, participantCount);
                          }
                        },
                        child: const Text('Scan'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          const String groupName = 'New GroupChat';
                          final Duration timeRemaining = Duration(hours: 12);
                          const int participantCount = 1;

                          _navigateToGroupChat(
                            groupName,
                            timeRemaining,
                            participantCount,
                          );
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

  void _navigateToGroupChat(
      String groupName, Duration timeRemaining, int participantCount) {
    setState(() {
      var newGroupChat = GroupChat(
        groupName: groupName,
        timeRemaining: timeRemaining,
        participantCount: participantCount,
      );
      _groupChats.add(newGroupChat);
      HelperFunctions.saveGroupChat(
          newGroupChat.groupName, newGroupChat.timeRemaining.inMilliseconds);
    });

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GroupScreen(groupName: groupName)),
    );
  }
}
