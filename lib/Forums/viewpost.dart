import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewPostPage extends StatefulWidget {
  final String userId;
  final String postId;
  final String title;
  final String content;
  final String category;
  final String author;
  final String time;
  final List<dynamic> likes;
  final List<dynamic> imageUrls; // Added imageUrls
  final String tags; // Added tags

  const ViewPostPage({
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
    _fetchAuthorProfile(widget.userId);
    _fetchUserProfile();
    _fetchPostLikes();
    _fetchPostImageUrl();
    _fetchPostAuthor(widget.author);
    _title = widget.title;
    _content = widget.content;
    _category = widget.category;

    if (widget.author.isNotEmpty) {
      _fetchAuthorProfile(widget.author);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _editPost() async {
    final titleController = TextEditingController(text: _title);
    final contentController = TextEditingController(text: _content);

    String updatedCategory = _category;

    final updatedPost = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: updatedCategory,
                  items: const [
                    DropdownMenuItem(
                      value: 'Crop Farming',
                      child: Text('Crop Farming'),
                    ),
                    DropdownMenuItem(
                      value: 'Livestock',
                      child: Text('Livestock'),
                    ),
                    DropdownMenuItem(
                      value: 'Aquafisheries',
                      child: Text('Aquafisheries'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      updatedCategory = value;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedTitle = titleController.text.trim();
                final updatedContent = contentController.text.trim();

                Navigator.of(context).pop({
                  'title': updatedTitle,
                  'content': updatedContent,
                  'category': updatedCategory,
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (updatedPost == null) return;

    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      await postRef.update({
        'title': updatedPost['title'],
        'content': updatedPost['content'],
        'category': updatedPost['category'],
      });

      setState(() {
        _title = updatedPost['title']!;
        _content = updatedPost['content']!;
        _category = updatedPost['category']!;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
      }

      // Navigate back to the ViewPostPage after editing
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => ViewPostPage(
            userId: widget.userId,
            postId: widget.postId,
            title: _title,
            content: _content,
            category: _category,
            author: widget.author,
            time: widget.time,
            likes: widget.likes,
            imageUrls: widget.imageUrls,
            tags: widget.tags,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error updating post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update post')),
        );
      }
    }
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
      } else {
        debugPrint('User document not found for userId: $userId');
      }
    } catch (e) {
      debugPrint('Error fetching post author profile: $e');
    }
  }

  Future<void> _deletePost() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Check if the current user is logged in and is the post owner
    final isOwner = currentUser != null && currentUser.uid == widget.author;
    debugPrint('Current User ID: ${currentUser?.uid}');
    debugPrint('Post Author ID: ${widget.author}');

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
      debugPrint('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete post')),
      );
    }
  }

  Future<void> _deleteComment(DocumentReference commentRef) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to delete a comment.')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmation = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete Comment'),
          content: const Text(
              'Are you sure you want to delete this comment? This action cannot be undone.'),
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
      final commentSnapshot = await commentRef.get();

      if (commentSnapshot.exists) {
        final commentData = commentSnapshot.data() as Map<String, dynamic>;

        // Allow only the comment owner to delete
        if (commentData['userId'] == currentUser.uid) {
          await commentRef.delete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comment deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('You are not authorized to delete this comment.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment not found.')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete comment')),
      );
    }
  }

  Future<void> _editComment(
      DocumentReference commentRef, String oldCommentText) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to edit a comment.')),
      );
      return;
    }

    // Show dialog to edit the comment
    final TextEditingController editController =
        TextEditingController(text: oldCommentText);

    final newComment = await showDialog<String>(
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
              onPressed: () {
                final editedText = editController.text.trim();
                Navigator.of(context).pop(editedText);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newComment == null ||
        newComment.isEmpty ||
        newComment == oldCommentText) return;

    try {
      final commentSnapshot = await commentRef.get();

      if (commentSnapshot.exists) {
        final commentData = commentSnapshot.data() as Map<String, dynamic>;

        // Check if the current user is the author of the comment
        if (commentData['userId'] == currentUser.uid) {
          await commentRef.update({'text': newComment});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comment edited successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('You are not authorized to edit this comment.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment not found.')),
        );
      }
    } catch (e) {
      debugPrint('Error editing comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to edit comment')),
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
    } catch (e) {
      debugPrint('Error fetching post image: $e');
    }
  }

  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Image(
                  image: AssetImage('assets/images/defaultimg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
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
        print(
            "Fetched Author Data: $data"); // Debugging line to check fetched data.
        final profileImageUrl = data?['profileImageUrl'] ??
            ''; // Get profileImageUrl or empty string

        setState(() {
          // If the profile image URL is not empty, use it. Otherwise, use the default profile image.
          _authorProfileImageUrl = profileImageUrl.isNotEmpty
              ? profileImageUrl
              : 'assets/images/defaultprofile.png'; // Fallback to default image if empty
        });
      } else {
        debugPrint('User document not found');
        // If no user document is found, set the default profile image
        setState(() {
          _authorProfileImageUrl = 'assets/images/defaultprofile.png';
        });
      }
    } catch (e) {
      debugPrint('Error fetching author profile: $e');
      // In case of an error, set the default profile image
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
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
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
    } catch (e) {
      debugPrint('Error fetching post likes: $e');
    }
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

  Widget _buildImageGrid(List<dynamic> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final imageCount = imageUrls.length;

    if (imageCount == 1) {
      // Single full-width image
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
      // Two images side by side
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
      // Three or more images
      return Row(
        children: List.generate(
          3,
          (index) {
            if (index == 2 && imageCount > 3) {
              // Show "+X" overlay for additional images
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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && currentUser.uid == widget.author;
    debugPrint('Current User ID: ${currentUser?.uid}');
    debugPrint('Post Author ID: ${widget.author}');

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
                                          'assets/images/defaultprofile.png')
                                      as ImageProvider,
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
                          DateFormat.yMMMd().format(
                            DateFormat('MMM d, yyyy h:mm a').parse(widget.time),
                          ),
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
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CupertinoActivityIndicator(),
                              );
                            }

                            final comments = snapshot.data!.docs;

                            if (comments.isEmpty) {
                              return const Center(
                                child: Text('No comments yet'),
                              );
                            }

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
                                final timestamp =
                                    commentData['timestamp'] as Timestamp?;
                                final time = timestamp != null
                                    ? DateFormat('MMM d, yyyy h:mm a')
                                        .format(timestamp.toDate())
                                    : 'Just now';

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(
                                          commentData['profileImageUrl'] ??
                                              'assets/images/defaultprofile.png',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: CupertinoColors.systemGrey5,
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
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(text),
                                              const SizedBox(height: 4),
                                              Text(
                                                time,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Add delete button for the comment
                                              if (currentUser?.uid ==
                                                  commentData[
                                                      'userId']) // Check if current user is the author
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () => _editComment(
                                                          comments[index]
                                                              .reference,
                                                          commentData['text']),
                                                      child: const Icon(
                                                        CupertinoIcons.pencil,
                                                        color: CupertinoColors
                                                            .activeBlue,
                                                        size: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width:
                                                            8), // Spacing between icons
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _deleteComment(
                                                              comments[index]
                                                                  .reference),
                                                      child: const Icon(
                                                        CupertinoIcons.delete,
                                                        color: CupertinoColors
                                                            .destructiveRed,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
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
                      onPressed: FirebaseAuth.instance.currentUser == null
                          ? () {
                              // Show login prompt
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please log in to comment'),
                                ),
                              );
                            }
                          : () async {
                              if (_commentController.text.isNotEmpty) {
                                await _addComment(_commentController.text,
                                    widget.postId, widget.title, widget.author);
                              }
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
}
