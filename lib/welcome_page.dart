import 'package:flutter/material.dart';
import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback onComplete;

  const WelcomePage({super.key, required this.onComplete});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final location.Location _location = location.Location();
  location.PermissionStatus _locationPermission = location.PermissionStatus.denied;

  final List<String> _titles = [
    "Welcome to AgriTek!",
    "Learn Farming Techniques",
    "Connect with the Community",
    "Get Started Today!"
  ];

  final List<String> _descriptions = [
    "An app designed to make farming easy and efficient.",
    "Step-by-step guides for planting and harvesting.",
    "Share ideas and experiences with other farmers.",
    "Let’s grow together and achieve more."
  ];

  final List<String> _images = [
    'assets/images/agritek.png',
    'assets/images/welcome2.png',
    'assets/images/welcome3.png',
    'assets/images/welcome4.png'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Request Notification Permission
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications are already enabled.')),
      );
    } else if (status.isDenied || status.isLimited) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications enabled successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications permission denied.')),
        );
      }
    }
  }

  // Request Location Permissions
  Future<void> _requestPermissions() async {
    // Request Location Permission
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are required.')),
        );
        return;
      }
    }

    if (_locationPermission != location.PermissionStatus.granted) {
      final location.PermissionStatus locationPermissionResult =
          await _location.requestPermission();
      setState(() {
        _locationPermission = locationPermissionResult;
      });

      if (_locationPermission != location.PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required.')),
        );
        return;
      }
    }

    // Request Notification Permission after location permissions
    await _requestNotificationPermission();

    // Proceed after successful permission requests
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _titles.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image Section
                        SizedBox(
                          height: 200,
                          child: Image.asset(
                            _images[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Title Section
                        Text(
                          _titles[index],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        // Description Section
                        Text(
                          _descriptions[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _titles.length,
                (index) => _buildDot(index),
              ),
            ),
            const SizedBox(height: 30),
            // Next Button or Get Started Button
            if (_currentPage < _titles.length - 1)
              ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            if (_currentPage == _titles.length - 1)
              ElevatedButton(
                onPressed: _requestPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
