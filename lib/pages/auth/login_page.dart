/*
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_signin_button/flutter_signin_button.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:groupchat_firebase/services/user.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
// import '../../helper/helper_function.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? verificationId;

  @override
  void dispose() {
    phoneNumberController.dispose();
    nameController.dispose();
    birthdateController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 150),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Text("Sign in to App Title",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              primary: Colors.white,
                              onPrimary: Colors.black,
                            ),
                            onPressed: () {
                              // Implement your sign in with Google logic here
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset('assets/images/google_logo.png',
                                    height: 12.0),
                                const SizedBox(width: 10),
                                const Text('Sign in with Google'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              primary: Colors.black,
                              onPrimary: Colors.white,
                            ),
                            onPressed: () {
                              // Implement your sign in with Apple logic here
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset('assets/images/apple_logo.png',
                                    height: 12.0),
                                const SizedBox(width: 10),
                                const Text('Sign in with Apple'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: phoneNumberController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Sign in with your phone number',
                              hintStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _showUserInfoDialog,
                            style: ElevatedButton.styleFrom(
                              primary: const Color(0xFFFAFAFA),
                              onPrimary: Colors.black,
                            ),
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showUserInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('User Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: birthdateController,
                decoration: InputDecoration(labelText: 'Birthdate'),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Next'),
              onPressed: () {
                Navigator.pop(context);
                _submitForm();
              },
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (phoneNumberController.text.isEmpty ||
        nameController.text.isEmpty ||
        birthdateController.text.isEmpty ||
        usernameController.text.isEmpty) {
      // Handle case where user information is incomplete
      return;
    }

    AuthState authState = AuthState();

    UserModel user = UserModel(
      phoneNumber: phoneNumberController.text.trim(),
      displayName: nameController.text,
      // Assign other user properties
    );

    authState
        .signUp(
      user,
      context,
      password: '', // No password is needed for phone number sign-up
      scaffoldKey: GlobalKey<ScaffoldState>(), // Use your scaffold key here
    )
        .then((status) {
      print(status);
    }).whenComplete(() {
      Future.delayed(const Duration(seconds: 0)).then((_) {
        authState.getCurrentUser();
        Navigator.pushReplacementNamed(
          context,
          '/home', // Navigate to HomePage
        );
      });
    });
  }
}
*/