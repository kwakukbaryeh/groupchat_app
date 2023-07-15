import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'App Title',
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFAFAFA)),
            ),
            SizedBox(height: 30), // You can adjust this value as needed
            CircularProgressIndicator(), // This is the loading spinner
          ],
        ),
      ),
    );
  }
}
