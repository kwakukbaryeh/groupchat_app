import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/widgets/chat_appbar.dart';
import 'package:groupchat_firebase/widgets/chat_bottombar.dart';
import 'package:groupchat_firebase/widgets/chat_messages.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  UserModel sender;
  UserModel receiver;
  ChatScreen({
    super.key,
    required this.sender,
    required this.receiver,
  });
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String chatRoomId = "";
  getChatRoomIdByUsernames(String a, String b) {
    List<String> usernames = [a, b];
    usernames.sort(); // Sorts the usernames alphabetically
    return "${usernames[0]}_${usernames[1]}";
  }

  void getChatRoomId() {
    chatRoomId = getChatRoomIdByUsernames(
        widget.receiver.userName!, widget.sender.userName!);
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    getChatRoomId();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width / 100;
    final h = MediaQuery.of(context).size.height / 100;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: h * 13.7),
              Expanded(
                  child: ChatMessages(
                sender: widget.sender,
                receiver: widget.receiver,
                chatRoomId: chatRoomId,
              ))
            ],
          ),
          ChatAppBar(
            icon: Icons.arrow_back,
            receiver: widget.receiver,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ChatBottomBar(
                sender: widget.sender,
                receiver: widget.receiver,
                chatRoomId: chatRoomId),
          ),
        ],
      ),
    );
  }
}
