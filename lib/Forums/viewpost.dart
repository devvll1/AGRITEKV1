// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agritek/Forums/editpost.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ViewPostPage extends StatefulWidget {
  final String userId; // User ID of the post author
  final String postId; // Post ID
  final String title; // Post title
  final String content; // Post content
  final String category; // Post category
  final String author; // Author's name
  final String time; // Time of the post
  final List<dynamic> likes; // List of likes
  final List<String> imageUrls; // List of image URLs
  String tags; // Tags for the post (mutable)

  ViewPostPage({
    super.key,
    required this.userId,
    required this.postId,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.time,
    required this.likes,
    required this.imageUrls,
    required this.tags,
  });

  @override
  State<ViewPostPage> createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  final TextEditingController _commentController = TextEditingController();
  String? _authorProfileImageUrl;
  String? _userProfileImageUrl;
  List<dynamic> _postLikes = [];
  bool _hasLiked = false;
  String? _postImageUrl;
  String? _authorFullName;
  late String _title;
  late String _content;
  late String _category;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {}); // Refresh the UI when the text changes
    });
    _fetchAuthorProfile(widget.userId);
    _fetchUserProfile();
    _fetchPostLikes();
    _fetchPostImageUrl();
    _fetchPostAuthor(widget.author);
    _title = widget.title;
    _content = widget.content;
    _category = widget.category;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _editPost() async {
    final updatedPost = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(
          postId: widget.postId,
          title: _title,
          content: _content,
          category: _category,
          imageUrls: widget.imageUrls, // Pass the current images
          tags: widget.tags, // Pass the current tags
        ),
      ),
    );

    if (updatedPost == null) return;

    setState(() {
      _title = updatedPost['title'];
      _content = updatedPost['content'];
      _category = updatedPost['category'];
      widget.imageUrls.clear();
      widget.imageUrls.addAll(updatedPost['imageUrls']);
      widget.tags = updatedPost['tags'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post updated successfully')),
    );
  }

  Future<void> _fetchPostAuthor(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final firstName = data?['firstName'] ?? 'Unknown';
        final lastName = data?['lastName'] ?? 'User';

        setState(() {
          _authorFullName = '$firstName $lastName'; // Full name of the author
        });
      }
    } catch (e) {}
  }

  Future<void> _deletePost() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Check if the current user is logged in and is the post owner
    final isOwner = currentUser != null && currentUser.uid == widget.author;

    if (!isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You are not authorized to delete this post.')),
      );
      return;
    }

    // Ask for confirmation before deletion
    final confirmation = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete Post'),
          content: const Text(
              'Are you sure you want to delete this post? This action cannot be undone.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              isDestructiveAction: true,
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmation != true) return;

    try {
      // Create a Firestore batch to delete the post and its comments
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Delete all comments under the post
      final commentsQuery = await postRef.collection('comments').get();
      for (var commentDoc in commentsQuery.docs) {
        batch.delete(commentDoc.reference);
      }

      // Delete the post itself
      batch.delete(postRef);

      // Commit the batch
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );

      // Navigate back after deletion
      Navigator.of(context)
          .pop(); // Close the dialog or go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete post')),
      );
    }
  }

  Future<void> _fetchPostImageUrl() async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (postDoc.exists) {
        final postData = postDoc.data();
        final postImageUrl =
            postData?['imageUrl'] ?? ''; // Get the imageUrl from Firestore
        setState(() {
          _postImageUrl = postImageUrl.isNotEmpty ? postImageUrl : null;
        });
      }
    } catch (e) {}
  }

  Future<void> _fetchAuthorProfile(String userId) async {
    try {
      // Fetch the user document using the provided userId (author's UID)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final profileImageUrl = data?['profileImageUrl'] ?? '';

        setState(() {
          _authorProfileImageUrl = profileImageUrl.isNotEmpty
              ? profileImageUrl
              : 'assets/images/defaultprofile.png';
        });
      } else {
        setState(() {
          _authorProfileImageUrl = 'assets/images/defaultprofile.png';
        });
      }
    } catch (e) {
      setState(() {
        _authorProfileImageUrl = 'assets/images/defaultprofile.png';
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userProfileImageUrl = userDoc.data()?['profileImageUrl'] ?? '';
        });
      }
    } catch (e) {}
  }

  Future<void> _fetchPostLikes() async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (postDoc.exists) {
        setState(() {
          _postLikes = postDoc.data()?['likes'] ?? [];
          _hasLiked =
              _postLikes.contains(FirebaseAuth.instance.currentUser?.uid);
        });
      }
    } catch (e) {}
  }

  Future<void> _togglePostLike(String postId, List<dynamic> currentLikes,
      String postTitle, String postAuthorId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like posts.')),
      );
      return;
    }

    final userId = user.uid;
    final postDoc = FirebaseFirestore.instance.collection('posts').doc(postId);

    try {
      if (currentLikes.contains(userId)) {
        await postDoc.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
      } else {
        await postDoc.update({
          'likes': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {}
  }

  Future<void> _addComment(
      String comment, String postId, String postTitle, String postAuthorId,
      {String? imageUrl}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to add a comment.')),
      );
      return;
    }

    if (comment.isEmpty && (imageUrl == null || imageUrl.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty.')),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found.')),
        );
        return;
      }

      final userData = userDoc.data()!;
      final fullName =
          '${userData['firstName'] ?? 'Unknown'} ${userData['lastName'] ?? 'User'}';

      final commentData = {
        'text': comment,
        'imageUrl': imageUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'author': fullName,
        'userId': user.uid,
        'profileImageUrl':
            userData['profileImageUrl'] ?? 'assets/images/defaultprofile.png',
        'likes': [],
      };

      final postDoc =
          FirebaseFirestore.instance.collection('posts').doc(postId);
      await postDoc.collection('comments').add(commentData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully')),
      );

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add comment')),
      );
    }
  }

  Future<void> _editComment(
      DocumentReference commentRef, String currentText) async {
    final TextEditingController editController =
        TextEditingController(text: currentText);

    final updatedComment = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(labelText: 'Edit your comment'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(editController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (updatedComment == null || updatedComment.isEmpty) return;

    try {
      await commentRef.update({'text': updatedComment});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update comment')),
      );
    }
  }

  Future<void> _deleteComment(DocumentReference commentRef) async {
    final confirmation = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              isDestructiveAction: true,
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmation != true) return;

    try {
      await commentRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete comment')),
      );
    }
  }

  Future<void> _toggleCommentLike(
      DocumentReference commentRef, List<String> currentLikes) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to like comments.')),
      );
      return;
    }

    final userId = user.uid;

    try {
      if (currentLikes.contains(userId)) {
        await commentRef.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
      } else {
        await commentRef.update({
          'likes': FieldValue.arrayUnion([userId]),
        });

        // Fetch the comment's author ID
        final commentSnapshot = await commentRef.get();
        final commentData = commentSnapshot.data() as Map<String, dynamic>?;
        final commentAuthorId = commentData?['userId'];

        // Notify the comment's author
        if (commentAuthorId != null && commentAuthorId != user.uid) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          final userData = userDoc.data()!;
          final userName =
              '${userData['firstName'] ?? 'Unknown'} ${userData['lastName'] ?? 'User'}';

          final notificationRef = FirebaseFirestore.instance
              .collection('notifications')
              .doc(commentAuthorId)
              .collection('userNotifications')
              .doc();

          await notificationRef.set({
            'type': 'like',
            'postId': widget.postId,
            'postTitle': widget.title,
            'senderId': user.uid,
            'senderName': userName,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to like comment')),
      );
    }
  }

  Future<void> _replyToComment(DocumentReference commentRef) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to reply.')),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user details.')),
      );
      return;
    }

    final userData = userDoc.data()!;
    final userName =
        '${userData['firstName'] ?? 'Unknown'} ${userData['lastName'] ?? 'User'}';
    final userProfileImageUrl =
        userData['profileImageUrl'] ?? 'assets/images/defaultprofile.png';

    final TextEditingController replyController = TextEditingController();
    String? imageUrl;

    final reply = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reply to Comment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: replyController,
                decoration: const InputDecoration(labelText: 'Reply'),
              ),
              const SizedBox(height: 8),
              CupertinoButton(
                child: const Text('Attach Image'),
                onPressed: () async {
                  // Implement image picker logic here
                  // Set `imageUrl` to the uploaded image's URL
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop({
                'text': replyController.text.trim(),
                'imageUrl': imageUrl ?? '',
              }),
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );

    if (reply == null || reply['text']!.isEmpty) return;

    try {
      // Add the reply to Firestore
      await commentRef.collection('replies').add({
        'text': reply['text'],
        'imageUrl': reply['imageUrl'],
        'timestamp': FieldValue.serverTimestamp(),
        'author': userName,
        'profileImageUrl': userProfileImageUrl,
        'userId': user.uid,
      });

      // Fetch the comment's author ID
      final commentSnapshot = await commentRef.get();
      final commentData = commentSnapshot.data() as Map<String, dynamic>?;
      final commentAuthorId = commentData?['userId'];

      // Notify the comment's author
      if (commentAuthorId != null && commentAuthorId != user.uid) {
        final notificationRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc(commentAuthorId)
            .collection('userNotifications')
            .doc();

        await notificationRef.set({
          'type': 'reply',
          'postId': widget.postId,
          'postTitle': widget.title,
          'senderId': user.uid,
          'senderName': userName,
          'comment': reply['text'],
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reply to comment')),
      );
    }
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.black,
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
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

  Future<String?> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return null; // User canceled the picker
    }

    try {
      final file = File(pickedFile.path);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('comment_images')
          .child('$fileName.jpg');

      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && currentUser.uid == widget.author;

    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Colors.black,
      ),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: isOwner
              ? Row(
                  mainAxisSize:
                      MainAxisSize.min, // Ensures the buttons fit properly
                  children: [
                    GestureDetector(
                      onTap: _editPost, // Call your edit function
                      child: const Icon(CupertinoIcons.pencil,
                          color: CupertinoColors.activeBlue),
                    ),
                    const SizedBox(width: 16), // Add spacing between the icons
                    GestureDetector(
                      onTap: _deletePost,
                      child: const Icon(CupertinoIcons.delete,
                          color: CupertinoColors.destructiveRed),
                    ),
                  ],
                )
              : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post Details
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: _authorProfileImageUrl != null &&
                                      _authorProfileImageUrl!.isNotEmpty
                                  ? NetworkImage(_authorProfileImageUrl!)
                                  : const AssetImage(
                                      'assets/images/defaultprofile.png'),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _authorFullName ?? 'Fetching author...',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.category,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.inactiveGray,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Post Image
                        _postImageUrl != null && _postImageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: GestureDetector(
                                  onTap: () {
                                    if (_postImageUrl != null &&
                                        _postImageUrl!.isNotEmpty) {
                                      _showImagePopup(context, _postImageUrl!);
                                    }
                                  },
                                  child: Image.network(
                                    _postImageUrl!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        const SizedBox
                                            .shrink(), // Empty space when image fails
                                  ),
                                ),
                              )
                            : const SizedBox
                                .shrink(), // Don't show anything when there's no image

                        const SizedBox(height: 8),
                        // Post Date
                        Text(
                          widget.time.isNotEmpty
                              ? DateFormat.yMMMd().format(
                                  DateFormat('MMM d, yyyy h:mm a')
                                      .parse(widget.time),
                                )
                              : 'Unknown Date',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const Divider(),
                        // Post Title
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Post Content
                        Text(
                          widget.content,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        // Uploaded Images Section
                        if (widget.imageUrls.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Column(
                            children: widget.imageUrls.map((imageUrl) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: GestureDetector(
                                  onTap: () => _showFullScreenImage(imageUrl),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit
                                        .contain, // Show the image in its original size
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const Divider(),
                        // Likes Section
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _hasLiked
                                    ? CupertinoIcons.hand_thumbsup_fill
                                    : CupertinoIcons.hand_thumbsup,
                                color: _hasLiked
                                    ? CupertinoColors.activeBlue
                                    : CupertinoColors.inactiveGray,
                              ),
                              onPressed: () => _togglePostLike(widget.postId,
                                  _postLikes, widget.title, widget.author),
                            ),
                            Text('${_postLikes.length} Likes'),
                          ],
                        ),
                        const Divider(),
                        // Comments Section
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(widget.postId)
                              .collection('comments')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text('No comments yet'),
                              );
                            }

                            final comments = snapshot.data!.docs;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final commentData = comments[index].data()
                                    as Map<String, dynamic>;
                                final author =
                                    commentData['author'] ?? 'Anonymous';
                                final text = commentData['text'] ?? '';
                                final imageUrl = commentData['imageUrl'] ?? '';
                                final likes = List<String>.from(
                                    commentData['likes'] ?? []);
                                final timestamp =
                                    commentData['timestamp'] as Timestamp?;
                                final time = timestamp != null
                                    ? DateFormat('MMM d, yyyy h:mm a')
                                        .format(timestamp.toDate())
                                    : 'Just now';

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundImage: (commentData[
                                                            'profileImageUrl'] !=
                                                        null &&
                                                    commentData[
                                                            'profileImageUrl']
                                                        .isNotEmpty &&
                                                    Uri.tryParse(commentData[
                                                                'profileImageUrl'])
                                                            ?.hasAbsolutePath ==
                                                        true)
                                                ? NetworkImage(commentData[
                                                    'profileImageUrl'])
                                                : const AssetImage(
                                                        'assets/images/defaultprofile.png')
                                                    as ImageProvider,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    author,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  if (text.isNotEmpty)
                                                    Text(text),
                                                  if (imageUrl.isNotEmpty)
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _showFullScreenImage(
                                                              imageUrl),
                                                      child: Image.network(
                                                        imageUrl,
                                                        height: 150,
                                                        fit: BoxFit.cover,
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return const Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        },
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                          size: 50,
                                                        ),
                                                      ),
                                                    ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    time,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () =>
                                                            _toggleCommentLike(
                                                                comments[index]
                                                                    .reference,
                                                                likes),
                                                        child: Icon(
                                                          likes.contains(
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser
                                                                      ?.uid)
                                                              ? CupertinoIcons
                                                                  .heart_fill
                                                              : CupertinoIcons
                                                                  .heart,
                                                          color: likes.contains(
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser
                                                                      ?.uid)
                                                              ? CupertinoColors
                                                                  .systemRed
                                                              : CupertinoColors
                                                                  .inactiveGray,
                                                          size: 18,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text('${likes.length}'),
                                                      const SizedBox(width: 16),
                                                      GestureDetector(
                                                        onTap: () =>
                                                            _replyToComment(
                                                                comments[index]
                                                                    .reference),
                                                        child: const Icon(
                                                          CupertinoIcons.reply,
                                                          color: CupertinoColors
                                                              .activeBlue,
                                                          size: 18,
                                                        ),
                                                      ),
                                                      if (FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              ?.uid ==
                                                          commentData[
                                                              'userId']) ...[
                                                        const SizedBox(
                                                            width: 16),
                                                        GestureDetector(
                                                          onTap: () =>
                                                              _editComment(
                                                                  comments[
                                                                          index]
                                                                      .reference,
                                                                  commentData[
                                                                      'text']),
                                                          child: const Icon(
                                                            CupertinoIcons
                                                                .pencil,
                                                            color:
                                                                CupertinoColors
                                                                    .activeBlue,
                                                            size: 18,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        GestureDetector(
                                                          onTap: () =>
                                                              _deleteComment(
                                                                  comments[
                                                                          index]
                                                                      .reference),
                                                          child: const Icon(
                                                            CupertinoIcons
                                                                .delete,
                                                            color: CupertinoColors
                                                                .destructiveRed,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Replies Section
                                      StreamBuilder<QuerySnapshot>(
                                        stream: comments[index]
                                            .reference
                                            .collection('replies')
                                            .orderBy('timestamp',
                                                descending: true)
                                            .snapshots(),
                                        builder: (context, replySnapshot) {
                                          if (!replySnapshot.hasData ||
                                              replySnapshot
                                                  .data!.docs.isEmpty) {
                                            return const SizedBox.shrink();
                                          }

                                          final replies =
                                              replySnapshot.data!.docs;

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 40.0, top: 8.0),
                                            child: Column(
                                              children: replies.map((reply) {
                                                final replyData = reply.data()
                                                    as Map<String, dynamic>;
                                                final replyAuthor =
                                                    replyData['author'] ??
                                                        'Anonymous';
                                                final replyText =
                                                    replyData['text'] ?? '';
                                                final replyImageUrl =
                                                    replyData['imageUrl'] ?? '';
                                                final replyProfileImageUrl =
                                                    replyData[
                                                            'profileImageUrl'] ??
                                                        '';
                                                final replyLikes =
                                                    List<String>.from(
                                                        replyData['likes'] ??
                                                            []);
                                                final replyTimestamp =
                                                    replyData['timestamp']
                                                        as Timestamp?;
                                                final replyTime = replyTimestamp !=
                                                        null
                                                    ? DateFormat(
                                                            'MMM d, yyyy h:mm a')
                                                        .format(replyTimestamp
                                                            .toDate())
                                                    : 'Just now';

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 12,
                                                        backgroundImage: (replyProfileImageUrl
                                                                    .isNotEmpty &&
                                                                Uri.tryParse(
                                                                            replyProfileImageUrl)
                                                                        ?.hasAbsolutePath ==
                                                                    true)
                                                            ? NetworkImage(
                                                                replyProfileImageUrl)
                                                            : const AssetImage(
                                                                    'assets/images/defaultprofile.png')
                                                                as ImageProvider,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 1,
                                                                blurRadius: 3,
                                                                offset:
                                                                    const Offset(
                                                                        0, 1),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                replyAuthor,
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              if (replyText
                                                                  .isNotEmpty)
                                                                Text(replyText),
                                                              if (replyImageUrl
                                                                  .isNotEmpty)
                                                                GestureDetector(
                                                                  onTap: () =>
                                                                      _showFullScreenImage(
                                                                          replyImageUrl),
                                                                  child: Image
                                                                      .network(
                                                                    replyImageUrl,
                                                                    height: 100,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                replyTime,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Row(
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        _toggleCommentLike(
                                                                            reply.reference,
                                                                            replyLikes),
                                                                    child: Icon(
                                                                      replyLikes.contains(FirebaseAuth
                                                                              .instance
                                                                              .currentUser
                                                                              ?.uid)
                                                                          ? CupertinoIcons
                                                                              .heart_fill
                                                                          : CupertinoIcons
                                                                              .heart,
                                                                      color: replyLikes.contains(FirebaseAuth
                                                                              .instance
                                                                              .currentUser
                                                                              ?.uid)
                                                                          ? CupertinoColors
                                                                              .systemRed
                                                                          : CupertinoColors
                                                                              .inactiveGray,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  Text(
                                                                      '${replyLikes.length}'),
                                                                  const SizedBox(
                                                                      width:
                                                                          16),
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        _replyToComment(
                                                                            reply.reference),
                                                                    child:
                                                                        const Icon(
                                                                      CupertinoIcons
                                                                          .reply,
                                                                      color: CupertinoColors
                                                                          .activeBlue,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                                  if (FirebaseAuth
                                                                          .instance
                                                                          .currentUser
                                                                          ?.uid ==
                                                                      replyData[
                                                                          'userId']) ...[
                                                                    const SizedBox(
                                                                        width:
                                                                            16),
                                                                    GestureDetector(
                                                                      onTap: () => _editComment(
                                                                          reply
                                                                              .reference,
                                                                          replyData[
                                                                              'text']),
                                                                      child:
                                                                          const Icon(
                                                                        CupertinoIcons
                                                                            .pencil,
                                                                        color: CupertinoColors
                                                                            .activeBlue,
                                                                        size:
                                                                            18,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    GestureDetector(
                                                                      onTap: () =>
                                                                          _deleteComment(
                                                                              reply.reference),
                                                                      child:
                                                                          const Icon(
                                                                        CupertinoIcons
                                                                            .delete,
                                                                        color: CupertinoColors
                                                                            .destructiveRed,
                                                                        size:
                                                                            18,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Add Comment Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _commentController,
                        placeholder: FirebaseAuth.instance.currentUser == null
                            ? 'Log in to add a comment'
                            : 'Add a comment...',
                        padding: const EdgeInsets.all(12),
                        enabled: FirebaseAuth.instance.currentUser != null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      color: CupertinoColors.activeBlue,
                      onPressed: () async {
                        final imageUrl = await _pickAndUploadImage();
                        if (imageUrl != null) {
                          await _addComment(
                            _commentController.text,
                            widget.postId,
                            widget.title,
                            widget.author,
                            imageUrl: imageUrl,
                          );
                        }
                      },
                      child: const Icon(
                        CupertinoIcons.photo,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      color: CupertinoColors.activeBlue,
                      onPressed: _commentController.text.trim().isEmpty
                          ? null
                          : () async {
                              await _addComment(
                                _commentController.text.trim(),
                                widget.postId,
                                widget.title,
                                widget.author,
                              );
                              _commentController
                                  .clear(); // Clear the text field after sending
                            },
                      child: const Icon(
                        CupertinoIcons.paperplane_fill,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                    final timestamp = data['timestamp'] as Timestamp?;
                    final formattedTime = timestamp != null
                        ? DateFormat('MMM d, yyyy h:mm a')
                            .format(timestamp.toDate())
                        : 'Unknown time';

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
}
