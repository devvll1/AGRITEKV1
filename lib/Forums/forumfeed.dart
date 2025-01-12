import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumsPage extends StatefulWidget {
  const ForumsPage({Key? key}) : super(key: key);

  @override
  _ForumsPageState createState() => _ForumsPageState();
}

class _ForumsPageState extends State<ForumsPage> {
  final TextEditingController _postController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  final Map<String, String> _userCache = {};

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<String> _getFullName(String? userId) async {
    if (userId == null) return 'Anonymous';

    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final fullName = '${data?['firstName'] ?? ''} ${data?['lastName'] ?? ''}'.trim();
        _userCache[userId] = fullName;
        return fullName.isNotEmpty ? fullName : 'Anonymous';
      }
    } catch (e) {}

    return 'Anonymous';
  }

  Future<void> _addPost() async {
    if (_postController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('posts').add({
      'content': _postController.text.trim(),
      'author': user?.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
    });
    _postController.clear();
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

  void _showCommentsModal(String postId, String postContent, List<dynamic> postLikes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CommentsModal(
        postId: postId,
        postContent: postContent,
        postLikes: postLikes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forums')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: const InputDecoration(hintText: 'Write a post...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addPost,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final postData = post.data() as Map<String, dynamic>;
                    final postTimestamp = postData['timestamp'] as Timestamp?;
                    final postTime = postTimestamp != null
                        ? timeago.format(postTimestamp.toDate())
                        : '';
                    final postLikes = postData['likes'] ?? [];

                    return FutureBuilder<String>(
                      future: _getFullName(postData['author']),
                      builder: (context, snapshot) {
                        final authorName = snapshot.data ?? 'Anonymous';

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(postData['content']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Posted by $authorName $postTime'),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        postLikes.contains(user?.uid)
                                            ? Icons.thumb_up
                                            : Icons.thumb_up_alt_outlined,
                                        color: postLikes.contains(user?.uid)
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      onPressed: () => _togglePostLike(post.id, postLikes),
                                    ),
                                    Text('${postLikes.length}'),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.comment),
                            onTap: () => _showCommentsModal(post.id, postData['content'], postLikes),
                          ),
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
    );
  }
}

class CommentsModal extends StatefulWidget {
  final String postId;
  final String postContent;
  final List<dynamic> postLikes;

  const CommentsModal({
    Key? key,
    required this.postId,
    required this.postContent,
    required this.postLikes,
  }) : super(key: key);

  @override
  _CommentsModalState createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  final TextEditingController _commentController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  final Map<String, String> _userCache = {};

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<String> _getFullName(String? userId) async {
    if (userId == null) return 'Anonymous';

    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final fullName = '${data?['firstName'] ?? ''} ${data?['lastName'] ?? ''}'.trim();
        _userCache[userId] = fullName;
        return fullName.isNotEmpty ? fullName : 'Anonymous';
      }
    } catch (e) {}

    return 'Anonymous';
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'content': _commentController.text.trim(),
      'author': user?.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
    });
    _commentController.clear();
  }

  Future<void> _toggleCommentLike(String commentId, List<dynamic> currentLikes) async {
    final userId = user?.uid;
    if (userId == null) return;

    final commentDoc = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);

    if (currentLikes.contains(userId)) {
      await commentDoc.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await commentDoc.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.postContent,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(hintText: 'Write a comment...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final commentData = comment.data() as Map<String, dynamic>;
                    final commentLikes = commentData['likes'] ?? [];
                    final commentTimestamp = commentData['timestamp'] as Timestamp?;
                    final commentTime = commentTimestamp != null
                        ? timeago.format(commentTimestamp.toDate())
                        : '';

                    return FutureBuilder<String>(
                      future: _getFullName(commentData['author']),
                      builder: (context, snapshot) {
                        final authorName = snapshot.data ?? 'Anonymous';

                        return ListTile(
                          title: Text(commentData['content']),
                          subtitle: Text('Commented by $authorName $commentTime'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  commentLikes.contains(user?.uid)
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_alt_outlined,
                                  color: commentLikes.contains(user?.uid)
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                                onPressed: () =>
                                    _toggleCommentLike(comment.id, commentLikes),
                              ),
                              Text('${commentLikes.length}'),
                            ],
                          ),
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
    );
  }
}
