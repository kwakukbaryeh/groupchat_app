import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:groupchat_firebase/animation/animation.dart';
import 'package:groupchat_firebase/permission/contact.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  final VoidCallback? loginCallback;
  final String? name;
  final String? birth;
  final File? file;

  const Signup({Key? key, this.loginCallback, this.name, this.birth, this.file})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _body(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 130,
        ),
        _submitButton(context),
      ],
    );
  }

  Widget _submitButton(BuildContext context) {
    return Column(
      children: [
        SignInButton(
          Buttons.Google,
          onPressed: () async {
            var state = Provider.of<AuthState>(context, listen: false);
            var user = await state.signInWithGoogle();
            if (user != null) {
              // Navigate to next screen
              Navigator.push(
                context,
                AwesomePageRoute(
                  transitionDuration: const Duration(milliseconds: 600),
                  exitPage: widget,
                  enterPage: const ContactPage(),
                  transition: CubeTransition(),
                ),
              );
            }
          },
          text: "Sign in with Google",
        ),
        SignInButton(
          Buttons.Apple,
          onPressed: () async {
            var state = Provider.of<AuthState>(context, listen: false);
            var user = await state.signInWithApple();
            if (user != null) {
              // Navigate to next screen
              Navigator.push(
                context,
                AwesomePageRoute(
                  transitionDuration: const Duration(milliseconds: 600),
                  exitPage: widget,
                  enterPage: const ContactPage(),
                  transition: CubeTransition(),
                ),
              );
            }
          },
          text: "Sign in with Apple",
        ),
      ],
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
          height: 130,
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(child: _body(context)),
    );
  }
}
