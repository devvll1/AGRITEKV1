import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddInformationForm extends StatefulWidget {
  const AddInformationForm({Key? key}) : super(key: key);

  @override
  _AddInformationFormState createState() => _AddInformationFormState();
}

class _AddInformationFormState extends State<AddInformationForm> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _selectedBranch;
  String? _selectedCropCategory;
  List<Map<String, dynamic>> _sections = [];
  File? _titleImageFile; // File for the title image

  final List<String> _branches = ['Crop Farming', 'Livestock', 'Aquaculture'];
  final Map<String, List<String>> _cropCategories = {
    'Crop Farming': [
      'Fruits',
      'Grains',
      'Spices',
      'Root Crops',
      'Highland Vegetables',
      'Lowland Vegetables'
    ],
  };

  // Map to associate categories with images
  final Map<String, String> _categoryImages = {
    'Fruits': 'assets/images/fruits.jpg',
    'Grains': 'assets/images/grains.jpg',
    'Spices': 'assets/images/spices.jpg',
    'Root Crops': 'assets/images/root_crops.jpg',
    'Highland Vegetables': 'assets/images/highland_vegetables.png',
    'Lowland Vegetables': 'assets/images/lowland_vegetables.jpg',
  };

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          FirebaseStorage.instance.ref().child("images/$fileName.jpg");
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }

  Future<void> _saveToFirebase(BuildContext context) async {
    try {
      // Upload title image
      String? titleImageUrl;
      if (_titleImageFile != null) {
        titleImageUrl = await uploadImage(_titleImageFile!);
      }

      // Upload images for each section and update the sections list
      for (var section in _sections) {
        if (section['imageFile'] != null) {
          String? imageUrl = await uploadImage(section['imageFile']);
          section['image'] = imageUrl;
          section.remove('imageFile'); // Remove the local file reference
        }
      }

      // Save data to Firestore
      await FirebaseFirestore.instance.collection('agriculture_guides').add({
        'title': _title,
        'titleImage': titleImageUrl,
        'category': _selectedBranch,
        'cropCategory': _selectedCropCategory,
        'sections': _sections,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );

      // Reset the form
      setState(() {
        _formKey.currentState!.reset();
        _sections = [];
        _titleImageFile = null;
        _selectedCropCategory = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit form: $e')),
      );
    }
  }

  Future<void> _pickTitleImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _titleImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickSectionImage(int index) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _sections[index]['imageFile'] = File(pickedFile.path);
      });
    }
  }

  void _addSection() {
    setState(() {
      _sections.add({'heading': '', 'content': '', 'imageFile': null});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _title = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _pickTitleImage,
                  child: const Text('Pick Title Image'),
                ),
                if (_titleImageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(
                      _titleImageFile!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Branch of Agriculture',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedBranch,
                  items: _branches.map((branch) {
                    return DropdownMenuItem(
                      value: branch,
                      child: Text(branch),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBranch = value;
                      _selectedCropCategory = null; // Reset crop category
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a branch of agriculture';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedBranch == 'Crop Farming')
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Crop Category',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCropCategory,
                    items: _cropCategories['Crop Farming']!.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCropCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a crop category';
                      }
                      return null;
                    },
                  ),
                if (_selectedCropCategory != null &&
                    _categoryImages.containsKey(_selectedCropCategory!))
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Image.asset(
                      _categoryImages[_selectedCropCategory!]!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addSection,
                  child: const Text('Add Section'),
                ),
                const SizedBox(height: 16),
                ..._sections.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> section = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Section Heading ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          section['heading'] = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a heading for section ${index + 1}';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Section Content ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          section['content'] = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter content for section ${index + 1}';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _pickSectionImage(index),
                        child: const Text('Pick Section Image'),
                      ),
                      if (section['imageFile'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.file(
                            section['imageFile'],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveToFirebase(context);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
