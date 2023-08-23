import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class ChatBottomBar extends StatefulWidget {
  UserModel sender;
  UserModel receiver;
  String chatRoomId;
  ChatBottomBar(
      {super.key, required this.sender, required this.receiver, required this.chatRoomId});

  @override
  _ChatBottomBarState createState() => _ChatBottomBarState();
}

class _ChatBottomBarState extends State<ChatBottomBar> {
  TextEditingController messageTextEdittingController = TextEditingController();
  late String messageId = "";

  addMessage(bool sendClicked) {
    if (messageTextEdittingController.text != "") {
      String message = messageTextEdittingController.text;

      var lastMessageTs = DateTime.now();
      Map<String, dynamic> messageInfoMap = {
        "type": 'text',
        "message": message,
        "sendBy": widget.sender.userName,
        "ts": lastMessageTs,
        "imgUrl": widget.sender.profilePic
      };

      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      Database()
          .addMessage(widget.chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "type": "text",
          "read": false,
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": widget.sender.userName,
          "sender": widget.sender.toJson(),
          "receiver": widget.receiver.toJson()
        };

        Database().updateLastMessageSend(widget.chatRoomId, lastMessageInfoMap);
        if (sendClicked) {
          // remove the text in the message input field
          messageTextEdittingController.text = "";
          // make message id blank to get regenerated on next message send
          messageId = "";
        }
      });
    }
  }

  addFile() async {
    //FilePickerResult? result = await FilePicker.platform.pickFiles();
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      //file = result.files.single;
      String fileName = '${DateTime.now().toString()}.png';
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putData(await image.readAsBytes());
      String urlImage = await (await uploadTask).ref.getDownloadURL();

      void setImageMsg(String url, String chatRoomId) async {
        Map<String, dynamic> messageInfoMap = {
          "type": 'image',
          "photoUrl": url,
          "sendBy": widget.sender.userName,
          "ts": Timestamp.now(),
          "imgUrl": widget.sender.profilePic
        };

        String messageId = randomAlphaNumeric(12);

        Database()
            .addMessage(chatRoomId, messageId, messageInfoMap)
            .then((value) {
          Map<String, dynamic> lastMessageInfoMap = {
            "type": "image",
            "read": false,
            "lastMessage": url,
            "lastMessageSendTs": Timestamp.now(),
            "lastMessageSendBy": widget.sender.userName,
            "sender": widget.sender.toJson(),
            "receiver": widget.receiver.toJson()
          };

          Database().updateLastMessageSend(chatRoomId, lastMessageInfoMap);
        });
      }

      setImageMsg(urlImage, widget.chatRoomId);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width / 100;
    var h = MediaQuery.of(context).size.height / 100;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        width: double.infinity,
        decoration: const BoxDecoration(
            /*boxShadow: [
          BoxShadow(
              blurRadius: 10.0,
              offset: Offset(2, 2),
              color: Colors.grey.withOpacity(0.5))
        ]*/
            ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /*appProvider.type == ""
                  ? Container()
                  : appProvider.type == "text"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            appProvider.senderReplied == widget.sender
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "You",
                                        style:
                                            TextStyle(color: Color(0xff4B0973)),
                                      ),
                                      InkWell(
                                        child: Icon(Icons.cancel,
                                            color: Color(0xff4B0973)),
                                        onTap: () {
                                          appProvider.updateVal(
                                              "", "", false, "", "");
                                        },
                                      )
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        appProvider.senderReplied,
                                        style:
                                            TextStyle(color: Color(0xff4B0973)),
                                      ),
                                      InkWell(
                                        child: Icon(Icons.cancel,
                                            color: Color(0xff4B0973)),
                                        onTap: () {
                                          appProvider.updateVal(
                                              "", "", false, "", "");
                                        },
                                      )
                                    ],
                                  ),
                            Container(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border: Border(
                                      left: BorderSide(
                                        color: Color(0xff4B0973),
                                        width: 10,
                                      ),
                                    )),
                                child: Row(
                                  children: [
                                    Flexible(
                                        child: Text(appProvider.msgreplied)),
                                  ],
                                )),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            appProvider.senderReplied == widget.sender
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "You",
                                        style:
                                            TextStyle(color: Color(0xff4B0973)),
                                      ),
                                      InkWell(
                                        child: Icon(Icons.cancel,
                                            color: Color(0xff4B0973)),
                                        onTap: () {
                                          appProvider.updateVal(
                                              "", "", false, "", "");
                                        },
                                      )
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        appProvider.senderReplied,
                                        style:
                                            TextStyle(color: Color(0xff4B0973)),
                                      ),
                                      InkWell(
                                        child: Icon(Icons.cancel,
                                            color: Color(0xff4B0973)),
                                        onTap: () {
                                          appProvider.updateVal(
                                              "", "", false, "", "");
                                        },
                                      )
                                    ],
                                  ),
                            Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border(
                                    left: BorderSide(
                                      color: Color(0xff4B0973),
                                      width: 10,
                                    ),
                                  )),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Image.network(
                                      "https://pboforum.com/office/${appProvider.msgreplied}",
                                      height: 90,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageTextEdittingController,
                      decoration: InputDecoration(
                        filled: true,
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black45, width: 2.0),
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        fillColor: Colors.white60,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        hintText: 'Type a message...',
                        suffixIcon: IconButton(
                          onPressed: () {
                            addMessage(true);
                          },
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      /*widget.forum ? addFileToGroup() : addFile();
                      appProvider.updateVal("", "", false, "", "");*/
                    },
                    icon: const Icon(
                      Icons.attachment_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
