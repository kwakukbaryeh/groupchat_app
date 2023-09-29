import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_sms/flutter_sms.dart';

class ShareButton extends StatefulWidget {
  const ShareButton({super.key});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

void shareText(String text, [String? phoneNumber]) {
  final shareContent =
      phoneNumber != null ? '$text\nSend to: $phoneNumber' : text;

  Share.share(
    shareContent,
    subject: "Add me on keepUp.",
    sharePositionOrigin: const Rect.fromLTWH(0, 0, 10, 10),
  );
}

void _sendSMS(String message, List<String> recipents) async {
  String _result = await sendSMS(message: message, recipients: recipents)
      .catchError((onError) {
    print(onError);
  });
  print(_result);
}

class _ShareButtonState extends State<ShareButton> {
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
            child: GestureDetector(
                onTap: () {
                  shareText(
                      'keepUp/${state.profileUserModel!.userName!.replaceAll("@", "").toLowerCase()}');
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[500],
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        height: 100,
                                        imageUrl: state
                                                .profileUserModel?.profilePic ??
                                            "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg"),
                                  )),
                              Container(
                                width: 10,
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Invite your friends to keepUp\n',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'keepUp/${state.profileUserModel!.userName!.replaceAll("@", "").toLowerCase()}',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 30,
                          ),
                          const Icon(
                            CupertinoIcons.share,
                            color: Colors.white,
                            size: 22,
                          )
                        ],
                      ),
                    )))),
        Container(
          height: 20,
        ),
      ],
    );
  }
}
