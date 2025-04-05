// ignore_for_file: unused_element

import 'package:agritek/Forums/postdetails.dart';
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

              return ListTile(
                title: Text(
                  data['type'] == 'like'
                      ? '${data['senderName']} liked your post: ${data['postTitle']}'
                      : '${data['senderName']} commented on your post: ${data['postTitle']}',
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
        final userName = userDoc.data()?['name'] ?? 'Someone';

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
            'senderName': userName,
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

      final commentData = {
        'text': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'author': fullName,
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
