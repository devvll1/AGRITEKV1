// ignore_for_file: prefer_const_constructors, unused_element, use_build_context_synchronously, deprecated_member_use

import 'package:agritek/Agricultural%20Guides/add_info.dart';
import 'package:agritek/Agricultural%20Guides/view_guides.dart';
import 'package:agritek/General/about_us.dart';
import 'package:agritek/General/privacy_policy.dart';
import 'package:agritek/General/terms_and_conditions.dart';
import 'package:agritek/Track/Plant%20Tracker/view_plant_tracker.dart';
import 'package:agritek/Updates/Market%20Price/view_market_price.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agritek/Forums/forumfeed.dart';
import 'package:agritek/Login/profile.dart';
import 'package:agritek/Updates/Weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? firstName;
  bool isLoading = true;

  // Weather-related state
  String weatherCondition = "Fetching...";
  String locationName = "Loading location...";
  double temperature = 0;
  double precipChance = 0;
  double lat = 0;
  double lon = 0;
  String currentTime = ''; // Add a field for the current time
  String currentDate = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _getCurrentLocation();
    _updateTime(); // Fetch the time when the widget is initialized
  }

  Future<void> _getCurrentLocation() async {
    Position position = await _determinePosition();
    lat = position.latitude;
    lon = position.longitude;

    // Fetch weather and location name
    await Future.wait([
      _fetchWeather(lat, lon),
      _fetchLocationName(lat, lon),
    ]);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check location services
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, cannot fetch location.');
    }

    // Return the current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    try {
      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,precipitation_probability';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Map weather code to description, default to 'Unknown' if not found
          weatherCondition = data['current_weather']?['weathercode'] != null
              ? {
                    0: 'Clear',
                    1: 'Mainly Clear',
                    2: 'Partly Cloudy',
                    3: 'Overcast',
                    45: 'Foggy',
                    48: 'Depositing Rime Fog',
                    51: 'Light Drizzle',
                    53: 'Moderate Drizzle',
                    55: 'Dense Drizzle',
                    56: 'Freezing Light Drizzle',
                    57: 'Freezing Dense Drizzle',
                    61: 'Slight Rain',
                    63: 'Moderate Rain',
                    65: 'Heavy Rain',
                    66: 'Freezing Light Rain',
                    67: 'Freezing Heavy Rain',
                    71: 'Slight Snow',
                    73: 'Moderate Snow',
                    75: 'Heavy Snow',
                    77: 'Snow Grains',
                    80: 'Slight Rain Showers',
                    81: 'Moderate Rain Showers',
                    82: 'Violent Rain Showers',
                    85: 'Slight Snow Showers',
                    86: 'Heavy Snow Showers',
                    95: 'Thunderstorm',
                    96: 'Thunderstorm with Slight Hail',
                    99: 'Thunderstorm with Heavy Hail',
                  }[data['current_weather']['weathercode']] ??
                  'Unknown'
              : 'Unknown'; // Default to 'Unknown' if weathercode is null

          temperature = data['current_weather']['temperature'];
          precipChance =
              (data['hourly']['precipitation_probability']?[0] ?? 0).toDouble();
          _updateTime(); // Update time when weather is fetched
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      setState(() {
        weatherCondition = 'Error fetching weather: $e';
      });
    }
  }

  Future<void> _fetchLocationName(double lat, double lon) async {
    final url =
        'https://api.opencagedata.com/geocode/v1/json?q=$lat+$lon&key=269b80706cd84223a9ac0155bb6b285c';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        final components = data['results'][0]['components'];
        String formattedLocation = '';

        if (components['city'] != null) {
          formattedLocation += components['city'] + ', ';
        } else if (components['town'] != null) {
          formattedLocation += components['town'] + ', ';
        }

        if (components['state'] != null) {
          formattedLocation += components['state'];
        } else if (components['region'] != null) {
          formattedLocation += components['region'];
        }

        locationName = formattedLocation.isNotEmpty
            ? formattedLocation
            : 'Unknown location';
        _updateTime();
      });
    } else {
      setState(() {
        locationName = 'Unknown location';
      });
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    final formattedDate =
        DateFormat('EEEE, d MMM').format(now); // Example: "Monday, 4 Oct"

    setState(() {
      currentTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      currentDate = formattedDate;
    });
  }

  void _showMoreOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text("More Options",
              style: TextStyle(fontFamily: 'Poppins')),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _showSignOutConfirmation(context); // Show sign-out confirmation
              },
              child: const Text("Sign Out",
                  style: TextStyle(fontFamily: 'Poppins')),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                // Add any other option you need
              },
              child: const Text("Option 2",
                  style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context); // Close the action sheet
            },
            child:
                const Text("Cancel", style: TextStyle(fontFamily: 'Poppins')),
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
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

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
        return await _showExitConfirmation(
            context); // Return the result of the confirmation dialog
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: isLoading
              ? const Text("Welcome!", style: TextStyle(fontFamily: 'Poppins'))
              : Text("Welcome ${firstName ?? ''}!",
                  style: const TextStyle(fontFamily: 'Poppins')),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: const Icon(CupertinoIcons.profile_circled,
                color: CupertinoColors.systemGreen),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'signOut') {
                      _showSignOutConfirmation(context);
                    } else if (value == 'exit') {
                      _showExitConfirmation(context);
                    } else if (value == 'addInformation') {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const AddInformationForm()),
                      );
                    } else if (value == 'aboutUs') {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const AboutUsPage()),
                      );
                    } else if (value == 'termsAndConditions') {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                const TermsAndConditionsPage()),
                      );
                    } else if (value == 'privacyPolicy') {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const PrivacyPolicyPage()),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      // const PopupMenuItem<String>(
                      //   value: 'signOut',
                      //   child: Text("Sign Out",
                      //       style: TextStyle(fontFamily: 'Poppins')),
                      // ),
                      // const PopupMenuItem<String>(
                      //   value: 'addInformation',
                      //   child: Text("Add Information",
                      //       style: TextStyle(fontFamily: 'Poppins')),
                      // ),
                      const PopupMenuItem<String>(
                        value: 'aboutUs',
                        child: Text("About Us",
                            style: TextStyle(fontFamily: 'Poppins')),
                      ),
                      const PopupMenuItem<String>(
                        value: 'termsAndConditions',
                        child: Text("Terms and Conditions",
                            style: TextStyle(fontFamily: 'Poppins')),
                      ),
                      const PopupMenuItem<String>(
                        value: 'privacyPolicy',
                        child: Text("Privacy Policy",
                            style: TextStyle(fontFamily: 'Poppins')),
                      ),
                      const PopupMenuItem<String>(
                        value: 'exit',
                        child: Text("Exit",
                            style: TextStyle(fontFamily: 'Poppins')),
                      ),
                    ];
                  },
                  child: const Icon(CupertinoIcons.ellipsis,
                      color: CupertinoColors.systemGreen),
                ),
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                const SizedBox(height: 5),

                // Weather Container
                isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 98, 45, 8)
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Current Weather",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                decoration: TextDecoration.none,
                                color: CupertinoColors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.cloud_sun,
                                  size: 50,
                                  color: Color.fromARGB(255, 255, 235, 13),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${temperature.toStringAsFixed(1)}°C",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                        color: CupertinoColors.white,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    Text(
                                      weatherCondition,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        color: CupertinoColors.white,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    Text(
                                      locationName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        color: CupertinoColors.white,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                CupertinoButton(
                                  padding: const EdgeInsets.all(22.0),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            const WeatherScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.activeGreen,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "See Forecast",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: CupertinoColors.white,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              " $currentDate",
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: CupertinoColors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),

                const SizedBox(height: 10),

                // Main Buttons Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuButton(
                        "Agricultural Guides",
                        context,
                        const ViewGuides(),
                        CupertinoIcons.book,
                        'assets/images/agricultural_guides.jpg',
                      ),
                      const SizedBox(height: 10),
                      _buildMenuButton(
                        "Community",
                        context,
                        const ForumsPage(),
                        CupertinoIcons.group,
                        'assets/images/forums.jpg',
                      ),
                      const SizedBox(height: 10),
                      _buildMenuButton(
                        "Updates",
                        context,
                        const ViewMarketPrice(),
                        CupertinoIcons.cart_fill,
                        'assets/images/updates.png',
                      ),
                      const SizedBox(height: 10),
                      _buildMenuButton(
                        "Track",
                        context,
                        const CalendarScreen(),
                        CupertinoIcons.calendar,
                        'assets/images/track.png',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "All rights Reserved.",
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
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
          title:
              const Text("Sign Out", style: TextStyle(fontFamily: 'Poppins')),
          content: const Text("Are you sure you want to sign out?",
              style: TextStyle(fontFamily: 'Poppins')),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without signing out
              },
              child:
                  const Text("Cancel", style: TextStyle(fontFamily: 'Poppins')),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true, // Highlights the destructive action
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                FirebaseAuth.instance.signOut(); // Sign out the user
                Navigator.pushReplacementNamed(
                    context, '/login'); // Navigate to the login screen
              },
              child: const Text("Sign Out",
                  style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuButton(String title, BuildContext context, Widget page,
      IconData icon, String imagePath,
      {String? category}) {
    return Container(
      width: double.infinity, // Ensures the container fills the row
      height: 100, // Increased height for the button
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath), // Background image
          fit: BoxFit.cover, // Ensures the image fills the container
        ),
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      child: CupertinoButton(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => page),
          );
        },
        padding: EdgeInsets.zero, // Remove default padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: CupertinoColors.white), // Icon color
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white, // Text color
                fontSize: 12, // Reduced font size
                fontFamily: 'Poppins',
              ),
            ),
            if (category != null &&
                category.isNotEmpty) // Conditionally render category
              Text(
                category,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: CupertinoColors.white, // Text color
                  fontSize: 10, // Smaller font size for category
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
  final shouldExit = await showCupertinoDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title:
                const Text("Exit App", style: TextStyle(fontFamily: 'Poppins')),
            content: const Text("Are you sure you want to exit the app?",
                style: TextStyle(fontFamily: 'Poppins')),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); // Return false (do not exit)
                },
                child: const Text("Cancel",
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true, // Highlights the destructive action
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true (exit the app)
                },
                child:
                    const Text("Exit", style: TextStyle(fontFamily: 'Poppins')),
              ),
            ],
          );
        },
      ) ??
      false; // Default to false if the dialog is dismissed

  if (shouldExit) {
    // Exit the app
    SystemNavigator.pop(); // Closes the app
  }

  return shouldExit;
}
