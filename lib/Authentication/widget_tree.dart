import 'package:agritek/Authentication/auth.dart';
import 'package:agritek/homepage.dart';
import 'package:agritek/Login/login.dart';
import 'package:agritek/welcome_page.dart'; // Import your WelcomePage
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  bool _showWelcomePage = true; // Tracks if the WelcomePage should be shown

  @override
  void initState() {
    super.initState();
    _checkWelcomePageStatus(); // Check if the user has already seen the WelcomePage
  }

  // Check if the WelcomePage has been shown previously
  Future<void> _checkWelcomePageStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Get the saved flag to determine whether to show the WelcomePage
      _showWelcomePage = prefs.getBool('hasSeenWelcomePage') ?? true;
    });
  }

  // Mark the WelcomePage as seen
  Future<void> _markWelcomePageSeen() async {
    final prefs = await SharedPreferences.getInstance();
    // Save the flag to indicate the WelcomePage has been seen
    await prefs.setBool('hasSeenWelcomePage', false);
  }

  @override
  Widget build(BuildContext context) {
    // Show the WelcomePage if it hasn't been seen yet
    if (_showWelcomePage) {
      return WelcomePage(
        onComplete: () async {
          // Mark the WelcomePage as seen and update the state
          await _markWelcomePageSeen();
          setState(() {
            _showWelcomePage = false; // This triggers the build again to move forward
          });
        },
      );
    }

    // After the WelcomePage is completed, proceed with the regular app flow
    return StreamBuilder(
      stream: Auth().authStateChanges, // Listen to the authentication state
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // If the user is authenticated, navigate to the HomePage
          return const HomePage();
        } else {
          // If the user is not authenticated, navigate to the StartupPage (Login/Register)
          return const StartupPage();
        }
      },
    );
  }
}
