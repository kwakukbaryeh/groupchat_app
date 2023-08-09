import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/services/database.dart';
import 'package:provider/provider.dart';

class ChatMessages extends StatefulWidget {
  UserModel sender;
  UserModel receiver;
  String chatRoomId;

  ChatMessages(
      {required this.sender, required this.receiver, required this.chatRoomId});

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  int idx = -1;
  Stream? messageStream;
  ScrollController? scrollController;

  Widget chatMessageTile(
    String message,
    bool sendByMe,
    String senderName,
    String receiverName,
    String? senderPics,
    String? receiverPics,
    String reply,
    Timestamp time,
  ) {
    return !sendByMe
        ? message != ""
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    receiverPics == null
                        ? Container()
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: CachedNetworkImage(
                                height: 40,
                                width: 40,
                                imageUrl: receiverPics,
                                fit: BoxFit.fill,
                                progressIndicatorBuilder:
                                    (context, url, progress) => Center(
                                          child: CircularProgressIndicator(
                                              value: progress.progress),
                                        ))),
                    SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            constraints: BoxConstraints(maxWidth: 200),
                            decoration: BoxDecoration(
                              color: Color(0xff4B0973),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(20),
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                reply != ""
                                    ? reply.contains("uploads/images/")
                                        ? Flexible(
                                            child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                        255, 197, 207, 243),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Image.network(
                                                  "https://pboforum.com/office/$reply",
                                                  height: 40,
                                                  width: 40,
                                                )),
                                          )
                                        : Flexible(
                                            child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                        255, 197, 207, 243),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Text(
                                                  reply,
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontFamily: "Nunito"),
                                                )),
                                          )
                                    : Container(
                                        width: 3,
                                      ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  message,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontFamily: "Helvetica"),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  formatDate(
                                      time.toDate(), [M, ' ', dd, ', ', yyyy]),
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            senderName,
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Container()
        : message != ""
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 200),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 197, 207, 243),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: reply != ""
                                      ? reply.contains("uploads/images/")
                                          ? Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color: Color(0xff4B0973),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Image.network(
                                                "https://pboforum.com/office/$reply",
                                                height: 40,
                                                width: 40,
                                              ),
                                            )
                                          : Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color: Color(0xff4B0973),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Text(
                                                reply,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "Nunito",
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            )
                                      : Container(
                                          width: 3,
                                        ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  message,
                                  style: TextStyle(
                                      fontSize: 16.0, fontFamily: "Helvetica"),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  formatDate(
                                      time.toDate(), [M, ' ', dd, ', ', yyyy]),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            senderName,
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    senderPics == null
                        ? Container()
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: CachedNetworkImage(
                                height: 40,
                                width: 40,
                                imageUrl: senderPics,
                                fit: BoxFit.fill,
                                progressIndicatorBuilder:
                                    (context, url, progress) => Center(
                                          child: CircularProgressIndicator(
                                              value: progress.progress),
                                        )))
                  ],
                ),
              )
            : Container();
  }

  Widget imageMessageTile(
      String? url,
      bool sendByMe,
      String senderName,
      String receiverName,
      String? senderPics,
      String? receiverPics,
      String reply,
      String time) {
    return sendByMe
        ? url != null
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Icon(Icons.phone,color: const Color(0xff7672c9),),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          //height: 180,
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 197, 207, 243),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          margin: EdgeInsets.only(
                            top: 10,
                          ),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              reply != ""
                                  ? reply.contains("uploads/images/")
                                      ? Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: Color(0xff4B0973),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          child: Image.network(
                                            "https://pboforum.com/office/$reply",
                                            height: 40,
                                            width: 40,
                                          ),
                                        )
                                      : Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: Color(0xff4B0973),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          child: Text(
                                            reply,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Nunito",
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        )
                                  : Container(),
                              SizedBox(
                                height: 8,
                              ),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                child: Image.network(
                                  "https://pboforum.com/office/${url}",
                                  height: 90,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                time,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          senderName,
                        )
                      ],
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    senderPics == null
                        ? Container()
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: CachedNetworkImage(
                                height: 40,
                                width: 40,
                                imageUrl: senderPics,
                                fit: BoxFit.fill,
                                progressIndicatorBuilder:
                                    (context, url, progress) => Center(
                                          child: CircularProgressIndicator(
                                              value: progress.progress),
                                        )))
                  ],
                ),
              )
            : Container()
        : url != null
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Icon(Icons.phone,color: const Color(0xff7672c9),),

                    receiverPics == null
                        ? Container()
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: CachedNetworkImage(
                                height: 40,
                                width: 40,
                                imageUrl: receiverPics,
                                fit: BoxFit.fill,
                                progressIndicatorBuilder:
                                    (context, url, progress) => Center(
                                          child: CircularProgressIndicator(
                                              value: progress.progress),
                                        ))),
                    SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          //height: 180,
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(
                            color: Color(0xff4B0973),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          margin: EdgeInsets.only(
                            top: 10,
                          ),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              reply != ""
                                  ? reply.contains("uploads/images/")
                                      ? Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 197, 207, 243),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          child: Image.network(
                                            "https://pboforum.com/office/$reply",
                                            height: 40,
                                            width: 40,
                                          ))
                                      : Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 197, 207, 243),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          child: Text(
                                            reply,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: "Nunito"),
                                          ))
                                  : Container(),
                              SizedBox(
                                height: 8,
                              ),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                child: Image.network(
                                  "https://pboforum.com/office/${url}",
                                  height: 90,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                time,
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          senderName,
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ],
                ),
              )
            : Container();
  }

  Widget chatMessages(h, w, ctx) {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        QuerySnapshot? q =
            snapshot.data != null ? snapshot.data as QuerySnapshot : null;
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 70, top: 16),
                itemCount: q!.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = q.docs[index];
                  return ds['type'] == 'text'
                      ? chatMessageTile(
                          ds["message"],
                          widget.sender.userName == ds["sendBy"],
                          widget.sender.displayName!,
                          widget.receiver.displayName!,
                          widget.sender.profilePic,
                          widget.receiver.profilePic,
                          "",
                          ds["ts"],
                        )
                      : imageMessageTile(
                          ds['photoUrl'],
                          widget.sender.userName == ds["sendBy"],
                          widget.sender.displayName!,
                          widget.receiver.displayName!,
                          widget.sender.profilePic,
                          widget.receiver.profilePic,
                          "",
                          ds["ts"],
                        );
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  getMessageStream(String chatRoomId) async {
    messageStream = await Database().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController = ScrollController();
    getMessageStream(widget.chatRoomId);
    /*Timer.periodic(Duration(milliseconds: 250), (timer) {
      appProvider.getNotifications();
      timer.cancel();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width / 100;
    var h = MediaQuery.of(context).size.height / 100;
    return SafeArea(
        child: Column(
      children: [
        Expanded(
          child: chatMessages(h, w, context),
        ),
        SizedBox(
          height: 88.2,
        )
      ],
    ));
  }
}

/*const String dateFormatter = 'MMMM dd, y';

extension DateHelper on DateTime {
  String formatDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }

  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}*/
