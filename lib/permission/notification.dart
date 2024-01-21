// ignore_for_file: must_be_immutable
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:groupchat_firebase/main.dart';
import 'package:groupchat_firebase/notification/notification.dart';
import 'package:groupchat_firebase/pages/homepage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../animation/animation.dart';
import '../state/auth_state.dart';

class NotificationPage extends StatefulWidget {
  final VoidCallback? loginCallback;
  const NotificationPage({Key? key, this.loginCallback}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<void> sendNotificationToUser(String userId) async {
    const url = 'https://sendnotificationtouser-fbm2eqbq6q-uc.a.run.app';
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
          const Text(
            "When to post your\nkeepUp ?\n",
            style: TextStyle(
                color: Colors.white, fontSize: 35, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const Text(
            "The only way to know when to post your\nkeepUp is to turn on notifications !",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          Container(
            height: 30,
          ),
          Container(
            height: 300,
            width: 250,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const Text(
                  "\nPlease turn on notifications\n",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "\nAll notifications on keepUp\nare silent except for the one telling\nwhen to post on keepUp\n",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w300),
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: 20,
                ),
                GestureDetector(
                    onTap: () async {
                      print("Sending notification from Permission folder");
                      HapticFeedback.heavyImpact();

                      // Request notification permissions
                      FirebaseMessaging messaging = FirebaseMessaging.instance;
                      NotificationSettings settings =
                          await messaging.requestPermission(
                        alert: true,
                        announcement: false,
                        badge: true,
                        carPlay: false,
                        criticalAlert: false,
                        provisional: false,
                        sound: true,
                      );

                      if (settings.authorizationStatus ==
                          AuthorizationStatus.authorized) {
                        print('User granted permission');

                        // Initialize local notifications after permission is granted
                        flutterLocalNotificationsPlugin
                            .initialize(initializationSettings,
                                onDidReceiveNotificationResponse:
                                    (NotificationResponse response) async {
                          // Navigate the user to the homepage
                          navigatorKey.currentState!.pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        });

                        // If granted, proceed with your logic
                        var state =
                            Provider.of<AuthState>(context, listen: false);
                        await sendNotificationToUser(
                            state.profileUserModel?.userId ?? '');

                        Navigator.push(
                          context,
                          AwesomePageRoute(
                            transitionDuration:
                                const Duration(milliseconds: 600),
                            exitPage: widget,
                            enterPage: NotifcationTest(),
                            transition: ZoomOutSlideTransition(),
                          ),
                        );
                      } else {
                        print('User declined or has not accepted permission');
                        navigatorKey.currentState!.pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      }
                    },
                    child: Container(
                      width: 260,
                      height: 40,
                      color: const Color.fromARGB(255, 0, 120, 232),
                      alignment: Alignment.center,
                      child: const Text(
                        "Allow",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    )),
                Container(
                  height: 10,
                ),
                const Text(
                  "Allow in your \n Scheduled Summary",
                  style: TextStyle(
                      color: Color.fromARGB(255, 89, 89, 89),
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: 10,
                ),
                Container(
                  color: Colors.grey,
                  height: 0.3,
                  width: 250,
                ),
                Container(
                  height: 10,
                ),
                const Text(
                  "Refuse",
                  style: TextStyle(
                      color: Color.fromARGB(255, 89, 89, 89),
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
