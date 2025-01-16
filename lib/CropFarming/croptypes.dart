import 'package:flutter/material.dart';

class TypeOfCropsScreen extends StatefulWidget {
  const TypeOfCropsScreen({super.key});

  @override
  TypeOfCropsScreenState createState() => TypeOfCropsScreenState();
}

class TypeOfCropsScreenState extends State<TypeOfCropsScreen> {
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
        title: const Text("Type of Crops"),
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
            '/images/vegetables.jpg',
            'Vegetables',
            'A plant or part of a plant used as food.',
            '/vegetables',
          ),
          _buildCropTile(
            '/images/fruits.jpg',
            'Fruits',
            'The sweet and fleshy product of a tree or other plant that contains seed and can be eaten as food.',
            '/fruits',
          ),
          _buildCropTile(
            '/images/grains.jpg',
            'Grains',
            'A seed or fruit of a cereal grass.',
            '/grains',
          ),
          _buildCropTile(
            '/images/legumes.jpg',
            'Legumes',
            'The fruit or seed of leguminous plants (as peas or beans) used for food.',
            '/legumes',
          ),
          _buildCropTile(
            '/images/grass.jpg',
            'Grass',
            'Green plants that grow in the ground, used as feed for animals or for lawns.',
            '/grass',
          ),
        ],
      ),
    );
  }
}
