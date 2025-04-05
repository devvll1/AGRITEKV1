// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api

import 'package:agritek/Forums/newpost.dart';
import 'package:agritek/Forums/notifications.dart';
import 'package:agritek/Forums/profilefeed.dart';
import 'package:agritek/Forums/viewpost.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ForumsPage extends StatefulWidget {
  const ForumsPage({super.key});

  @override
  _ForumsPageState createState() => _ForumsPageState();
}

class _ForumsPageState extends State<ForumsPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final Map<String, String> _userCache = {};
  final TextEditingController _commentController =
      TextEditingController(); // Added this line
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isSearchFocused = false;

  final List<String> _categories = [
    'All Categories',
    'Crop Farming',
    'Livestock',
    'Aquaculture',
    'Other',
  ];

  @override
  void dispose() {
    _commentController
        .dispose(); // Dispose of the controller to avoid memory leaks
    super.dispose();
  }

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
    } catch (e) {}

    return 'Anonymous';
  }

  Future<String> _getProfileImageUrl(String? userId) async {
    if (userId == null) return '';

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final profileImageUrl = data?['profileImageUrl'] ?? '';
        return profileImageUrl;
      }
    } catch (e) {}

    return '';
  }

  Future<void> _togglePostLike(String postId, List<dynamic> currentLikes,
      String postTitle, String postAuthorId) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like posts.')),
      );
      return;
    }

    final userId = user!.uid;
    final postDoc = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (currentLikes.contains(userId)) {
      await postDoc.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await postDoc.update({
        'likes': FieldValue.arrayUnion([userId]),
      });

      // Add a notification for the post author
      if (postAuthorId != userId) {
        final notificationRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc(postAuthorId)
            .collection('userNotifications')
            .doc();

        await notificationRef.set({
          'type': 'like',
          'postId': postId,
          'postTitle': postTitle,
          'senderId': userId,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    }
  }

  Future<void> _addComment(String comment, String postId, String postTitle,
      String postAuthorId) async {
    if (comment.isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint('User is not logged in');
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('User document does not exist');
        return;
      }

      final userData = userDoc.data()!;
      final firstName = userData['firstName'] ?? 'Unknown';
      final lastName = userData['lastName'] ?? 'User';

      final commentData = {
        'text': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'author': '$firstName $lastName',
        'userId': user.uid,
        'profileImageUrl':
            userData['profileImageUrl'] ?? 'assets/images/defaultprofile.png',
      };

      final postDoc =
          FirebaseFirestore.instance.collection('posts').doc(postId);

      // Add the comment to Firestore
      await postDoc.collection('comments').add(commentData);

      // Add a notification for the post author
      if (postAuthorId != user.uid) {
        final notificationRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc(postAuthorId)
            .collection('userNotifications')
            .doc();

        await notificationRef.set({
          'type': 'comment',
          'postId': postId,
          'postTitle': postTitle,
          'senderId': user.uid,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }

      _commentController.clear(); // Clear the comment input field
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully')),
      );
    } catch (e) {
      debugPrint('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add comment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Community Forums'),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.bell),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsPage(),
                      ),
                    );
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(user?.uid)
                      .collection('userNotifications')
                      .where('isRead', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${snapshot.data!.docs.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                8.0, 16.0, 8.0, 0.0), // Added top padding
            child: Row(
              children: [
                // Profile Button
                FutureBuilder<String>(
                  future: _getProfileImageUrl(
                      user?.uid), // Fetch the profile image URL
                  builder: (context, snapshot) {
                    final profileImageUrl = snapshot.data ??
                        ''; // Default to an empty string if null

                    return GestureDetector(
                      onTap: () {
                        // Navigate to the ProfileFeedPage to show the logged-in user's posts
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileFeedPage(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(
                                profileImageUrl) // Show the fetched profile image
                            : const AssetImage(
                                    'assets/images/defaultprofile.png')
                                as ImageProvider, // Show a default placeholder image
                      ),
                    );
                  },
                ),
                const SizedBox(
                    width: 8), // Space between profile button and search bar
                // Search Bar
                Expanded(
                  flex: 4, // Adjust the flex to control the initial width
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {
                        _isSearchFocused = hasFocus; // Track focus state
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isSearchFocused
                          ? MediaQuery.of(context).size.width * 0.6
                          : MediaQuery.of(context).size.width *
                              0.4, // Expand when focused
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Search',
                          prefixIcon: const Icon(CupertinoIcons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    width: 8), // Space between search bar and dropdown
                // Category Filter
                SizedBox(
                  width: 150, // Fixed width for the dropdown
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(
                        fontSize: 14, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category == 'All Categories' ? null : category,
                        child: Text(
                          category,
                          style: const TextStyle(
                              fontSize: 12), // Reduced font size for items
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    icon: const Icon(
                      CupertinoIcons.chevron_down,
                      size: 16, // Reduced icon size
                    ),
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Posts List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                final posts = snapshot.data!.docs.where((post) {
                  final postData = post.data() as Map<String, dynamic>;
                  final title = postData['title']?.toLowerCase() ?? '';
                  final category = postData['category'] ?? '';

                  // Filter by search query and category
                  final matchesSearch = title.contains(_searchQuery);
                  final matchesCategory = _selectedCategory == null ||
                      category == _selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

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
                    final postLikes = postData['likes'] ?? [];

                    return FutureBuilder<String>(
                      future: _getFullName(postData['author']),
                      builder: (context, snapshot) {
                        final authorName = snapshot.data ?? 'Anonymous';

                        return FutureBuilder<String>(
                          future: _getProfileImageUrl(postData['author']),
                          builder: (context, imageSnapshot) {
                            final authorImageUrl = imageSnapshot.data ?? '';

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
                                      author: postData['author'] ?? '',
                                      time: postTime,
                                      likes: postLikes,
                                      imageUrls: postData['imageUrls'] ??
                                          [], // Corrected field
                                      tags: postData['tags'] ??
                                          '', // Corrected field
                                      userId: user?.uid ?? '',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage: authorImageUrl
                                                    .isNotEmpty
                                                ? NetworkImage(authorImageUrl)
                                                : const AssetImage(
                                                        'assets/images/defaultprofile.png')
                                                    as ImageProvider,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$authorName',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
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
                                            color: Colors.grey,
                                          ),
                                        ),
                                      if (postData['tags'] != null &&
                                          postData['tags'].isNotEmpty)
                                        Text(
                                          'Tags: ${postData['tags']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      const Divider(
                                          color: Colors.grey, thickness: 1),
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
                                        postData['content'] ??
                                            'No Content Available',
                                        style: const TextStyle(fontSize: 14),
                                        maxLines: 12,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Divider(
                                          color: Colors.grey, thickness: 1),
                                      if (postData['imageUrls'] != null &&
                                          postData['imageUrls'].isNotEmpty)
                                        _buildDynamicImageRow(
                                            postData['imageUrls']),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  postLikes.contains(user?.uid)
                                                      ? CupertinoIcons
                                                          .hand_thumbsup_fill
                                                      : CupertinoIcons
                                                          .hand_thumbsup,
                                                  color: postLikes
                                                          .contains(user?.uid)
                                                      ? CupertinoColors
                                                          .activeBlue
                                                      : CupertinoColors
                                                          .inactiveGray,
                                                ),
                                                onPressed: () =>
                                                    _togglePostLike(
                                                        post.id,
                                                        postLikes,
                                                        postData['title'],
                                                        postData['author']),
                                              ),
                                              Text('${postLikes.length} Likes'),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                CupertinoIcons.chat_bubble_text,
                                                color: CupertinoColors
                                                    .inactiveGray,
                                              ),
                                              const SizedBox(width: 4),
                                              StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('posts')
                                                    .doc(post.id)
                                                    .collection('comments')
                                                    .snapshots(),
                                                builder:
                                                    (context, commentSnapshot) {
                                                  final commentCount =
                                                      commentSnapshot.data?.docs
                                                              .length ??
                                                          0;

                                                  return Text(
                                                    '$commentCount Comments',
                                                    style: const TextStyle(
                                                        fontSize: 13),
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: user == null
          ? null
          : CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(30),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(CupertinoIcons.add, color: CupertinoColors.white),
                  SizedBox(width: 5),
                  Text('New Post',
                      style: TextStyle(color: CupertinoColors.white)),
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

  Widget _buildDynamicImageRow(List<dynamic> imageUrls) {
    final imageCount = imageUrls.length;

    if (imageCount == 1) {
      // Show a single full-width image
      return GestureDetector(
        onTap: () => _showFullScreenImage(imageUrls[0]),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(imageUrls[0]),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (imageCount == 2) {
      // Show two images side by side
      return Row(
        children: imageUrls.take(2).map((imageUrl) {
          return Expanded(
            child: GestureDetector(
              onTap: () => _showFullScreenImage(imageUrl),
              child: Container(
                height: 150,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      // Show three images, with the last one showing "+X" if there are more
      return Row(
        children: List.generate(
          3,
          (index) {
            if (index == 2 && imageCount > 3) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showFullScreenImage(imageUrls[index]),
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(imageUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        '+${imageCount - 3}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return GestureDetector(
                onTap: () => _showFullScreenImage(imageUrls[index]),
                child: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(imageUrls[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      );
    }
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
