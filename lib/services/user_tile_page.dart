import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/pages/profile_page.dart';
import 'package:groupchat_firebase/widgets/custom/title_text.dart';

class UserTilePage extends StatelessWidget {
  UserTilePage({Key? key, required this.user, required this.isadded})
      : super(key: key) {
    print("isadded in UserTilePage: $isadded"); // Debugging print
    print("userId in UserTilePage: ${user.userId}"); // Debugging print
  }
  final UserModel user;
  bool? isadded;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log(user.userId!);
        Navigator.push(
          context,
          ProfilePage.getRoute(
              profileId: user.userId!, isadded: isadded!, user: user),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl: user.profilePic ??
                    "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg",
                height: 60,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TitleText(
                    user.displayName!,
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.userName!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            isadded!
                ? Container()
                : SizedBox(
                    width: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Material(
                          child: InkWell(
                            onTap: () async {
                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                print("called");
                                await FirebaseFirestore.instance
                                    .collection("friendship")
                                    .doc(user.uid)
                                    .set({"d": "d"});
                                FirebaseFirestore.instance
                                    .collection("friendship")
                                    .doc(user.uid)
                                    .collection("friends")
                                    .add({
                                  "email": this.user.email,
                                  "userId": this.user.userId,
                                  "userName": this.user.userName,
                                  "displayName": this.user.displayName,
                                  "localisation": this.user.localisation,
                                  "bio": this.user.bio,
                                  "profilePic": this.user.profilePic,
                                  "key": this.user.key,
                                  "createAt": this.user.createAt,
                                  "fcmToken": this.user.fcmToken
                                });
                              }
                            },
                            child: Container(
                              height: 30,
                              width: 90,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(221, 69, 69, 69),
                                borderRadius: BorderRadius.circular(90),
                              ),
                              child: const Text(
                                "ADD",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey[800],
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
