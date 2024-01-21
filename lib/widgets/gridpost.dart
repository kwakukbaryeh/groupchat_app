import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/pages/comments.dart';

class GridPostWidget extends StatefulWidget {
  PostModel postModel;
  GridPostWidget({required this.postModel, super.key});

  @override
  State<GridPostWidget> createState() => _GridPostWidgetState();
}

class _GridPostWidgetState extends State<GridPostWidget> {
  bool switcher = false;
  void switcherFunc() {
    setState(() {
      switcher = !switcher;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Rendering GridPostWidget: ${widget.postModel.key}");
    DateTime now = DateTime.now();
    DateTime? createdAt;

    if (widget.postModel.createdAt.isNotEmpty) {
      createdAt = DateTime.parse(widget.postModel.createdAt);
    }
    String? timeAgo;
    if (createdAt != null) {
      Duration difference = now.difference(createdAt);

      if (difference.inSeconds < 60) {
        timeAgo = 'A few seconds ago';
      } else if (difference.inMinutes < 60) {
        int minutes = difference.inMinutes;
        timeAgo = '$minutes minute${minutes > 1 ? 's' : ''} ago';
      } else {
        int hours = difference.inHours;
        timeAgo = 'A few $hours hours${hours > 1 ? 's' : ''} ago';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CommentScreen(widget.postModel),
        ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Main Image (Back Facing Camera Image)
            CachedNetworkImage(
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.63,
              imageUrl: widget.postModel.imageBackPath.toString(),
            ),
            // Selfie Image (Front Facing Camera Image)
            Positioned(
              top: 5,
              left: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.height / 12,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: widget.postModel.imageFrontPath.toString(),
                  ),
                ),
              ),
            ),
            // Username and TimeAgo
            Positioned(
              bottom: 10,
              left: 10,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "${widget.postModel.user!.displayName}\n",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: timeAgo,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
