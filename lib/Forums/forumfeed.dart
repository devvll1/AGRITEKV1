// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api, unnecessary_string_interpolations, avoid_types_as_parameter_names, prefer_const_declarations, unused_element, unused_import, empty_catches

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

    try {
      if (currentLikes.contains(userId)) {
        // Unlike the post
        await postDoc.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
      } else {
        // Like the post
        await postDoc.update({
          'likes': FieldValue.arrayUnion([userId]),
        });

        // Fetch the user's name
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          debugPrint('User document does not exist');
          return;
        }

        final userData = userDoc.data()!;
        final firstName = userData['firstName'] ?? 'Unknown';
        final lastName = userData['lastName'] ?? 'User';
        final fullName = '$firstName $lastName';

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
            'senderName': fullName,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });

          debugPrint('Notification added for like');
        }
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> _addComment(String comment, String postId, String postTitle,
      String postAuthorId) async {
    if (user == null) {
      debugPrint('User is not logged in');
      return;
    }

    if (comment.isEmpty) {
      debugPrint('Comment is empty');
      return;
    }

    try {
      // Fetch the current user's details
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('User document does not exist');
        return;
      }

      final userData = userDoc.data()!;
      final firstName = userData['firstName'] ?? 'Unknown';
      final lastName = userData['lastName'] ?? 'User';
      final fullName = '$firstName $lastName';

      // Prepare the comment data
      final commentData = {
        'text': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'author': fullName,
        'userId': user!.uid,
        'profileImageUrl':
            userData['profileImageUrl'] ?? 'assets/images/defaultprofile.png',
      };

      // Add the comment to Firestore
      final postDoc =
          FirebaseFirestore.instance.collection('posts').doc(postId);
      await postDoc.collection('comments').add(commentData);

      // Add a notification for the post author
      if (postAuthorId != user!.uid) {
        final notificationRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc(postAuthorId)
            .collection('userNotifications')
            .doc();

        await notificationRef.set({
          'type': 'comment',
          'postId': postId,
          'postTitle': postTitle,
          'senderId': user!.uid,
          'senderName': fullName,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

        debugPrint('Notification added for comment');
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
                                      imageUrls: List<String>.from(
                                          postData['imageUrls'] ?? []),
                                      tags: postData['tags'] ?? '',
                                      userId: user?.uid ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 3.0),
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
                                          'Tags: #${postData['tags']}',
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
                                        _buildImageGrid(postData['imageUrls']),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
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
                                                  if (!commentSnapshot
                                                      .hasData) {
                                                    return const Text(
                                                      '0 Comments',
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                    );
                                                  }

                                                  final comments =
                                                      commentSnapshot
                                                          .data!.docs;

                                                  // Count the number of replies for each comment
                                                  return FutureBuilder<int>(
                                                    future: Future.wait(comments
                                                        .map((comment) async {
                                                      final repliesSnapshot =
                                                          await comment
                                                              .reference
                                                              .collection(
                                                                  'replies')
                                                              .get();
                                                      return repliesSnapshot
                                                          .docs.length;
                                                    })).then((replyCounts) =>
                                                        replyCounts.fold<int>(
                                                            comments.length,
                                                            (total, count) =>
                                                                total + count)),
                                                    builder:
                                                        (context, snapshot) {
                                                      final totalCommentsAndReplies =
                                                          snapshot.data ??
                                                              comments.length;
                                                      return Text(
                                                        '$totalCommentsAndReplies Comments',
                                                        style: const TextStyle(
                                                            fontSize: 13),
                                                      );
                                                    },
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

  Widget _buildImageGrid(List<dynamic> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final imageCount = imageUrls.length;
    final maxImagesToShow = 4;

    return SizedBox(
      height: 300, // Set a fixed height for the row
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Distribute spaces evenly
        children: List.generate(
          imageCount > maxImagesToShow ? maxImagesToShow : imageCount,
          (index) {
            if (index == maxImagesToShow - 1 && imageCount > maxImagesToShow) {
              // Show "+X" overlay for additional images
              return Expanded(
                child: GestureDetector(
                  onTap: () => _showFullScreenGallery(imageUrls, index),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(imageUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.black.withOpacity(0.5),
                          child: Text(
                            '+${imageCount - maxImagesToShow}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Show individual images
              return Expanded(
                child: GestureDetector(
                  onTap: () => _showFullScreenGallery(imageUrls, index),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showFullScreenGallery(List<dynamic> imageUrls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
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

class FullScreenGallery extends StatefulWidget {
  final List<dynamic> imageUrls;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  _FullScreenGalleryState createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return Center(
            child: Image.network(
              widget.imageUrls[index],
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 50,
              ),
            ),
          );
        },
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .doc(userId)
            .collection('userNotifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final data = notification.data() as Map<String, dynamic>;

              final senderName = data['senderName'] ?? 'Someone';

              return ListTile(
                title: Text(
                  data['type'] == 'like'
                      ? '$senderName liked your post: ${data['postTitle']}'
                      : '$senderName commented on your post: ${data['postTitle']}',
                ),
                subtitle:
                    data['type'] == 'comment' ? Text(data['comment']) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    notification.reference.update({'isRead': true});
                  },
                ),
                onTap: () async {
                  // Fetch the post details from Firestore
                  final postSnapshot = await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(data['postId'])
                      .get();

                  if (postSnapshot.exists) {
                    final postData =
                        postSnapshot.data() as Map<String, dynamic>;

                    // Format the timestamp
                    final timestamp = postData['timestamp'] as Timestamp;
                    final formattedTime = DateFormat('MMM dd, yyyy hh:mm a')
                        .format(timestamp.toDate());

                    // Navigate to the ViewPostPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewPostPage(
                          userId: postData['author'] ?? '',
                          postId: data['postId'],
                          title: postData['title'] ?? 'No Title',
                          content: postData['content'] ?? 'No Content',
                          category: postData['category'] ?? 'No Category',
                          author: postData['author'] ?? '',
                          time: formattedTime,
                          likes: postData['likes'] ?? [],
                          imageUrls:
                              List<String>.from(postData['imageUrls'] ?? []),
                          tags: postData['tags'] ?? '',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post not found.')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
