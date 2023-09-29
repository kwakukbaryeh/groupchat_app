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
import 'package:groupchat_firebase/pages/auth/name.dart';
import 'package:groupchat_firebase/state/appState.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
  StreamSubscription<User?>? authStateSubscription;

  AuthState() {
    authStateListener();
  }

  void authStateListener() {
    authStateSubscription =
        _firebaseAuth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is signed out
        authStatus = AuthStatus.NOT_LOGGED_IN;
        userId = '';
        _userModel = null;
        this.user = null;
        if (_profileQuery != null) {
          _profileQuery!.onValue.drain();
        }
        _profileQuery = null;
        notifyListeners();
      } else {
        // User is signed in
        this.user = user;
        userId = user.uid;
        authStatus = AuthStatus.LOGGED_IN;
        getProfileUser();
        notifyListeners();
      }
    });
  }

  void logoutCallback(BuildContext context) async {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    _userModel = null;
    user = null;
    if (_profileQuery != null) {
      _profileQuery!.onValue.drain();
    }
    _profileQuery = null;
    await _firebaseAuth.signOut();
    notifyListeners();
    await getIt<SharedPreferenceHelper>().clearPreferenceValues();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NamePage()),
    );
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

  Future<UserCredential?> signInWithGoogle(
      {required String displayName,
      required String birthdate,
      required String username}) async {
    print("signInWithGoogle called"); // Debugging line
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.additionalUserInfo!.isNewUser) {
        String fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
        print("Username before creating user: $username"); // Debugging line
        createUser(
          UserModel(
            userId: userCredential.user!.uid,
            key: userCredential.user!.uid,
            fcmToken: fcmToken,
            displayName: displayName,
            birthdate: birthdate,
            email: userCredential.user!.email,
            profilePic: userCredential.user!.photoURL,
            userName: username, // Use the username parameter here
          ),
          newUser: true,
        );
      }

      return userCredential;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<UserCredential?> signInWithApple(
      {required String displayName,
      required String birthdate,
      required String username}) async {
    print("signInWithApple called"); // Debugging line
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(
        OAuthProvider("apple.com").credential(
          idToken: credential.identityToken,
          accessToken: credential.authorizationCode,
        ),
      );

      if (userCredential.additionalUserInfo!.isNewUser) {
        String fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
        print("Username before creating user: $username"); // Debugging line
        createUser(
          UserModel(
            userId: userCredential.user!.uid,
            key: userCredential.user!.uid,
            fcmToken: fcmToken,
            displayName: displayName,
            birthdate: birthdate,
            email: userCredential.user!.email,
            profilePic: userCredential.user!.photoURL,
            userName: username, // Use the username parameter here
          ),
          newUser: true,
        );
      }

      return userCredential;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void createUser(UserModel? user, {bool newUser = false}) {
    print("Creating user with username: ${user?.userName}");
    if (user == null) {
      print("UserModel is null. Cannot create user.");
      return;
    }

    try {
      if (user.userId == null) {
        print("UserId is null. Cannot write to database.");
        return;
      }

      print('Creating user: ${user.toJson()}'); // Debugging line

      kDatabase
          .child('profile')
          .child(user.userId!)
          .set(user.toJson())
          .then((_) {
        print('User created in database'); // Debugging line
      }).catchError((error) {
        print('Error writing to database: $error'); // Debugging line
      });

      _userModel = user;
    } catch (error) {
      print('Error creating user: $error'); // Debugging line
    } finally {
      isBusy = false;
    }
  }

  void updateUsername(String newUsername) async {
    print("Updating username to: $newUsername");
    try {
      if (user?.uid != null && kDatabase != null) {
        await kDatabase.child('profile').child(user!.uid).update({
          'userName': newUsername,
        });
        if (_userModel != null) {
          _userModel!.userName = newUsername;
        }
        notifyListeners();
      } else {
        print("User or Database is null");
      }
    } catch (error) {
      print('Error updating username: $error');
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

  void checkUserExistence(BuildContext context) {
    _firebaseAuth.currentUser?.reload().then((_) {
      User? refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser == null) {
        // User has been deleted, sign them out
        logoutCallback(context);
      }
    }).catchError((error) {
      // Handle error, for example, by logging out the user
      logoutCallback(context);
    });
  }

  Future<void> updateBirthdate(DateTime birthdate) async {
    try {
      await kDatabase.child('profile').child(user!.uid).update({
        'birthdate': birthdate.toIso8601String(),
      });
      _userModel!.birthdate = birthdate.toIso8601String();
      ;
      notifyListeners();
    } catch (error) {
      print('Error updating birthdate: $error');
    }
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

  void dispose() {
    authStateSubscription?.cancel();
  }
}
