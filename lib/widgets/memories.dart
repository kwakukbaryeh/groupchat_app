import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/state/groupchatState.dart';
import 'package:groupchat_firebase/widgets/feedpost.dart';
import 'package:provider/provider.dart';

class MemoriesPage extends StatefulWidget {
  @override
  _MemoriesPageState createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  DateTime selectedDate = DateTime.now();
  String? selectedGroup;
  List<Map<String, dynamic>> posts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),
        title: FadeInRight(
          duration: const Duration(milliseconds: 300),
          child: const Text(
            "Memories",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Display calendar here
          // When a date is selected, set `selectedDate` and call `fetchPosts`
          ElevatedButton(
            onPressed: () async {
              try {
                if (selectedGroup == null) {
                  print("selectedGroup is null");
                  return;
                }
                var groupChatState =
                    Provider.of<GroupChatState>(context, listen: false);
                posts = await groupChatState.fetchPostsByDateAndGroup(
                    selectedDate, selectedGroup!);
                if (posts.isEmpty) {
                  print("No posts found");
                } else {
                  print("Fetched ${posts.length} posts");
                }
                setState(() {});
              } catch (e) {
                print("An error occurred: $e");
              }
            },
            child: Text("Fetch Posts"),
          ),

          // Display dropdown to select group chat
          // When a group chat is selected, set `selectedGroup`
          DropdownButton<String>(
            value: selectedGroup,
            items: Provider.of<GroupChatState>(context)
                .groupChats
                ?.map((groupChat) {
              return DropdownMenuItem<String>(
                value: groupChat.key,
                child: Text(groupChat.groupName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedGroup = value;
              });
            },
          ),
          // Display posts for `selectedGroup`
          Expanded(
            // <-- Wrap ListView in Expanded
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                // Convert the Map to a PostModel
                // Note: This is a simplified example; you may need to adjust this based on your actual PostModel structure
                PostModel postModel = PostModel.fromJson(posts[index]);

                // Use FeedPostWidget to display the post
                return FeedPostWidget(
                  postModel: postModel,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
