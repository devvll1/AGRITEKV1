import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agritek/Forums/forumfeed.dart';
import 'package:agritek/Login/profile.dart';
import 'package:agritek/Track/calendar.dart';
import 'package:agritek/Updates/weather.dart';
import 'package:agritek/farmguide.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? firstName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _showMoreOptions(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text("More Options", style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showSignOutConfirmation(context); // Show sign-out confirmation
            },
            child: const Text("Sign Out", style: TextStyle(fontFamily: 'Poppins')),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Add any other option you need
              print("Option 2 selected");
            },
            child: const Text("Option 2", style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context); // Close the action sheet
          },
          child: const Text("Cancel", style: TextStyle(fontFamily: 'Poppins')),
        ),
      );
    },
  );
}



  Future<void> _fetchUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
      // User skipped login; do nothing or load default behavior
      setState(() {
        firstName = "Guest";
        isLoading = false;
      });
      return;
    }

      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (snapshot.exists) {
        setState(() {
          firstName = snapshot.data()?['firstName'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await _showExitConfirmation(context);
        return shouldExit;
      },
      child: CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: isLoading
            ? const Text("Welcome!", style: TextStyle(fontFamily: 'Poppins'))
            : Text("Welcome ${firstName ?? ''}!", style: const TextStyle(fontFamily: 'Poppins')),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const ProfilePage()),
            );
          },
          child: const Icon(CupertinoIcons.profile_circled, color: CupertinoColors.systemGreen),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent, // Transparent material for just the button
              child: PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'signOut') {
                    _showSignOutConfirmation(context); // Show sign-out confirmation
                  } else {
                    print("Option 2 selected");
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'signOut',
                      child: Text("Sign Out", style: TextStyle(fontFamily: 'Poppins')),
                    ),
                    const PopupMenuItem<String>(
                      value: 'option',
                      child: Text("Option", style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ];
                },
                child: const Icon(CupertinoIcons.ellipsis, color: CupertinoColors.systemGreen),
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            const Text(
              "AGRITEK",
              style: TextStyle(
                fontSize: 28,
                color: CupertinoColors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                decoration: TextDecoration.none,
              ),
            ),
            const Text(
              "Your Farming Companion",
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
                fontFamily: 'Poppins',
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                children: [
                  _buildMenuButton("Agricultural Guides", context, const FarmGuidePage(), CupertinoIcons.book),
                  _buildMenuButton("Community", context, const ForumsPage(), CupertinoIcons.group),
                  _buildMenuButton("Updates", context, const WeatherScreen(), CupertinoIcons.cloud),
                  _buildMenuButton("Track", context, const CalendarScreen(), CupertinoIcons.calendar),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    onPressed: () {},
                    child: const Text("Contact us", style: TextStyle(fontFamily: 'Poppins')),
                  ),
                  const Text(
                    " | ",
                    style: TextStyle(
                      fontSize: 25,
                      decoration: TextDecoration.none,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {},
                    child: const Text("About Us", style: TextStyle(fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
            const Text(
              "All rights Reserved.",
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Poppins',
                decoration: TextDecoration.none,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Sign Out", style: TextStyle(fontFamily: 'Poppins')),
          content: const Text("Are you sure you want to sign out?", style: TextStyle(fontFamily: 'Poppins')),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without signing out
              },
              child: const Text("Cancel", style: TextStyle(fontFamily: 'Poppins')),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true, // Highlights the destructive action
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                FirebaseAuth.instance.signOut(); // Sign out the user
                Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login screen
              },
              child: const Text("Sign Out", style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuButton(String title, BuildContext context, Widget page, IconData icon) {
    return AspectRatio(
      aspectRatio: 1,
      child: CupertinoButton(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => page),
          );
        },
        color: CupertinoColors.systemGrey4,
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: CupertinoColors.systemGreen),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _showExitConfirmation(BuildContext context) async {
  bool shouldExit = false;
  await showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text("Exit App", style: TextStyle(fontFamily: 'Poppins')),
        content: const Text("Are you sure you want to exit the app?", style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              shouldExit = false; // Do not exit the app
            },
            child: const Text("Cancel", style: TextStyle(fontFamily: 'Poppins')),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true, // Highlights the destructive action
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              shouldExit = true; // Allow exiting the app
            },
            child: const Text("Exit", style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      );
    },
  );
  return shouldExit;
}