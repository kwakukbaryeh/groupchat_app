import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/pages/chat_screen.dart';
import 'package:groupchat_firebase/pages/friends.dart';
import 'package:groupchat_firebase/services/database.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';

class DirectMessages extends StatefulWidget {
  UserModel user;
  DirectMessages({Key? key, required this.user}) : super(key: key);
  @override
  _DirectMessagesState createState() => _DirectMessagesState();
}

class _DirectMessagesState extends State<DirectMessages> {
  Stream<QuerySnapshot>? chatroomStream;

  getChatRooms() async {
    chatroomStream = await Database().getChatRooms(widget.user.userName!);
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    getChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width / 100;
    final h = MediaQuery.of(context).size.height / 100;
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Direct Message"),
          backgroundColor: Colors.black,
          actions: [
            InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (ctx) => const Friends()));
                },
                child: const Icon(Icons.person)),
            const SizedBox(
              width: 15,
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: chatroomStream,
            builder: (ctx, snapshot) {
              if (snapshot.hasData) {
                final docs = snapshot.data!.docs;
                if (docs.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: docs.length,
                    itemBuilder: (cxt, index) {
                      final ds = docs[index];
                      final data = ds.data() as Map<String, dynamic>?;

                      if (data != null &&
                          data.containsKey("expireAt") &&
                          !data["expireAt"].toDate().isAfter(DateTime.now())) {
                        ds.reference
                            .collection("chats")
                            .get()
                            .then((querysnap) {
                          querysnap.docs.forEach((element) {
                            element.reference.delete();
                          });
                        }).then((value) => ds.reference.delete());
                      }

                      if (data != null &&
                          data.containsKey("expireAt") &&
                          data["expireAt"].toDate().isAfter(DateTime.now())) {
                        return ChatRoomListTile(
                          lastMessage: data.containsKey("lastMessage")
                              ? data["lastMessage"]
                              : "",
                          type: data.containsKey('type') ? data['type'] : "",
                          read: data.containsKey('read') ? data['read'] : false,
                          chatId: ds.id,
                          sender:
                              data.containsKey("sender") ? data["sender"] : {},
                          receiver: data.containsKey("receiver")
                              ? data["receiver"]
                              : {},
                          dateString: data.containsKey("lastMessageSendTs")
                              ? data["lastMessageSendTs"]
                              : Timestamp
                                  .now(), // set to Timestamp.now() if it doesn't exist
                        );
                      } else {
                        return Container();
                      }
                    },
                  );
                } else {
                  return const Center(
                      child: Text(
                    "No direct messages yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ));
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              }
            }));
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, type, chatId;
  Timestamp dateString;
  Map<String, dynamic> sender;
  Map<String, dynamic> receiver;
  final bool read;
  ChatRoomListTile(
      {super.key,
      required this.lastMessage,
      required this.type,
      required this.sender,
      required this.receiver,
      required this.dateString,
      required this.chatId,
      required this.read});
  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String timesAgo = "";
  late UserModel sender;
  late UserModel receiver;
  late Timer _timer;

  String calcTimesAgo(DateTime dt) {
    Duration dur = DateTime.now().difference(dt);
    print(dur.inHours);
    if (dur.inSeconds < 60) {
      return dur.inSeconds == 1
          ? "${dur.inSeconds} sec ago"
          : "${dur.inSeconds} sec ago";
    }
    if (dur.inMinutes >= 1 && dur.inMinutes < 60) {
      return dur.inMinutes == 1
          ? "${dur.inMinutes} min ago"
          : "${dur.inMinutes} mins ago";
    }
    if (dur.inHours >= 1 && dur.inHours < 60) {
      return dur.inHours == 1
          ? "${dur.inHours} hour ago"
          : "${dur.inHours} hours ago";
    }
    if (dur.inHours > 60) {
      DateTime dateNow =
          DateTime.parse(DateTime.now().toString().substring(0, 10));
      DateTime dte = DateTime.parse(dt.toString().substring(0, 10));
      String date = dateNow.compareTo(dte) == 0
          ? "Today"
          : "${dte.year} ${dte.month} ${dte.day}" ==
                  "${dateNow.year} ${dateNow.month} ${(dateNow.day) - 1}"
              ? "Yesterday"
              : formatDate(dte, [M, ' ', dd, ', ', yyyy]);
      return date;
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    timesAgo = calcTimesAgo(widget.dateString
        .toDate()); // This should now correctly reflect the 'ts' field from Firestore
    sender = UserModel.fromJson(widget.sender);
    receiver = UserModel.fromJson(widget.receiver);

    // Initialize the Timer to update every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        timesAgo = calcTimesAgo(widget.dateString.toDate());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the Timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    UserModel currentUser =
        state.profileUserModel!; // Assuming this gives the current user

    // Determine who the other user is
    UserModel otherUser;
    if (sender.userName == currentUser.userName) {
      otherUser = receiver;
    } else {
      otherUser = sender;
    }

    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => ChatScreen(
                      sender: currentUser,
                      receiver: otherUser,
                    )));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8.0),
        child: Row(
          children: [
            Stack(
              children: [
                sender.profilePic == null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            height: 50,
                            imageUrl: state.profileUserModel?.profilePic ??
                                "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg"))
                    : CircleAvatar(
                        radius: 30,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            sender.profilePic!,
                            fit: BoxFit.fill,
                            height: 60,
                            width: 60,
                          ),
                        ),
                      ),
                /* Positioned(
                    top: 0,
                    right: 2,
                    child: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red),
                        child: Center(
                            child: Text('5',
                                style: TextStyle(color: Colors.white)))))*/
              ],
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUser.displayName!, // Display the other user's name
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                widget.type == "text"
                    ? SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.lastMessage,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  color:
                                      widget.read ? Colors.grey : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        width: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: widget.read ? 0.5 : 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  widget.lastMessage,
                                  height: 60,
                                  width: 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
              ],
            ),
            Expanded(
                child: Text(
              timesAgo,
              style: const TextStyle(color: Colors.white),
            ))
          ],
        ),
      ),
    );
  }
}
