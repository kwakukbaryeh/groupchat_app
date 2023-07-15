import 'package:flutter/material.dart';
import 'package:groupchat_firebase/helper/enum.dart';
import 'package:groupchat_firebase/pages/auth/name.dart';
import 'package:groupchat_firebase/pages/homepage.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:groupchat_firebase/state/profile_state.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer();
    });
    super.initState();
  }

  bool isAppUpdated = true;

  void timer() async {
    if (isAppUpdated) {
      Future.delayed(const Duration(seconds: 1)).then((_) {
        var state = Provider.of<AuthState>(context, listen: false);
        state.getCurrentUser();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: state.authStatus == AuthStatus.NOT_LOGGED_IN
          ? const NamePage()
          : MultiProvider(providers: [
              ChangeNotifierProvider<ProfileState>(
                  create: (_) => ProfileState(state.userId)),
            ], child: HomePage()),
    );
  }
}
