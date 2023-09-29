import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/pages/settings.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/widgets/memories.dart';
import 'package:groupchat_firebase/widgets/share.dart';
import 'package:provider/provider.dart';
import 'edit.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<MyProfilePage> {
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final previousDays = List<DateTime>.generate(
        14, (index) => today.subtract(Duration(days: index)));
    final reversedDays = previousDays.reversed.toList();
    var state = Provider.of<AuthState>(context);
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
            actions: [
              FadeIn(
                  duration: const Duration(milliseconds: 1000),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsPage()));
                      },
                      child: const Icon(Icons.more_horiz, color: Colors.white)))
            ],
            leading: FadeIn(
                duration: const Duration(milliseconds: 1000),
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white))),
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: FadeInRight(
                duration: const Duration(milliseconds: 300),
                child: const Text(
                  "Profile",
                  style: TextStyle(color: Colors.white),
                ))),
        body: Center(
            child: FadeInDown(
                child: ListView(
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfilePage()));
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: SizedBox(
                              height: 120,
                              width: 120,
                              child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  height: 100,
                                  imageUrl: state
                                          .profileUserModel?.profilePic ??
                                      "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg"),
                            ))),
                    Container(height: 10),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfilePage()));
                        },
                        child: Text(
                          state.profileUserModel?.displayName.toString() ?? "",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700),
                        )),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfilePage()));
                        },
                        child: Text(
                          state.profileUserModel?.userName.toString() ?? "",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        )),
                    Container(height: 10),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfilePage()));
                        },
                        child: Text(
                          state.profileUserModel?.bio ?? "",
                          style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        )),
                    Container(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Time Capsule",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w700),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.lock,
                              color: Colors.grey[800],
                              size: 12,
                            ),
                            Container(
                              width: 5,
                            ),
                            Text(
                              "Only visible for me.",
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        )
                      ],
                    ),
                    Container(
                      height: 10,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                          color: Colors.grey[800],
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "last 14 days",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Expanded(
                                      child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 7,
                                                  mainAxisSpacing: 0,
                                                  crossAxisSpacing: 0),
                                          itemCount: reversedDays.length,
                                          itemBuilder: (context, index) {
                                            final day = reversedDays[index];
                                            return Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: index == 13
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    '${day.day}',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: index == 13
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ));
                                          })),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MemoriesPage()));
                                      },
                                      child: Center(
                                          child: Container(
                                        height: 40,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          shape: BoxShape.rectangle,
                                          border: Border.all(
                                              color: Colors.white, width: 0.4),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "See all of your Groups",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      )))
                                ],
                              ))),
                    ),
                    Container(
                      height: 30,
                    ),
                    GestureDetector(
                        onTap: () {
                          shareText(
                              "keepUp/${state.profileUserModel?.userName!.replaceAll("@", "").toLowerCase() ?? ""}");
                        },
                        child: Text(
                          "🔗 keepUp/${state.profileUserModel?.userName!.replaceAll("@", "").toLowerCase() ?? ""}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w400),
                        )),
                  ],
                ))
          ],
        ))));
  }
}
