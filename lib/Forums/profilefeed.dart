// ignore_for_file: library_private_types_in_public_api, unused_element

import 'package:agritek/Forums/viewpost.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:agritek/Forums/newpost.dart';
import 'package:flutter/cupertino.dart';

class ProfileFeedPage extends StatefulWidget {
  const ProfileFeedPage({super.key});

  @override
  _ProfileFeedPageState createState() => _ProfileFeedPageState();
}

class _ProfileFeedPageState extends State<ProfileFeedPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final Map<String, String> _userCache = {};

  Future<String> _getFullName(String? userId) async {
    if (userId == null) return 'Anonymous';

    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final firstName = data?['firstName'] ?? '';
        final lastName = data?['lastName'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        _userCache[userId] = fullName;
        return fullName.isNotEmpty ? fullName : 'Anonymous';
      }
    } catch (e) {
      debugPrint('Error fetching full name: $e');
    }

    return 'Anonymous';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        backgroundColor: Colors.green,
      ),
      body: user == null
          ? const Center(
              child: Text('You must be logged in to view your posts.'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('author',
                      isEqualTo: user!.uid) // Filter by current user
                  .orderBy('timestamp', descending: true) // Order by timestamp
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Error: ${snapshot.error}');
                  return Center(
                    child: Text('An error occurred: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs;

                if (posts.isEmpty) {
                  return const Center(child: Text('No posts found.'));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final postData = post.data() as Map<String, dynamic>;
                    final postTimestamp = postData['timestamp'] as Timestamp?;
                    final postTime = postTimestamp != null
                        ? DateFormat('MMM d, y h:mm a')
                            .format(postTimestamp.toDate())
                        : '';
                    final likes = List<String>.from(postData['likes'] ?? []);
                    final commentsCount = postData['commentsCount'] ?? 0;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewPostPage(
                              userId: user!.uid,
                              postId: post.id,
                              title: postData['title'] ?? 'No Title',
                              content: postData['content'] ?? 'No Content',
                              category: postData['category'] ?? 'Uncategorized',
                              author: postData['author'] ?? 'Unknown',
                              time: postTime,
                              likes: likes,
                              imageUrls: List<String>.from(
                                  postData['imageUrls'] ?? []),
                              tags: postData['tags'] ?? '',
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (postData['imageUrls'] != null &&
                                  (postData['imageUrls'] as List).isNotEmpty)
                                _buildImageGrid(postData['imageUrls']),
                              const SizedBox(height: 8),
                              Text(
                                'Posted on: $postTime',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                              if (postData['category'] != null)
                                Text(
                                  'Category: ${postData['category']}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (postData['tags'] != null &&
                                  postData['tags'].isNotEmpty)
                                Text(
                                  'Tags: #${postData['tags']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              const Divider(color: Colors.grey, thickness: 1),
                              Text(
                                postData['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                postData['content'] ?? 'No Content Available',
                                style: const TextStyle(fontSize: 14),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.hand_thumbsup,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${likes.length} Likes'),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    CupertinoIcons.chat_bubble,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('$commentsCount Comments'),
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
            ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewPostPage(),
                  ),
                );
              },
              backgroundColor: Colors.green,
              child: const Icon(CupertinoIcons.add),
            ),
    );
  }

  Widget _buildImageGrid(List<dynamic> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of images per row
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(imageUrls[index]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 50,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
