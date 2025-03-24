import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  String? selectedFarmerType;

  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool _isUserLoggedIn = false;

  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> farmerTypes = [
    'Crop Farmer',
    'Livestock Farmer',
    'Aquaculture Farmer',
    'Forestry Farmer',
    'Mixed Farmer',
    'Aspiring Farmer'
  ];

  @override
  void initState() {
    super.initState();
    _requestAllPermissions();
    _loadUserData();
  }

  Future<void> _requestAllPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.photos, // iOS photo gallery access
        Permission.camera, // Camera access
        Permission.mediaLibrary, // iOS media library access
      ].request();

      statuses.forEach((permission, status) {
        if (status.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Permission for $permission is permanently denied. Please enable it in app settings.',
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting permissions: $e')),
      );
    }
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _isUserLoggedIn = false;
          isLoading = false;
        });
        return;
      }

      setState(() {
        _isUserLoggedIn = true;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data();
          _initializeControllers();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile data not found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    _controllers['firstName'] =
        TextEditingController(text: userData?['firstName']);
    _controllers['middleName'] =
        TextEditingController(text: userData?['middleName'] ?? '');
    _controllers['lastName'] =
        TextEditingController(text: userData?['lastName']);
    _controllers['age'] = TextEditingController(text: userData?['age']);
    _controllers['address'] = TextEditingController(text: userData?['address']);
    selectedFarmerType = userData?['farmerType'];
  }

  Future<void> _pickImage() async {
    await _requestAllPermissions();

    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> _uploadImageAndSaveProfile(String userId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      final uploadTask = await storageRef.putFile(_profileImage!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
        return;
      }

      final updatedData = {
        'firstName': _controllers['firstName']!.text.trim(),
        'middleName': _controllers['middleName']!.text.trim(),
        'lastName': _controllers['lastName']!.text.trim(),
        'age': _controllers['age']!.text.trim(),
        'address': _controllers['address']!.text.trim(),
        'farmerType': selectedFarmerType,
      };

      if (_profileImage != null) {
        final profileImageUrl = await _uploadImageAndSaveProfile(user.uid);
        if (profileImageUrl != null) {
          updatedData['profileImageUrl'] = profileImageUrl;
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(
          context, '/login'); // Navigate to login screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget _buildProfileForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              'Edit Your Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (userData?['profileImageUrl'] != null
                            ? NetworkImage(userData!['profileImageUrl'])
                            : const AssetImage(
                                'assets/images/defaultprofile.png'))
                        as ImageProvider,
                child: _profileImage == null
                    ? const Icon(CupertinoIcons.camera, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildEditableField('First Name', 'firstName'),
                  _buildEditableField('Middle Name', 'middleName'),
                  _buildEditableField('Last Name', 'lastName'),
                  _buildEditableField('Age', 'age'),
                  _buildEditableField('Address', 'address'),
                  _buildDropdownField('Farmer Type'),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(CupertinoIcons.check_mark, size: 16),
                  label: const Text('Save Changes',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(CupertinoIcons.arrow_right_circle_fill,
                      size: 16),
                  label: const Text('Sign Out', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) {
              if (value == 'change_email_password') {
                Navigator.pushNamed(context, '/changePassword');
              } else if (value == 'delete_account') {
                _deleteAccount();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'change_email_password',
                child: Text('Change Email and Password'),
              ),
              const PopupMenuItem(
                value: 'delete_account',
                child: Text('Delete Account'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isUserLoggedIn
              ? userData == null
                  ? const Center(child: Text('No profile data available.'))
                  : _buildProfileForm()
              : _buildLoginPrompt(),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        Navigator.pushReplacementNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: $e')),
      );
    }
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'You are not logged in.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedFarmerType,
        items: farmerTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onChanged: (value) {
          setState(() {
            selectedFarmerType = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a $label.';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
