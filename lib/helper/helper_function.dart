import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class HelperFunctions {
  // keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userBirthdateKey = "USERBIRTHDATEKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userUsernameKey = "USERUSERNAMEKEY";
  static String groupChatKey = "GROUPCHATKEY";

  // saving the data to SF
  static Future<void> saveUserBirthdate(String userBirthdate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userBirthdateKey, userBirthdate);
  }

  static Future<void> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, userName);
  }

  static Future<void> saveUserUsername(String userUsername) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userUsernameKey, userUsername);
  }

  static Future<void> saveGroupChat(String groupName, int timeRemaining) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> groupChat = {
      'groupName': groupName,
      'timeRemaining': timeRemaining,
    };
    await prefs.setString(groupChatKey, jsonEncode(groupChat));
  }

  static Future<Map<String, dynamic>?> getGroupChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? groupChatJson = prefs.getString(groupChatKey);
    if (groupChatJson != null) {
      return jsonDecode(groupChatJson);
    }
    return null;
  }

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserBirthdate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userBirthdateKey);
  }

  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  static Future<String?> getUserUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userUsernameKey);
  }

  static String formatTimeRemaining(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static Future<void> saveUser(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel.fromJson(userMap);
    }
    return null;
  }
}
