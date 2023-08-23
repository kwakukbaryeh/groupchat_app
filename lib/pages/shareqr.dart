import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/groupchat.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareQr extends StatefulWidget {
  ShareQr({required this.groupChat, super.key});
  GroupChat groupChat;

  @override
  State<ShareQr> createState() => _ShareQrState();
}

class _ShareQrState extends State<ShareQr> {
  @override
  Widget build(BuildContext context) {
    AuthState auth = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Share Qr code"),
      ),
      body: Center(
        child: SizedBox(
          width: 250,
          height: 250,
          child: QrImageView(
            data:
                "${auth.userId} ${auth.userModel!.fcmToken} ${widget.groupChat.key}",
            version: QrVersions.auto,
          ),
        ),
      ),
    );
  }
}
