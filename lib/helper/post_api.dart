import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostApi {
  // Example method to fetch posts from Firestore
  Future<List<PostModel>> fetchPosts() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('posts').get();

    final List<PostModel> posts =
        snapshot.docs.map((doc) => PostModel.fromJson(doc.data())).toList();

    return posts;
  }
}
