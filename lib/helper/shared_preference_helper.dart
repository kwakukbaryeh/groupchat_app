import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SharedPreferenceHelper {
  SharedPreferenceHelper._internal();
  static final SharedPreferenceHelper _singleton =
      SharedPreferenceHelper._internal();

  factory SharedPreferenceHelper() {
    return _singleton;
  }

  Future clearPreferenceValues() async {
    (await SharedPreferences.getInstance()).clear();
  }

  Future<bool> saveUserProfile(UserModel user) async {
    return (await SharedPreferences.getInstance()).setString(
        UserPreferenceKey.UserProfile.toString(), json.encode(user.toJson()));
  }
}

enum UserPreferenceKey { UserProfile }
