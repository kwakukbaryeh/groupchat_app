import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/groupdata.dart';
import 'package:groupchat_firebase/widgets/group_carousel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class GroupGridPage extends StatefulWidget {
  final DateTime selectedDate;

  GroupGridPage({required this.selectedDate});

  @override
  _GroupGridPageState createState() => _GroupGridPageState();
}

class _GroupGridPageState extends State<GroupGridPage> {
  late Future<List<GroupData>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = getGroupsForDate(widget.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Grid"),
        backgroundColor:
            Colors.black, // AppBar background color to match the page
        elevation: 0, // Remove shadow for a seamless appearance
      ),
      body: FutureBuilder<List<GroupData>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              print('Error fetching groups: ${snapshot.error}');
              return Center(child: Text('Error loading data.'));
            }

            final List<GroupData>? groups = snapshot.data;

            if (groups != null && groups.isNotEmpty) {
              print('List of Groups: $groups');
              return buildGroupGrid(context, groups);
            } else {
              return Center(
                child: Text('No memories on this date.'),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget buildGroupGrid(BuildContext context, List<GroupData> groups) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two columns
        crossAxisSpacing: 4, // Spacing between columns
        mainAxisSpacing: 4, // Spacing between rows
      ),
      itemCount: min(4, groups.length), // Show up to 4 groups only
      itemBuilder: (context, index) {
        GroupData group = groups[index];
        return buildGroupItem(context, group);
      },
    );
  }

  Widget buildGroupItem(BuildContext context, GroupData group) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupCarouselPage(group: group),
          ),
        );
      },
      child: FutureBuilder<Map<String, dynamic>>(
        future: getRandomFeedPostPreview(group),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final previewData = snapshot.data!;
              final String? backImageUrl = previewData['imageBackPath'];
              final String? frontImageUrl = previewData['imageFrontPath'];

              if (backImageUrl != null) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: backImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    if (frontImageUrl != null)
                      Positioned(
                        left: 8, // Adjust the position to the top left
                        top: 8,
                        child: Image.network(
                          frontImageUrl,
                          width: 50, // Adjust the size as needed
                          height: 50,
                        ),
                      ),
                    Container(
                      alignment: Alignment.center,
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        group.groupName,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                );
              } else {
                // Handle the case where the back image URL is null
                return _buildPlaceholderGroupItem(group);
              }
            } else {
              // Handle the case where snapshot doesn't have data
              return _buildPlaceholderGroupItem(group);
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _buildPlaceholderGroupItem(GroupData group) {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey,
      child: Text(
        group.groupName,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<List<GroupData>> getGroupsForDate(DateTime date) async {
    Set<String> uniqueGroupIds = {};
    List<GroupData> selectedDateGroups = [];
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      DatabaseReference historyRef =
          FirebaseDatabase.instance.reference().child('history_posts');
      DatabaseEvent event = await historyRef
          .orderByChild('createdAt')
          .startAt(formattedDate)
          .endAt(formattedDate + "\uf8ff")
          .once();

      final dynamic snapshotValue = event.snapshot.value;

      if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> postsData = snapshotValue;
        postsData.forEach((postId, postData) {
          if (postData is Map<dynamic, dynamic> &&
              postData.containsKey('groupChat')) {
            Map groupChatData = postData['groupChat'];
            String groupId = groupChatData['key'];
            if (uniqueGroupIds.add(groupId)) {
              // Only add if the groupId is not already in the set
              GroupData group = GroupData(
                groupId: groupId,
                groupName: groupChatData['groupName'],
                groupImage: postData['imageBackPath'] ?? '',
              );
              selectedDateGroups.add(group);
            }
          }
        });
      }
    } catch (e) {
      print('Error fetching groups: $e');
    }
    return selectedDateGroups;
  }

  Future<Map<String, dynamic>> getRandomFeedPostPreview(GroupData group) async {
    try {
      DatabaseReference historyRef =
          FirebaseDatabase.instance.reference().child('history_posts');
      DatabaseEvent event = await historyRef
          .orderByChild('groupChat/key')
          .equalTo(group.groupId)
          .once();

      final dynamic snapshotValue = event.snapshot.value;

      if (snapshotValue != null && snapshotValue is Map) {
        // Convert each key and value in the map to a String key and dynamic value
        var postsData = snapshotValue.map((key, value) {
          // Ensure the key is a string
          var stringKey = key.toString();
          // Ensure the value is a Map with String keys before casting
          if (value is Map) {
            var stringDynamicValue = Map<String, dynamic>.from(value);
            return MapEntry(stringKey, stringDynamicValue);
          } else {
            // If the value is not a Map, return it as is
            return MapEntry(stringKey, value);
          }
        });

        List postList = postsData.values.toList();

        if (postList.isNotEmpty) {
          // Randomly select a post from the list
          Map<String, dynamic> randomPost =
              postList[Random().nextInt(postList.length)];
          return randomPost;
        }
      }
    } catch (e) {
      print('Error fetching feed posts: $e');
    }

    // Return a default map if no suitable post is found
    return {
      'backgroundImageUrl':
          'URL_of_a_valid_default_image', // Provide a valid URL
      'caption': '',
      'createdAt': '',
    };
  }
}
