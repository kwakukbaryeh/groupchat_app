import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'edit.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: FadeIn(
            duration: const Duration(milliseconds: 1000),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: FadeInRight(
            duration: const Duration(milliseconds: 300),
            child: const Text(
              "Settings",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ListView(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 90,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[900],
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: SizedBox(
                                  height: 65,
                                  width: 65,
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    height: 100,
                                    imageUrl: state
                                            .profileUserModel?.profilePic ??
                                        "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg",
                                  ),
                                ),
                              ),
                              Container(
                                width: 10,
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '${state.profileUserModel!.displayName}\n',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '${state.profileUserModel!.userName}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 30,
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey[800],
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                ),
                const Text(
                  "About",
                  style: TextStyle(color: Color.fromARGB(255, 65, 65, 65)),
                ),
                Container(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          String tikTokUrl =
                              'https://www.tiktok.com/@your_account';
                          if (await canLaunch(tikTokUrl)) {
                            await launch(tikTokUrl);
                          }
                        },
                        child: ListTile(
                          leading: const Icon(CupertinoIcons.video_camera,
                              color: Colors.white),
                          title: const Text(
                            "Follow on TikTok",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.white),
                        ),
                      ),
                      Divider(color: Colors.black),
                      GestureDetector(
                        onTap: () async {
                          String instagramUrl =
                              'https://www.instagram.com/your_account';
                          if (await canLaunch(instagramUrl)) {
                            await launch(instagramUrl);
                          }
                        },
                        child: ListTile(
                          leading: const Icon(CupertinoIcons.camera,
                              color: Colors.white),
                          title: const Text(
                            "Follow on Instagram",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.white),
                        ),
                      ),
                      Divider(color: Colors.black),
                      GestureDetector(
                        onTap: () async {
                          String twitterUrl =
                              'https://twitter.com/your_account';
                          if (await canLaunch(twitterUrl)) {
                            await launch(twitterUrl);
                          }
                        },
                        child: ListTile(
                          leading: const Icon(CupertinoIcons.at,
                              color: Colors.white),
                          title: const Text(
                            "Follow on Twitter",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.white),
                        ),
                      ),
                      Divider(color: Colors.black),
                      GestureDetector(
                        onTap: () {
                          Share.share(
                            "keepUp/${state.profileUserModel!.userName!.replaceAll("@", "").toLowerCase()}",
                            subject: "Add me on keepUp.",
                            sharePositionOrigin:
                                const Rect.fromLTWH(0, 0, 10, 10),
                          );
                        },
                        child: ListTile(
                          leading: const Icon(CupertinoIcons.share,
                              color: Colors.white),
                          title: const Text(
                            "Share keepUp",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.white),
                        ),
                      ),
                      Divider(color: Colors.black),
                      // "Terms of Service" button
                      GestureDetector(
                        onTap: () async {
                          String termsUrl = 'https://your_website.com/terms';
                          if (await canLaunch(termsUrl)) {
                            await launch(termsUrl);
                          }
                        },
                        child: ListTile(
                          leading: const Icon(CupertinoIcons.doc_text,
                              color: Colors.white),
                          title: const Text(
                            "Terms of Service",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.white),
                        ),
                      ),
                      Divider(color: Colors.black),
                      // "Privacy Policy" button
                      GestureDetector(
                        onTap: () async {
                          String privacyUrl =
                              'https://your_website.com/privacy';
                          if (await canLaunch(privacyUrl)) {
                            await launch(privacyUrl);
                          }
                        },
                        child: ListTile(
                          leading: const Icon(CupertinoIcons.lock_shield,
                              color: Colors.white),
                          title: const Text(
                            "Privacy Policy",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 5,
                ),
                Container(
                  height: 5, // Add 5 more pixels of space
                ),
                // General Section
                const Text(
                  "General",
                  style: TextStyle(color: Color.fromARGB(255, 65, 65, 65)),
                ),
                Container(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      // "Get help" button
                      GestureDetector(
                        onTap: () async {
                          final mailtoLink = Uri(
                            scheme: 'mailto',
                            path: 'help@keepUp.com',
                            queryParameters: {
                              'subject': 'keepUp Help',
                            },
                          ).toString();
                          if (await canLaunch(mailtoLink)) {
                            await launch(mailtoLink);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Could not launch email client')),
                            );
                          }
                        },
                        child: ListTile(
                          leading: const Icon(CupertinoIcons.question_circle,
                              color: Colors.white),
                          title: const Text(
                            "Get help",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.white),
                        ),
                      ),
                      Divider(color: Colors.black),
                      // "Feedback" button
                      GestureDetector(
                        onTap: () async {
                          final mailtoLink = Uri(
                            scheme: 'mailto',
                            path: 'feedback@keepUp.com',
                            queryParameters: {
                              'subject': 'keepUp Feedback',
                            },
                          ).toString();
                          if (await canLaunch(mailtoLink)) {
                            await launch(mailtoLink);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Could not launch email client')),
                            );
                          }
                        },
                        child: ListTile(
                          leading: const Icon(
                              CupertinoIcons.bubble_left_bubble_right,
                              color: Colors.white),
                          title: const Text(
                            "Share feedback",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.white),
                        ),
                      ),
                      // ... (You can add more buttons here)
                    ],
                  ),
                ),
                /*
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 300, // You can adjust this value as needed
                          child: Column(
                            children: [
                              ListTile(
                                title: Text('Blocked Users'),
                              ),
                              Divider(),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: blockedUsers.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(blockedUsers[index]),
                                      // Add more properties like leading icons, trailing icons, etc. if needed
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[800],
                      alignment: Alignment.center,
                      child: const Text(
                        "Blocked",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),*/
                Container(
                  height: 5,
                ),
                Container(
                  height: 5, // Add 5 more pixels of space
                ),
                // Danger Zone Section
                const Text(
                  "Danger Zone",
                  style: TextStyle(color: Color.fromARGB(255, 65, 65, 65)),
                ),
                Container(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      // "Log out" button
                      GestureDetector(
                        onTap: () {
                          state.logoutCallback();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: ListTile(
                          leading: const Icon(CupertinoIcons.xmark_circle,
                              color: Colors.red),
                          title: const Text(
                            "Log out",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.red),
                        ),
                      ),
                      Divider(color: Colors.black),
                      // "Delete Account" button
                      GestureDetector(
                        onTap: () {
                          // Add your delete account logic here
                        },
                        child: ListTile(
                          leading: const Icon(CupertinoIcons.trash_circle,
                              color: Colors.red),
                          title: const Text(
                            "Delete Account",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "Version 1.0.0 (0) - Beta",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromARGB(255, 96, 96, 96),
                      fontWeight: FontWeight.w300,
                      fontSize: 15),
                ),
                Container(
                  height: 40,
                ),
              ],
            )));
  }
}
