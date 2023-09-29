// ignore_for_file: must_be_immutable

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:groupchat_firebase/widgets/share.dart';
import '../animation/animation.dart';
import 'notification.dart';

class ContactPage extends StatefulWidget {
  final VoidCallback? loginCallback;
  ContactPage({Key? key, this.loginCallback}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class ContactItem {
  final String name;
  final String phoneNumber;

  ContactItem({required this.name, required this.phoneNumber});
}

class _ContactPageState extends State<ContactPage> {
  List<ContactItem> contactItems = [];

  @override
  void initState() {
    super.initState();
    ContactsService.getContacts().then((contacts) {
      for (var contact in contacts) {
        for (var phone in contact.phones!) {
          contactItems.add(ContactItem(
              name: contact.displayName ?? '', phoneNumber: phone.value!));
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0) {
            setState(() {
              Navigator.pop(context);
            });
          }
        },
        child: Scaffold(
            appBar: AppBar(
              actions: [
                Padding(
                    padding: EdgeInsets.only(top: 15, right: 10),
                    child: GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          Navigator.push(
                            context,
                            AwesomePageRoute(
                              transitionDuration: Duration(milliseconds: 600),
                              exitPage: widget,
                              enterPage: NotificationPage(),
                              transition: ZoomOutSlideTransition(),
                            ),
                          );
                        },
                        child: Text("Skip",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 61, 61, 61),
                            ))))
              ],
              elevation: 0,
              title: Image.asset(
                "assets/rebeals.png",
                height: 50,
              ),
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
                  "Find you're friends\n",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Add your friends to keepUp.",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: contactItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(contactItems[index].name),
                        subtitle: Text(contactItems[index].phoneNumber),
                        leading: Icon(CupertinoIcons.profile_circled),
                        trailing: Container(
                          width: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Share functionality
                                  sendSMS(
                                      message: 'Join me on keepUp!',
                                      recipients: [
                                        contactItems[index].phoneNumber
                                      ]);
                                },
                                child: Container(
                                  height: 30,
                                  width: 90,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(90),
                                  ),
                                  child: Text(
                                    "ADD",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Delete functionality
                                  setState(() {
                                    contactItems.removeAt(index);
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey[800],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            )));
  }
}
