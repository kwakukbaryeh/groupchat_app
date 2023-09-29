import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/widgets/custom/rippleButton.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class NotifcationTest extends StatefulWidget {
  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<NotifcationTest> {
  Future<void> sendNotificationToUser(String userId) async {
    const url =
        'https://sendnotificationtouser-fbm2eqbq6q-uc.a.run.app/sendNotificationToUser';
    final response = await http.post(
      Uri.parse(url),
      body: {'userId': userId},
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully!');
    } else {
      print('Error sending notification: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return Scaffold(
        appBar: AppBar(
          leading: Container(),
          elevation: 0,
          backgroundColor: Colors.black,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 130,
            ),
            const Icon(
              Icons.arrow_upward_rounded,
              size: 60,
              color: Colors.white,
            ),
            Container(
              height: 10,
            ),
            Text(
              "\n${state.profileUserModel?.displayName},\nTap the notification to join.",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        bottomSheet: Container(
            height: 170,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 60),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Iconsax.notification,
                            color: Color.fromARGB(255, 101, 101, 101)),
                        Padding(
                            padding: EdgeInsets.only(top: 5, left: 5),
                            child: Text(
                              "Disable to not disturb",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 101, 101, 101)),
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RippleButton(
                          splashColor: Colors.transparent,
                          child: Container(
                              height: 70,
                              width: MediaQuery.of(context).size.width - 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                  child: Text(
                                "Resend notification",
                                style: TextStyle(
                                    fontFamily: "icons.ttf",
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800),
                              ))),
                          onPressed: () async {
                            print("Sending notification");

                            var state =
                                Provider.of<AuthState>(context, listen: false);
                            await sendNotificationToUser(
                                state.profileUserModel?.userId ?? '');
                          },
                        )
                      ],
                    ),
                  ],
                ))));
  }
}
