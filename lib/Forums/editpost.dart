// ignore_for_file: must_be_immutable, use_build_context_synchronously, unused_element

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditPostPage extends StatefulWidget {
  final String postId;
  final String title;
  final String content;
  final String category;
  final List<String> imageUrls;
  final String tags;

  const EditPostPage({
    super.key,
    required this.postId,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrls,
    required this.tags,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late String _selectedCategory;
  late List<String> _imageUrls;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _contentController = TextEditingController(text: widget.content);
    _tagsController = TextEditingController(text: widget.tags);
    _selectedCategory = widget.category;
    _imageUrls = List.from(widget.imageUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      await postRef.update({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _selectedCategory,
        'tags': _tagsController.text.trim(),
        'imageUrls': _imageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully')),
      );

      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _selectedCategory,
        'tags': _tagsController.text.trim(),
        'imageUrls': _imageUrls,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update post')),
      );
    }
  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final file = File(pickedFile.path);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('$fileName.jpg');

      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrls.add(downloadUrl);
      });

      Navigator.of(context).pop(); // Close the loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image added successfully')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  void _removeImage(String imageUrl) {
    setState(() {
      _imageUrls.remove(imageUrl);
    });
  }

  Future<void> _editPost() async {
    final updatedPost = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(
          postId: widget.postId,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          imageUrls: _imageUrls,
          tags: _tagsController.text.trim(),
        ),
      ),
    );

    if (updatedPost == null) return;

    setState(() {
      _titleController.text = updatedPost['title'];
      _contentController.text = updatedPost['content'];
      _selectedCategory = updatedPost['category'];
      _imageUrls.clear();
      _imageUrls.addAll(updatedPost['imageUrls']);
      _tagsController.text = updatedPost['tags'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: _selectedCategory),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Images',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _imageUrls.map((imageUrl) {
                  return Stack(
                    children: [
                      Image.network(
                        imageUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(imageUrl),
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _addImage,
                child: const Text('Add Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewPostPage extends StatefulWidget {
  final String postId;
  final String title;
  final String content;
  final String category;
  final List<String> imageUrls;
  String tags; // Remove 'final' to make it mutable

  ViewPostPage({
    super.key,
    required this.postId,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrls,
    required this.tags,
  });

  @override
  State<ViewPostPage> createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  late String _title;
  late String _content;
  late String _category;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _content = widget.content;
    _category = widget.category;
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
          imageUrls: widget.imageUrls,
          tags: widget.tags,
        ),
      ),
    );

    if (updatedPost != null) {
      // Update the state with the new data
      setState(() {
        _title = updatedPost['title'];
        _content = updatedPost['content'];
        _category = updatedPost['category'];
        widget.imageUrls.clear();
        widget.imageUrls.addAll(updatedPost['imageUrls']);
        widget.tags = updatedPost['tags'];
      });
    } else {
      // Optionally fetch the latest data from Firestore if no updates were made
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (postDoc.exists) {
        final postData = postDoc.data()!;
        setState(() {
          _title = postData['title'] ?? _title;
          _content = postData['content'] ?? _content;
          _category = postData['category'] ?? _category;
          widget.imageUrls.clear();
          widget.imageUrls
              .addAll(List<String>.from(postData['imageUrls'] ?? []));
          widget.tags = postData['tags'] ?? widget.tags;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_content),
              const SizedBox(height: 16),
              Text('Category: $_category'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.imageUrls.map((imageUrl) {
                  return Image.network(
                    imageUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
