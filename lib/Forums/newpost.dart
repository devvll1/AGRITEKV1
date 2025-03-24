import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  String? _selectedCategory;
  File? _selectedImage;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Crop Farming',
    'Livestock',
    'Aquafisheries'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image, String docId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child('$docId.jpg'); // Use docId to uniquely name the image
      final uploadTask = await storageRef.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty ||
        _selectedCategory == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill in all required fields.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create a new document in the "posts" collection
      final docRef = FirebaseFirestore.instance.collection('posts').doc();

      // Build the post data
      final postData = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _selectedCategory,
        'author': user?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': '', // Placeholder for image URL
      };

      // Save the initial document
      await docRef.set(postData);

      // If an image is selected, upload it and update the document
      if (_selectedImage != null) {
        final imageUrl = await _uploadImage(_selectedImage!, docRef.id);
        if (imageUrl != null) {
          await docRef.update({'imageUrl': imageUrl});
        }
      }

      Navigator.of(context).pop('Post Added'); // Notify parent of success
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Failed to submit post: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showCategorySelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select a Category'),
        actions: _categories.map((category) {
          return CupertinoActionSheetAction(
            child: Text(category),
            onPressed: () {
              setState(() {
                _selectedCategory = category;
              });
              Navigator.of(context).pop();
            },
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Add New Post'),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.black,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category', style: TextStyle(fontSize: 18)),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _showCategorySelector,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.inactiveGray),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedCategory ?? 'Select a category',
                      style: TextStyle(
                        color: _selectedCategory == null
                            ? CupertinoColors.inactiveGray
                            : CupertinoColors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Title', style: TextStyle(fontSize: 18)),
                CupertinoTextField(
                  controller: _titleController,
                  maxLength: 200,
                  placeholder: 'Enter a title (max 200 characters)',
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.inactiveGray),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Content', style: TextStyle(fontSize: 18)),
                CupertinoTextField(
                  controller: _contentController,
                  maxLength: 2500,
                  placeholder: 'Write a description (max 2500 characters)',
                  maxLines: 5,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.inactiveGray),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Attach Image', style: TextStyle(fontSize: 18)),
                CupertinoButton(
                  child: const Text('Select Image'),
                  onPressed: _pickImage,
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.file(_selectedImage!, height: 150),
                  ),
                const Spacer(),
                CupertinoButton.filled(
                  onPressed: _isSubmitting ? null : _submitPost,
                  child: _isSubmitting
                      ? const CupertinoActivityIndicator()
                      : const Text('Submit Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
