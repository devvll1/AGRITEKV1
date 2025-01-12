import 'package:flutter/material.dart';

void main() {
  runApp(const GrainsApp());
}

class GrainsApp extends StatelessWidget {
  const GrainsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GrainsScreen();
  }
}

class GrainsScreen extends StatelessWidget {
  final List<Map<String, String>> grains = [
    {'name': 'Corn', 'image': 'images/grains/corn.jpg'},
  ];

  GrainsScreen({super.key});

  void _onBottomNavItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home'); // Replace with actual HomePage
        break;
      case 1:

        break;
      case 2:
        Navigator.pushNamed(context, '/weather');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grains'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Add bookmark functionality here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose a Grain',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: grains.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.all(19.0),
                  leading: Image.asset(
                    grains[index]['image']!,
                    width: 80,
                    height: 100, // Increased height for the image
                    fit: BoxFit.cover,
                  ),
                  title: Text(grains[index]['name']!),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () {
                    // Navigate to details page or perform action
                    if (grains[index]['name'] ==
                        'Corn') {
                      Navigator.pushNamed(context, '/corn');
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onBottomNavItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_module),
            label: 'Modules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forums',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Updates',
          ),
        ],
      ),
    );
  }
}
