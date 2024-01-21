import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:groupchat_firebase/common/locator.dart';
import 'package:groupchat_firebase/common/splash.dart';
import 'package:groupchat_firebase/models/groupchat.dart';
import 'package:groupchat_firebase/pages/group_screen.dart';
import 'package:groupchat_firebase/pages/homepage.dart';
import 'package:groupchat_firebase/state/appState.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/state/groupchatState.dart';
import 'package:groupchat_firebase/state/post_state.dart';
import 'package:groupchat_firebase/state/search_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<CameraDescription> cameras = [];

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const InitializationSettings initializationSettings = InitializationSettings(
  android: AndroidInitializationSettings(
      '@mipmap/ic_launcher'), // <- Default icon of your app
  iOS: DarwinInitializationSettings(),
);

Future<void> requestContactPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.contacts,
  ].request();
  print(statuses[Permission.contacts]);
}

void setupFirebaseMessaging() {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        'Received a message while in the foreground: ${message.notification?.body}');
    print(message.notification?.title);
    print(message.notification?.body);

    // Show a local notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert:
          true, // Required to display notification when app is in the foreground
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  });

  // App is in the background and the user taps on the notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print(
        'Tapped on a notification to open the app: ${message.notification?.body}');

    final groupChatId = message.data['groupChatId'];

    if (groupChatId != null) {
      GroupChat? fetchedGroupChat = Provider.of<GroupChatState>(
              navigatorKey.currentContext!,
              listen: false)
          .getGroupChatByKey(groupChatId);
      if (fetchedGroupChat != null) {
        navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
            builder: (context) => GroupScreen(groupChat: fetchedGroupChat)));
      } else {
        // Handle the scenario where the group chat couldn't be fetched
        navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      }
    } else {
      // Fallback to the homepage
      navigatorKey.currentState!
          .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    }
  });

  // App is terminated and the user taps on the notification
  _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      final groupChatId = message.data['groupChatId'];
      if (groupChatId != null) {
        GroupChat? fetchedGroupChat = Provider.of<GroupChatState>(
                navigatorKey.currentContext!,
                listen: false)
            .getGroupChatByKey(groupChatId);
        if (fetchedGroupChat != null) {
          navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
              builder: (context) => GroupScreen(groupChat: fetchedGroupChat)));
        } else {
          // Handle the scenario where the group chat couldn't be fetched
          navigatorKey.currentState!.pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()));
        }
      } else {
        // Fallback to the homepage
        navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      }
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request contact permissions
  await requestContactPermissions();

  setupDependencies();
  final sharedPreferences = await SharedPreferences.getInstance();

  setupFirebaseMessaging(); // Add this line

  runApp(MyApp(sharedPreferences: sharedPreferences));
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
        ChangeNotifierProvider<GroupChatState>(create: (_) => GroupChatState()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(brightness: Brightness.dark),
        title: 'keepUp.',
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
