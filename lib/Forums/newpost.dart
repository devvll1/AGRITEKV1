import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final TextEditingController _tagController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  String? _selectedCategory;
  List<File> _selectedImages = [];
  bool _isSubmitting = false;
  String? _profileImageUrl;
  String? _userName;

  final List<String> _categories = [
    'Crop Farming',
    'Livestock',
    'Aquaculture',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _profileImageUrl = userDoc.data()?['profileImageUrl'];
          _userName =
              '${userDoc.data()?['firstName']} ${userDoc.data()?['lastName']}';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  void _showFullScreenImage(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Image.file(image),
          ),
        ),
      ),
    );
  }

  Future<List<String>> _uploadImages(String docId) async {
    List<String> imageUrls = [];
    try {
      for (var image in _selectedImages) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child('$docId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = await storageRef.putFile(image);
        final imageUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading images: $e')),
      );
    }
    return imageUrls;
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty ||
        _selectedCategory == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill in all required fields.'),
          actions: [
            TextButton(
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
      final docRef = FirebaseFirestore.instance.collection('posts').doc();

      final postData = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _selectedCategory,
        'tags': _tagController.text.trim(),
        'author': user?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrls': [], // Placeholder for image URLs
      };

      await docRef.set(postData);

      if (_selectedImages.isNotEmpty) {
        final imageUrls = await _uploadImages(docRef.id);
        await docRef.update({'imageUrls': imageUrls});
      }

      Navigator.of(context).pop('Post Added');
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to submit post: $e'),
          actions: [
            TextButton(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : const AssetImage('assets/images/defaultprofile.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _userName ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title Field
              const Text('Title', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _titleController,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Enter a title (max 200 characters)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category and Tag Fields
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category', style: TextStyle(fontSize: 18)),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          hint: const Text('Choose a Category'),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add a Tag', style: TextStyle(fontSize: 18)),
                        TextField(
                          controller: _tagController,
                          decoration: InputDecoration(
                            hintText: 'Enter a hashtag',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Content Field
              const Text('Content', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _contentController,
                maxLength: 2500,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write a description (max 2500 characters)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Attach Images Section
              Row(
                children: [
                  // Add Images Button
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Add Images',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Display Selected Images
                  if (_selectedImages.isNotEmpty)
                    Expanded(
                      child: Row(
                        children: List.generate(
                          _selectedImages.length > 3
                              ? 3
                              : _selectedImages.length,
                          (index) {
                            if (index == 2 && _selectedImages.length > 3) {
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showFullScreenImage(
                                        _selectedImages[index]),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image:
                                              FileImage(_selectedImages[index]),
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
                                        '+${_selectedImages.length - 2}',
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
                                onTap: () => _showFullScreenImage(
                                    _selectedImages[index]),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_selectedImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Submit Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Submit Post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
