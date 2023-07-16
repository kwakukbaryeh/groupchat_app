// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:groupchat_firebase/notification/notification.dart';

import '../animation/animation.dart';

class NotificationPage extends StatefulWidget {
  final VoidCallback? loginCallback;
  NotificationPage({Key? key, this.loginCallback}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<void> requestNotificationPermission() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.show(
      0,
      'Sample Notification',
      'This is a sample notification',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
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
            Text(
              "When to post your\nReBeal?\n",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            Text(
              "The only way to know when to post your\nReBeal is to turn on notifcations !",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
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
                  Text(
                    "\nPlease turn on notifications\n",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "\nAll notifications on App title\nare silent except for the one that\ntindicates when to post on App title\n once a day.",
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
                        HapticFeedback.heavyImpact();
                        FlutterLocalNotificationsPlugin
                            flutterLocalNotificationsPlugin =
                            FlutterLocalNotificationsPlugin();
                        await flutterLocalNotificationsPlugin.show(
                          0,
                          'Sample Notification',
                          'This is a sample notification',
                          NotificationDetails(
                            android: AndroidNotificationDetails(
                              'channel_id',
                              'channel_name',
                              importance: Importance.max,
                              priority: Priority.high,
                            ),
                            iOS: DarwinNotificationDetails(),
                          ),
                        );
                        Navigator.push(
                          context,
                          AwesomePageRoute(
                            transitionDuration: Duration(milliseconds: 600),
                            exitPage: widget,
                            enterPage: NotifcationTest(),
                            transition: ZoomOutSlideTransition(),
                          ),
                        );
                      },
                      child: Container(
                        width: 260,
                        height: 40,
                        color: Color.fromARGB(255, 0, 120, 232),
                        alignment: Alignment.center,
                        child: Text(
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
                  Text(
                    "Allow in scheduled\nSummary",
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
                  Text(
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
        ));
  }
}
