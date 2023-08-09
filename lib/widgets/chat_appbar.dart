import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';

class ChatAppBar extends StatelessWidget {
  //final OurUser recipient;
  final IconData icon;
  UserModel receiver;

  ChatAppBar(
      {
      //required this.recipient,
      required this.icon,
      required this.receiver});

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width / 100;
    var h = MediaQuery.of(context).size.height / 100;
    var state = Provider.of<AuthState>(context);
    return SafeArea(
      child: Container(
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 25,
            ),
            /*Expanded(
              child: GestureDetector(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: w * 1.9, vertical: h * 0.8),
                    child: Icon(icon, color: Color(0xff00AEFF), size: w * 7.3),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),*/
            Expanded(
              flex: 5,
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  children: [
                    receiver.profilePic == null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                height: 50,
                                imageUrl: state.profileUserModel?.profilePic ??
                                    "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg"))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                                height: 70,
                                width: 70,
                                imageUrl: receiver.profilePic!,
                                fit: BoxFit.fill,
                                progressIndicatorBuilder:
                                    (context, url, progress) => Center(
                                          child: CircularProgressIndicator(
                                              value: progress.progress),
                                        ))),
                    SizedBox(width: w * 3.6),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: w * 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              receiver.displayName!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: w * 4.8,
                              ),
                            ),
                          ),

                          /*Flexible(
                            child: Text(
                              "Online",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: w * 4.8,
                              ),
                            ),
                          ),*/
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
