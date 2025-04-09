// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? selectedFarmerType;
  final List<String> farmerTypes = [
    'Crop Farmer',
    'Livestock Farmer',
    'Mixed Farmer',
    'Aquaculture Farmer',
    'Forestry Farmer',
    'Aspiring Farmer'
  ];

  void registerUser() async {
    final String firstName = _firstNameController.text.trim();
    final String middleName = _middleNameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String age = _ageController.text.trim();
    final String address = _addressController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        age.isEmpty ||
        address.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        selectedFarmerType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match. Please ensure both fields are identical.',
            style: TextStyle(color: Colors.red),
          ),
          backgroundColor: Colors.white,
        ),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'middleName': middleName,
          'lastName': lastName,
          'age': age,
          'address': address,
          'farmerType': selectedFarmerType,
          'email': email,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully! Welcome to Agritek!',
              style: TextStyle(color: Colors.green),
            ),
            backgroundColor: Colors.white,
          ),
        );

        Navigator.pushNamed(context, '/homepage');
      }
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'The email address is already in use.';
        } else if (e.code == 'weak-password') {
          errorMessage =
              'The password is too weak. Please use a stronger password.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is invalid.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $errorMessage',
            style: const TextStyle(color: Colors.red),
          ),
          backgroundColor: Colors.white,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Setup"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Set up your profile",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                    labelText: 'First Name', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(
                controller: _middleNameController,
                decoration: const InputDecoration(
                    labelText: 'Middle Name (Optional)',
                    border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                    labelText: 'Last Name', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Age', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                    labelText: 'Address', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedFarmerType,
              items: farmerTypes
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => selectedFarmerType = value),
              decoration: const InputDecoration(
                  labelText: 'Type of Farmer', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder())),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: registerUser,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Register & Save Profile',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
