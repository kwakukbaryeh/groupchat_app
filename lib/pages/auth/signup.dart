import 'dart:io';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/animation/animation.dart';
import 'package:groupchat_firebase/permission/contact.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  final VoidCallback? loginCallback;
  final String? name;
  final String? username;
  final String? birth;
  final File? file;

  const Signup(
      {Key? key,
      this.loginCallback,
      this.name,
      this.username,
      this.birth,
      this.file})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _body(BuildContext context) {
    return Center(
      // Wrap with Center widget
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        children: [
          _submitButton(context),
        ],
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    print("In _submitButton: Username is ${widget.username}");
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _customSignInButton(
          context,
          "assets/images/google_logo.png",
          "Sign in",
          Colors.black,
          Colors.white,
          () async {
            var state = Provider.of<AuthState>(context, listen: false);

            var user = await state.signInWithGoogle(
              displayName: widget.name ?? '',
              birthdate: widget.birth ?? '',
              username: widget.username ?? '',
            );
            print(
                "Before calling signInWithGoogle: Username is ${widget.username}");
            if (user != null) {
              await state.getCurrentUser();
              Navigator.push(
                context,
                AwesomePageRoute(
                  transitionDuration: const Duration(milliseconds: 600),
                  exitPage: widget,
                  enterPage: ContactPage(),
                  transition: CubeTransition(),
                ),
              );
            }
          },
        ),
        SizedBox(width: 10),
        _customSignInButton(
          context,
          "assets/images/apple_logo.png",
          "Sign in",
          Colors.black,
          Colors.white,
          () async {
            var state = Provider.of<AuthState>(context, listen: false);

            var user = await state.signInWithApple(
              displayName: widget.name ?? '',
              birthdate: widget.birth ?? '',
              username: widget.username ?? '',
            );
            print(
                "Before calling signInWithApple: Username is ${widget.username}");
            if (user != null) {
              await state.getCurrentUser();
              Navigator.push(
                context,
                AwesomePageRoute(
                  transitionDuration: const Duration(milliseconds: 600),
                  exitPage: widget,
                  enterPage: ContactPage(),
                  transition: CubeTransition(),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _customSignInButton(
    BuildContext context,
    String imagePath,
    String text,
    Color textColor,
    Color buttonColor,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 50, // Smaller height
      width: 130,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Smaller corner radius
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // To make the button smaller
          children: [
            Container(
              height: 30, // Smaller height
              width: 30, // Smaller width
              color: Colors.white, // White background
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 10), // Smaller space
            Text(
              text,
              style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold), // Added fontWeight: FontWeight.bold
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        title: Image.asset(
          "assets/rebeals.png",
          height: 50,
        ),
        backgroundColor: Colors.black,
      ),
      body: _body(
          context), // Removed SingleChildScrollView as it's not necessary if you want the buttons to always be in the center
    );
  }
}
