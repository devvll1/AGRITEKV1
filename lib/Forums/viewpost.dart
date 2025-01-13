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
  final String imageUrl;

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
    required this.imageUrl,
    required List comments,
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
  

  @override
  void initState() {
    super.initState();
    _fetchAuthorProfile(widget.userId);
    _fetchUserProfile();
    _fetchPostLikes();
     _fetchPostImageUrl();

  }

@override
void dispose() {
  _commentController.dispose();
  super.dispose();
}

 Future<void> _fetchPostImageUrl() async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (postDoc.exists) {
        final postData = postDoc.data();
        final postImageUrl = postData?['imageUrl'] ?? ''; // Get the imageUrl from Firestore
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
      // Ensure that you're querying by the user ID.
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        print("Fetched Author Data: $data"); // Debugging line to check fetched data.
        final profileImageUrl = data?['profileImageUrl'] ?? '';
        setState(() {
          _authorProfileImageUrl = profileImageUrl.isNotEmpty
              ? profileImageUrl
              : 'assets/images/defaultprofile.png'; // Fallback to default if empty
        });
      } else {
        debugPrint('User document not found');
      }
    } catch (e) {
      debugPrint('Error fetching author profile: $e');
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
          _hasLiked = _postLikes.contains(FirebaseAuth.instance.currentUser?.uid);
        });
      }
    } catch (e) {
      debugPrint('Error fetching post likes: $e');
    }
  }

  Future<void> _togglePostLike() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final postDoc = FirebaseFirestore.instance.collection('posts').doc(widget.postId);

    try {
      if (_hasLiked) {
        await postDoc.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
        setState(() {
          _postLikes.remove(userId);
          _hasLiked = false;
        });
      } else {
        await postDoc.update({
          'likes': FieldValue.arrayUnion([userId]),
        });
        setState(() {
          _postLikes.add(userId);
          _hasLiked = true;
        });
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> _addComment(String comment) async {
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
        'profileImageUrl': userData['profileImageUrl'], // Added profile image URL
      };

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add(commentData);

      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully')),
      );
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Colors.black,
      ),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
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
                                  widget.author,
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
                        ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: GestureDetector(
                                onTap: () {
                                  if (_postImageUrl != null && _postImageUrl!.isNotEmpty) {
                                    _showImagePopup(context, _postImageUrl!);
                                  }
                                },
                                child: _postImageUrl != null && _postImageUrl!.isNotEmpty
                                    ? Image.network(
                                        _postImageUrl!,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      (loadingProgress.expectedTotalBytes ?? 1)
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) => const Image(
                                          image: AssetImage('assets/images/defaultimg.png'),
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Image(
                                        image: AssetImage('assets/images/defaultimg.png'),
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),

                        const SizedBox(height: 8),
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
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.content,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const Divider(),
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
                              onPressed: _togglePostLike,
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
                                final commentData =
                                    comments[index].data() as Map<String, dynamic>;
                                final author = commentData['author'] ?? 'Anonymous';
                                final text = commentData['text'] ?? '';
                                final timestamp =
                                    commentData['timestamp'] as Timestamp?;
                                final time = timestamp != null
                                    ? DateFormat('MMM d, yyyy h:mm a')
                                        .format(timestamp.toDate())
                                    : 'Just now';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                            borderRadius: BorderRadius.circular(8),
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
              // Add Comment
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _commentController,
                        placeholder: 'Add a comment...',
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      color: CupertinoColors.activeBlue,
                      onPressed: () async {
                        if (_commentController.text.isNotEmpty) {
                          await _addComment(_commentController.text);
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
