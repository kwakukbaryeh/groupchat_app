import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groupchat_firebase/animation/animation.dart';
import 'package:groupchat_firebase/widgets/custom/rippleButton.dart';
import 'birth.dart';
import 'package:firebase_database/firebase_database.dart';

class UsernamePage extends StatefulWidget {
  final String name;
  final VoidCallback? loginCallback;

  const UsernamePage({Key? key, required this.name, this.loginCallback})
      : super(key: key);

  @override
  _UsernamePageState createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final _usernameController = TextEditingController();
  bool isUsernameTaken = false;
  bool isUsernameLengthValid = true; // Add this
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  Future<bool> checkIfUsernameExists(String username) async {
    final DatabaseReference usersRef =
        FirebaseDatabase.instance.reference().child('profile');
    final DatabaseEvent event =
        await usersRef.orderByChild('userName').equalTo('@$username').once();

    final DataSnapshot snapshot = event.snapshot;

    return snapshot.value != null;
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
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 130,
              ),
              const Text(
                "Pick a username",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  setState(() {
                    isUsernameTaken = false; // Reset the flag when user types
                    isUsernameLengthValid =
                        true; // Reset the flag when user types
                  });
                },
                keyboardAppearance: Brightness.dark,
                controller: _usernameController,
                decoration: InputDecoration(
                    hintText: 'Username',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: Color.fromARGB(255, 60, 60, 60),
                        fontSize: 45,
                        fontWeight: FontWeight.w800)),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 45,
                    fontWeight: FontWeight.w800),
              ),
              if (isUsernameTaken)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        bottomSheet: Container(
          height: 140,
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
            child: Column(
              children: [
                if (!isUsernameLengthValid) // Display the error message
                  Text(
                    "Username must be between 3-30 characters.",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                Text(
                  "Don't worry, you can change your username anytime.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                RippleButton(
                  splashColor: Colors.transparent,
                  child: Container(
                      height: 70,
                      width: MediaQuery.of(context).size.width - 40,
                      decoration: BoxDecoration(
                        color: _usernameController.text.isNotEmpty
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
                  onPressed: () async {
                    if (_usernameController.text.isNotEmpty) {
                      if (_usernameController.text.length < 3 ||
                          _usernameController.text.length > 30) {
                        setState(() {
                          isUsernameLengthValid = false;
                        });
                        return;
                      }
                      bool exists =
                          await checkIfUsernameExists(_usernameController.text);
                      if (exists) {
                        setState(() {
                          isUsernameTaken = true;
                          errorMessage = 'This username is already taken';
                        });
                      } else {
                        HapticFeedback.heavyImpact();
                        print(
                            "Username from UsernamePage: ${_usernameController.text}");
                        Navigator.push(
                          context,
                          AwesomePageRoute(
                            transitionDuration:
                                const Duration(milliseconds: 600),
                            exitPage: widget,
                            enterPage: BirthPage(
                              name: widget.name,
                              username: '@' +
                                  _usernameController.text, // Add "@" here
                            ),
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
