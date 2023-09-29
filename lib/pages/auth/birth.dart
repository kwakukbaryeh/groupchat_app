// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groupchat_firebase/animation/animation.dart';
import 'package:groupchat_firebase/widgets/custom/rippleButton.dart';
import 'package:groupchat_firebase/pages/auth/signup.dart';
import 'package:intl/intl.dart'; // Import for date parsing

class BirthPage extends StatefulWidget {
  final String name;
  final String username;
  final VoidCallback? loginCallback;

  BirthPage(
      {Key? key,
      required this.name,
      required this.username,
      this.loginCallback})
      : super(key: key);

  @override
  _BirthPageState createState() => _BirthPageState();
}

bool empt = false;

class _BirthPageState extends State<BirthPage> {
  final _birthController = TextEditingController();
  bool isAgeValid = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    print("Username received in BirthPage: ${widget.username}");
  }

  int calculateAge(DateTime birthDate) {
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (birthDate.month > currentDate.month ||
        (birthDate.month == currentDate.month &&
            birthDate.day > currentDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
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
              "Hello ${widget.name}, when is your birthday?",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            TextField(
              textAlign: TextAlign.center,
              onChanged: (value) {
                setState(() {
                  _birthController.text.isNotEmpty ? empt = true : empt = false;
                  isAgeValid = true; // Reset the flag when user types
                });
                if (_birthController.text.length == 2) {
                  _birthController.text = "${_birthController.text} ";
                  _birthController.selection = TextSelection.fromPosition(
                      TextPosition(
                          offset: _birthController.text.length,
                          affinity: TextAffinity.upstream));
                }
                if (_birthController.text.length == 5) {
                  _birthController.text = "${_birthController.text} ";
                  _birthController.selection = TextSelection.fromPosition(
                      TextPosition(
                          offset: _birthController.text.length,
                          affinity: TextAffinity.upstream));
                }
                if (_birthController.text.length >= 11) {
                  _birthController.text = _birthController.text
                      .substring(0, _birthController.text.length - 1);
                }
              },
              keyboardType: TextInputType.number,
              keyboardAppearance: Brightness.dark,
              controller: _birthController,
              decoration: const InputDecoration(
                  hintText: 'MM DD YYYY',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: Color.fromARGB(255, 60, 60, 60),
                      fontSize: 38,
                      fontWeight: FontWeight.w800)),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800),
            ),
            if (!isAgeValid) // Display the error message
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        bottomSheet: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RippleButton(
                  splashColor: Colors.transparent,
                  child: Container(
                      height: 70,
                      width: MediaQuery.of(context).size.width - 40,
                      decoration: BoxDecoration(
                        color: empt || _birthController.text.isNotEmpty
                            ? Colors.white
                            : const Color.fromARGB(255, 61, 61, 61),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                          child: Text(
                        "Continue",
                        style: TextStyle(
                            fontFamily: "icons.ttf",
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w800),
                      ))),
                  onPressed: () {
                    if (_birthController.text.isNotEmpty) {
                      DateTime? birthDate;
                      try {
                        birthDate = DateFormat('MM dd yyyy')
                            .parse(_birthController.text.trim());
                      } catch (e) {
                        // Handle the error if the date format is wrong
                        setState(() {
                          isAgeValid = false;
                          errorMessage = 'Invalid date format';
                        });
                        return;
                      }

                      final age = calculateAge(birthDate);

                      if (age < 13) {
                        setState(() {
                          isAgeValid = false;
                          errorMessage =
                              'Must be 13 years or older to join keepUp!';
                        });
                      } else {
                        HapticFeedback.heavyImpact();
                        Navigator.push(
                          context,
                          AwesomePageRoute(
                            transitionDuration:
                                const Duration(milliseconds: 600),
                            exitPage: widget,
                            enterPage: Signup(
                                name: widget.name,
                                birth: _birthController.text,
                                username: widget.username),
                            transition: ZoomOutSlideTransition(),
                          ),
                        );
                      }
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
