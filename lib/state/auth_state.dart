import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as db;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/common/locator.dart';
import 'package:groupchat_firebase/helper/enum.dart';
import 'package:groupchat_firebase/helper/shared_preference_helper.dart';
import 'package:groupchat_firebase/helper/utility.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/state/appState.dart';
import 'package:path/path.dart' as path;

class AuthState extends AppStates {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  bool isSignInWithGoogle = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  db.Query? _profileQuery;

  late String userId;
  User? user;
  UserModel? _userModel;

  UserModel? get userModel => _userModel;
  UserModel? get profileUserModel => _userModel;

  void logoutCallback() async {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    _userModel = null;
    user = null;
    _profileQuery!.onValue.drain();
    _profileQuery = null;
    _firebaseAuth.signOut();
    notifyListeners();
    await getIt<SharedPreferenceHelper>().clearPreferenceValues();
  }

  void databaseInit() {
    try {
      if (_profileQuery == null) {
        _profileQuery = kDatabase.child("profile").child(user!.uid);
        _profileQuery!.onValue.listen(_onProfileChanged);
        _profileQuery!.onChildChanged.listen(_onProfileUpdated);
      }
    } catch (error) {}
  }

  Future<String?> signIn(String email, String password, BuildContext context,
      {required GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      isBusy = true;
      var result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      userId = user!.uid;
      return user!.uid;
    } on FirebaseException catch (error) {
      if (error.code == 'Email Adress Not found') {
        Utility.customSnackBar(scaffoldKey, 'User not found', context);
      } else {
        Utility.customSnackBar(
            scaffoldKey, error.message ?? 'Something went wrong', context);
      }
      return null;
    } catch (error) {
      Utility.customSnackBar(scaffoldKey, error.toString(), context);

      return null;
    } finally {
      isBusy = false;
    }
  }

  Future<String?> signUp(UserModel userModel, BuildContext context,
      {required GlobalKey<ScaffoldState> scaffoldKey,
      required String password}) async {
    try {
      isBusy = true;
      var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email!,
        password: password,
      );
      user = result.user;
      authStatus = AuthStatus.LOGGED_IN;
      kAnalytics.logSignUp(signUpMethod: 'register');
      result.user!.updateDisplayName(
        userModel.displayName,
      );
      result.user!.updatePhotoURL(userModel.profilePic);

      _userModel = userModel; //contains email and displayname here
      _userModel!.key = user!.uid;
      _userModel!.userId = user!.uid;
      _userModel!.fcmToken = await FirebaseMessaging.instance.getToken();
      createUser(_userModel!, newUser: true);
      return user!.uid;
    } catch (error) {
      isBusy = false;
      Utility.customSnackBar(scaffoldKey, error.toString(), context);
      return null;
    }
  }

  void createUser(UserModel user, {bool newUser = false}) {
    try {
      if (newUser) {
        user.userName =
            Utility.getUserName(id: user.userId!, name: user.displayName!);
        kAnalytics.logEvent(name: 'create_newUser');
      }
      kDatabase
          .child('profile')
          .child(user.userId!)
          .set(user.toJson())
          .then((_) {
        print('User created in database');
      }).catchError((error) {
        print('Error writing to database: $error');
      });
      _userModel = user;
    } catch (error) {
      print('Error creating user: $error');
    } finally {
      isBusy = false;
    }
  }

  Future<User?> getCurrentUser() async {
    log("currentUser");
    try {
      isBusy = true;
      user = _firebaseAuth.currentUser;
      if (user != null) {
        userId = user!.uid;
        print('User ID: $userId'); // Add this line for debugging
        log(userId);
        await getProfileUser(); // Fetch profile user data
        authStatus = AuthStatus.LOGGED_IN;
      } else {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      }
      isBusy = false;
      return user;
    } catch (error) {
      isBusy = false;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      return null;
    }
  }

  Future<void> updateUserProfile(UserModel? userModel,
      {File? image, File? bannerImage}) async {
    try {
      if (image == null && bannerImage == null) {
        createUser(userModel!);
      } else {
        if (image != null) {
          userModel!.profilePic = await _uploadFileToStorage(image,
              'user/profile/${userModel.userName}/${path.basename(image.path)}');
          var name = userModel.displayName ?? user!.displayName;
          _firebaseAuth.currentUser!.updateDisplayName(name);
          _firebaseAuth.currentUser!.updatePhotoURL(userModel.profilePic);
        }

        if (userModel != null) {
          createUser(userModel);
        } else {
          createUser(_userModel!);
        }
      }
    } catch (error) {}
  }

  Future<String> _uploadFileToStorage(File file, path) async {
    var task = _firebaseStorage.ref().child(path);
    var status = await task.putFile(file);

    return await task.getDownloadURL();
  }

  Future<UserModel?> getUserDetail(String userId) async {
    UserModel user;
    var event = await kDatabase.child('profile').child(userId).once();

    final map = event.snapshot.value as Map?;
    if (map != null) {
      user = UserModel.fromJson(map);
      user.key = event.snapshot.key!;
      return user;
    } else {
      return null;
    }
  }

  FutureOr<void> getProfileUser({String? userProfileId}) {
    try {
      userProfileId = userProfileId ?? user!.uid;
      print(
          'Fetching profile user data for ID: $userProfileId'); // Add this line for debugging
      kDatabase
          .child("profile")
          .child(userProfileId)
          .once()
          .then((DatabaseEvent event) async {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          var map = snapshot.value as Map<dynamic, dynamic>?;
          print('Profile user data: $map'); // Add this line for debugging
          if (map != null) {
            if (userProfileId == user!.uid) {
              log("getprofileuser");
              _userModel = UserModel.fromJson(map);
              getIt<SharedPreferenceHelper>().saveUserProfile(_userModel!);
            }
          }
        }
        isBusy = false;
      });
    } catch (error) {
      isBusy = false;
    }
  }

  void _onProfileChanged(DatabaseEvent event) {
    final val = event.snapshot.value;
    if (val is Map) {
      final updatedUser = UserModel.fromJson(val);
      _userModel = updatedUser;
      getIt<SharedPreferenceHelper>().saveUserProfile(_userModel!);
      notifyListeners();
    }
  }

  void _onProfileUpdated(DatabaseEvent event) {
    final val = event.snapshot.value;
    if (val is List &&
        ['following', 'followers'].contains(event.snapshot.key)) {
      final list = val.cast<String>().map((e) => e).toList();
      if (event.previousChildKey == 'following') {
        _userModel = _userModel!.copyWith(
          followingList: val.cast<String>().map((e) => e).toList(),
        );
      } else if (event.previousChildKey == 'followers') {
        _userModel = _userModel!.copyWith(
          followersList: list,
        );
      }
      getIt<SharedPreferenceHelper>().saveUserProfile(_userModel!);
      notifyListeners();
    }
  }
}
