import 'package:flutter/material.dart';

class LiveStockListScreen extends StatefulWidget {
  const LiveStockListScreen({super.key});

  @override
  LiveStockListScreenState createState() => LiveStockListScreenState();
}

class LiveStockListScreenState extends State<LiveStockListScreen> {
  int _selectedIndex = 0;

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        // Navigate to Forums or other screen if needed
        break;
      case 2:
        // Navigate to Updates or other screen if needed
        break;
    }
  }

  Widget _buildCropTile(String imagePath, String title, String subtitle, String routeName) {
    return Column(
      children: [
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8), // Adjusts for a square crop
            child: Image.asset(
              imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover, // Crops and fits the image within the container
            ),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.more_vert),
          onTap: () {
            Navigator.pushNamed(context, routeName);
          },
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Livestocks"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Handle bookmark action
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options action
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildCropTile(
            'images/livestock/chicken.png',
            'Chicken',
            'Gallus gallus domesticus',
            '/chicken',
          ),
          
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavItemTapped,
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
