// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_tile_page.dart'; // this was list from reBeal

class UserTileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this with your actual user data
    UserModel user = UserModel(
      displayName: 'John Doe',
      userName: 'johndoe',
      profilePic: 'https://example.com/profile.jpg',
    );

    // Replace this with your actual logic to determine if the user is added
    bool isAdded = false;

    return UserTilePage(user: user, isadded: isAdded);
  }
}
