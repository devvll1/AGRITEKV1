import 'package:flutter/material.dart';

void main() {
  runApp(const LegumesApp());
}

class LegumesApp extends StatelessWidget {
  const LegumesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LegumesScreen();
  }
}

class LegumesScreen extends StatelessWidget {
  final List<Map<String, String>> legumes = [
    {'name': 'Mango', 'image': 'images/legumes/mango.jpg'},
    {'name': 'Upo (Bottle Gourd)', 'image': 'images/Upo.jpg'},
    {'name': 'Sayote (Chayote)', 'image': 'images/Sayote.jpg'},
    {'name': 'Talong (Eggplant)', 'image': 'images/Talong.jpg'},
    {'name': 'Okra', 'image': 'images/Okra.jpg'},
  ];

  LegumesScreen({super.key});

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
        title: const Text('Legumes'),
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
              itemCount: legumes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.all(19.0),
                  leading: Image.asset(
                    legumes[index]['image']!,
                    width: 80,
                    height: 100, // Increased height for the image
                    fit: BoxFit.cover,
                  ),
                  title: Text(legumes[index]['name']!),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () {
                    // Navigate to details page or perform action
                    if (legumes[index]['name'] ==
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
