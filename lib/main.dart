import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:groupchat_firebase/common/locator.dart';
import 'package:groupchat_firebase/common/splash.dart';
import 'package:groupchat_firebase/helper/helper_function.dart';
import 'package:groupchat_firebase/pages/auth/login_page.dart';
import 'package:groupchat_firebase/pages/homepage.dart';
import 'package:groupchat_firebase/pages/loading_screen.dart';
import 'package:groupchat_firebase/shared/constants.dart';
import 'package:groupchat_firebase/state/appState.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/state/post_state.dart';
import 'package:groupchat_firebase/state/search_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Firebase.initializeApp();
  setupDependencies();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp(
    sharedPreferences: sharedPreferences,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.sharedPreferences}) : super(key: key);
  final SharedPreferences sharedPreferences;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStates>(create: (_) => AppStates()),
        ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
        ChangeNotifierProvider<PostState>(create: (_) => PostState()),
        ChangeNotifierProvider<SearchState>(create: (_) => SearchState()),
      ],
      child: MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          title: 'ReBeal.',
          debugShowCheckedModeBanner: false,
          home: SplashPage()),
    );
  }
}

class AppPage extends StatelessWidget {
  final String title;
  final bool hasHamburgerMenu;
  final bool hasDirectMessageIcon;
  final Widget page;

  const AppPage(
      {Key? key,
      required this.title,
      this.hasHamburgerMenu = false,
      this.hasDirectMessageIcon = false,
      required this.page})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: hasDirectMessageIcon ? Icon(Icons.message) : null,
        actions: hasHamburgerMenu ? [Icon(Icons.menu)] : null,
      ),
      body: page,
    );
  }
}
