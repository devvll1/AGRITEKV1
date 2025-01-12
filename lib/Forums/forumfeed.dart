// ignore_for_file: prefer_const_constructors

import 'package:agritek/Forums/newpost.dart';
import 'package:agritek/Forums/viewpost.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ForumsPage extends StatefulWidget {
  const ForumsPage({Key? key}) : super(key: key);

  @override
  _ForumsPageState createState() => _ForumsPageState();
}

class _ForumsPageState extends State<ForumsPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final Map<String, String> _userCache = {};

  Future<String> _getFullName(String? userId) async {
    if (userId == null) return 'Anonymous';

    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final firstName = data?['firstName'] ?? '';
        final lastName = data?['lastName'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        _userCache[userId] = fullName;
        return fullName.isNotEmpty ? fullName : 'Anonymous';
      }
    } catch (e) {}

    return 'Anonymous';
  }

  Future<void> _togglePostLike(String postId, List<dynamic> currentLikes) async {
    final userId = user?.uid;
    if (userId == null) return;

    final postDoc = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (currentLikes.contains(userId)) {
      await postDoc.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await postDoc.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Forums')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final postData = post.data() as Map<String, dynamic>;
              final postTimestamp = postData['timestamp'] as Timestamp?;
              final postTime = postTimestamp != null
                  ? DateFormat('MMM d, y h:mm a').format(postTimestamp.toDate())
                  : '';
              final postLikes = postData['likes'] ?? [];

              return FutureBuilder<String>(
                future: _getFullName(postData['author']),
                builder: (context, snapshot) {
                  final authorName = snapshot.data ?? 'Anonymous';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ViewPostPage(
                            postId: post.id,
                            title: postData['title'] ?? '',
                            content: postData['content'] ?? '',
                            category: postData['category'] ?? '',
                            author: authorName,
                            time: postTime,
                            likes: postLikes,
                            imageUrl: '', 
                            comments: [],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (postData['imageUrl'] != null &&
                                postData['imageUrl'].isNotEmpty)
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(postData['imageUrl'] ?? ''),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            SizedBox(height: 8),
                            Text('Author: $authorName',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Posted on: $postTime',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            if (postData['category'] != null)
                              Text('Category: ${postData['category']}',
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                      color: Colors.grey)),
                            Divider(color: Colors.grey.shade400, thickness: 1),
                            Text(postData['title'] ?? 'No Title',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            SizedBox(height: 4),
                            Text(
                              postData['content'] ?? 'No Content Available',
                              style: const TextStyle(fontSize: 14),
                              maxLines: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Divider(color: Colors.grey.shade400, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        postLikes.contains(user?.uid)
                                            ? CupertinoIcons.hand_thumbsup_fill
                                            : CupertinoIcons.hand_thumbsup,
                                        color: postLikes.contains(user?.uid)
                                            ? CupertinoColors.activeBlue
                                            : CupertinoColors.inactiveGray,
                                      ),
                                      onPressed: () =>
                                          _togglePostLike(post.id, postLikes),
                                    ),
                                    Text('${postLikes.length} Likes'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.chat_bubble_text,
                                      color: CupertinoColors.inactiveGray,
                                    ),
                                    SizedBox(width: 4),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(post.id)
                                            .collection('comments')
                                            .snapshots(),
                                        builder: (context, commentSnapshot) {

                                          final commentCount = commentSnapshot.data?.docs.length ?? 0;

                                          return Text(
                                            '$commentCount Comments',
                                            style: const TextStyle(fontSize: 13),
                                          );
                                        },
                                      ),

                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: CupertinoColors.activeBlue,
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(CupertinoIcons.add, color: CupertinoColors.white),
            SizedBox(width: 5),
            Text('New Post', style: TextStyle(color: CupertinoColors.white)),
          ],
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const NewPostPage(),
            ),
          );

          if (result != null && result == 'Post Added') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New post added!')),
            );
          }
        },
      ),
    );
  }
}
