// ignore_for_file: unused_element, unused_import, use_build_context_synchronously

import 'package:agritek/Forums/viewpost.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
              final isRead = data['isRead'] ?? false;

              return GestureDetector(
                onTap: () async {
                  // Mark the notification as read
                  await notification.reference.update({'isRead': true});

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
                          time: formattedTime, // Pass the formatted time
                          likes: postData['likes'] ?? [],
                          imageUrls: postData['imageUrls'] ?? [],
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
                child: Container(
                  color: isRead
                      ? Colors
                          .white // Default background for read notifications
                      : Colors.grey[200], // Highlight unread notifications
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    children: [
                      // Sender's profile image
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: (data['profileImageUrl'] != null &&
                                data['profileImageUrl'].isNotEmpty)
                            ? NetworkImage(data['profileImageUrl'])
                            : const AssetImage(
                                    'assets/images/defaultprofile.png')
                                as ImageProvider,
                      ),
                      const SizedBox(
                          width: 10), // Spacing between image and text

                      // Notification content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['type'] == 'like'
                                  ? '$senderName liked your post: ${data['postTitle']}'
                                  : '$senderName commented on your post: ${data['postTitle']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (data['type'] == 'comment')
                              Text(
                                data['comment'] ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _togglePostLike(String postId, List<dynamic> currentLikes,
      String postTitle, String postAuthorId) async {
    debugPrint('Toggling like for post: $postId');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('User is not logged in');
      return;
    }

    final userId = user.uid;
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
    debugPrint('Adding comment to post: $postId');
    final user = FirebaseAuth.instance.currentUser;

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
          .doc(user.uid)
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
        'userId': user.uid,
        'profileImageUrl':
            userData['profileImageUrl'] ?? 'assets/images/defaultprofile.png',
      };

      // Add the comment to Firestore
      final postDoc =
          FirebaseFirestore.instance.collection('posts').doc(postId);
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
          'senderName': fullName,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

        debugPrint('Notification added for comment');
      }

      debugPrint('Comment added successfully');
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }
}
