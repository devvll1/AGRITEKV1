import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewGuides extends StatelessWidget { // Renamed from ViewCrops to ViewGuides
  const ViewGuides({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final agricultureCategories = [
      {'name': 'Crop Farming', 'image': 'assets/images/cropfarming.jpg'},
      {'name': 'Livestock', 'image': 'assets/images/livestock.jpeg'},
      {'name': 'Aquaculture', 'image': 'assets/images/aquaculture.jpg'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agriculture Categories'),
      ),
      body: ListView.builder(
        itemCount: agricultureCategories.length,
        itemBuilder: (context, index) {
          final category = agricultureCategories[index];
          return GestureDetector(
            onTap: () {
              if (category['name'] == 'Crop Farming') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CropFarmingViewer(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TitleViewer(category: category['name']!),
                  ),
                );
              }
            },
            child: Container(
              height: 150, // Enlarged height for each item
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(category['image']!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black
                          .withOpacity(0.4), // Dark overlay for text visibility
                    ),
                  ),
                  Center(
                    child: Text(
                      category['name']!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CropFarmingViewer extends StatelessWidget {
  const CropFarmingViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cropCategories = [
      {'name': 'Fruits', 'image': 'assets/images/fruits.jpg'},
      {'name': 'Grains', 'image': 'assets/images/grains.jpg'},
      {'name': 'Spices', 'image': 'assets/images/spices.jpg'},
      {'name': 'Root Crops', 'image': 'assets/images/root_crops.jpg'},
      {
        'name': 'Highland Vegetables',
        'image': 'assets/images/highland_vegetables.png'
      },
      {
        'name': 'Lowland Vegetables',
        'image': 'assets/images/lowland_vegetables.png'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Farming Categories'),
      ),
      body: ListView.builder(
        itemCount: cropCategories.length,
        itemBuilder: (context, index) {
          final category = cropCategories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TitleViewer(
                    category: 'Crop Farming',
                    cropCategory: category['name'],
                  ),
                ),
              );
            },
            child: Container(
              height: 150, // Enlarged height for each item
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(category['image']!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black
                          .withOpacity(0.4), // Dark overlay for text visibility
                    ),
                  ),
                  Center(
                    child: Text(
                      category['name']!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TitleViewer extends StatelessWidget {
  final String category;
  final String? cropCategory;

  const TitleViewer({Key? key, required this.category, this.cropCategory})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cropCategory ?? category),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('agriculture_guides')
            .where('category', isEqualTo: category)
            .where('cropCategory', isEqualTo: cropCategory)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data available.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final imageUrl = doc['titleImage'] ??
                  ''; // Assuming `titleImage` is stored in Firestore
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoViewer(docId: doc.id),
                    ),
                  );
                },
                child: Container(
                  height: 150, // Enlarged height for each item
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black.withOpacity(
                              0.4), // Dark overlay for text visibility
                        ),
                      ),
                      Center(
                        child: Text(
                          doc['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class InfoViewer extends StatelessWidget {
  final String docId;

  const InfoViewer({Key? key, required this.docId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('agriculture_guides')
            .doc(docId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No details available.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final sections = data['sections'] as List<dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                data['title'] ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...sections.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section['heading'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(section['content'] ?? ''),
                    const SizedBox(height: 8),
                    if (section['image'] != null)
                      Image.network(
                        section['image'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}