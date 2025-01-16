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
  ];

  LegumesScreen({super.key});

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
    );
  }
}
