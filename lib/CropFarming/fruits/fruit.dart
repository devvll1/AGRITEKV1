import 'package:flutter/material.dart';

void main() {
  runApp(const FruitsApp());
}

class FruitsApp extends StatelessWidget {
  const FruitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FruitsScreen();
  }
}

class FruitsScreen extends StatelessWidget {
  final List<Map<String, String>> fruits = [
    {'name': 'Mango', 'image': 'images/fruits/mango.jpg'},
  ];

  FruitsScreen({super.key});

  void _onBottomNavItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home'); // Replace with actual HomePage
        break;
      case 1:
        // Handle navigation to Forums
        break;
      case 2:
        // Handle navigation to Updates
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruits'),
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
                  'Choose a Fruit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: fruits.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.all(19.0),
                  leading: Image.asset(
                    fruits[index]['image']!,
                    width: 80,
                    height: 100, // Increased height for the image
                    fit: BoxFit.cover,
                  ),
                  title: Text(fruits[index]['name']!),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () {
                    // Navigate to details page or perform action
                    if (fruits[index]['name'] ==
                        'Mango') {
                      Navigator.pushNamed(context, '/mango');
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
