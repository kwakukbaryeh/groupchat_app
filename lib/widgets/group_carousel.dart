import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/groupdata.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/widgets/feedpost.dart';
import 'package:carousel_slider/carousel_slider.dart';

class GroupCarouselPage extends StatefulWidget {
  final GroupData group;

  GroupCarouselPage({required this.group});

  @override
  _GroupCarouselPageState createState() => _GroupCarouselPageState();
}

class _GroupCarouselPageState extends State<GroupCarouselPage> {
  List<PostModel> feedPosts = [];
  int _currentCarouselIndex =
      0; // State variable to keep track of the current carousel index

  @override
  void initState() {
    super.initState();
    getAllFeedPostsForGroup(widget.group);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.groupName),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: feedPosts.isNotEmpty
          ? CarouselSlider.builder(
              itemCount: feedPosts.length,
              itemBuilder: (context, index, realIndex) {
                final bool isCurrentItem = index == _currentCarouselIndex;
                final double scaleFactor = isCurrentItem ? 1 : 0.85;
                PostModel feedPost = feedPosts[index];
                return Transform.scale(
                  scale: scaleFactor,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Adjust width if needed
                    height: MediaQuery.of(context).size.height *
                        0.5, // Adjust height if needed
                    child: Material(
                      elevation: isCurrentItem ? 10.0 : 5.0,
                      borderRadius: BorderRadius.circular(12.0),
                      child: FeedPostWidget(
                        postModel: feedPost,
                        scaleFactor: scaleFactor,
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.75,
                enableInfiniteScroll: false, // Disable infinite scroll
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
                scrollDirection: Axis.horizontal,
              ),
            )
          : Center(child: CircularProgressIndicator()),
      backgroundColor: Colors.black,
    );
  }

  void getAllFeedPostsForGroup(GroupData group) {
    DatabaseReference historyRef =
        FirebaseDatabase.instance.reference().child('history_posts');
    historyRef
        .orderByChild('groupChat/key')
        .equalTo(group.groupId)
        .once()
        .then((DatabaseEvent event) {
      final dynamic snapshotValue = event.snapshot.value;

      // Debug print the entire snapshot value
      print('Snapshot Value: $snapshotValue');

      if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
        // Initialize postsData from snapshotValue
        var postsData = Map<String, dynamic>.from(snapshotValue);
        List<PostModel> tempFeedPosts = [];

        // Indicate iteration start
        print('Iterating through posts...');

        // Process each post
        postsData.forEach((key, postData) {
          print('Processing key: $key'); // Print the key being processed
          if (postData is Map) {
            PostModel postModel =
                PostModel.fromJson(Map<String, dynamic>.from(postData));
            print('Added post from key: $key'); // Print after adding post
            tempFeedPosts.add(postModel); // Add the post to the temporary list
          } else {
            print(
                'Post data for key $key is not a Map: $postData'); // Print if data is not a Map
          }
        });

        // Print the fetched posts count
        print('Fetched ${tempFeedPosts.length} posts');

        // Update the UI with the new list of posts
        setState(() {
          feedPosts = tempFeedPosts;
          // Print the updated posts count
          print('Feed posts updated: ${feedPosts.length}');
        });
      } else {
        // Print if no data is found for the group ID
        print('No data found for group ID: ${group.groupId}');
      }
    }).catchError((error) {
      // Print if there is an error fetching posts
      print('Error fetching posts: $error');
    });
  }
}
