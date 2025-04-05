// ignore_for_file: library_private_types_in_public_api

import 'package:agritek/Forums/viewpost.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfileFeedPage extends StatefulWidget {
  const ProfileFeedPage({super.key});

  @override
  _ProfileFeedPageState createState() => _ProfileFeedPageState();
}

class _ProfileFeedPageState extends State<ProfileFeedPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
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
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
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

                    return GestureDetector(
                      onTap: () {
                        // Navigate to ViewPostPage for detailed view
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
                              likes: postData['likes'] ?? [],
                              imageUrls: postData['imageUrls'] ??
                                  [], // Fixed field name
                              tags: postData['tags'] ?? '', // Added tags
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
                              if (postData['imageUrls'] != null &&
                                  (postData['imageUrls'] as List).isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          (postData['imageUrls'] as List)[0]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
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
                                      color: Colors.grey),
                                ),
                              if (postData['tags'] != null &&
                                  postData['tags'].isNotEmpty)
                                Text(
                                  'Tags: ${postData['tags']}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              const Divider(color: Colors.grey, thickness: 1),
                              Text(
                                postData['title'] ?? 'No Title',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                postData['content'] ?? 'No Content Available',
                                style: const TextStyle(fontSize: 14),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
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
    );
  }
}
