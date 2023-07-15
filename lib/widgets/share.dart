import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../state/auth_state.dart';
// import 'path/to/auth_state.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({Key? key});

  void shareText(String text) {
    Share.share(
      text,
      subject: "Share on My App",
      sharePositionOrigin: Rect.fromLTWH(0, 0, 10, 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 30, left: 10, right: 10),
          child: GestureDetector(
            onTap: () {
              shareText("Share this content");
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[800],
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            height: 40,
                            width: 40,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              height: 100,
                              imageUrl:
                                  state.profileUserModel!.profilePic.toString(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Invite your friends to My App\n',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text:
                                    'myapp.com/${state.profileUserModel!.userName!.replaceAll("@", "").toLowerCase()}',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 30),
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
