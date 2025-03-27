import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewCrops extends StatelessWidget {
  const ViewCrops({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agriculture Categories'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Crop Farming'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CropFarmingViewer(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Livestock'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const TitleViewer(category: 'Livestock'),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Aquaculture'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const TitleViewer(category: 'Aquaculture'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CropFarmingViewer extends StatelessWidget {
  const CropFarmingViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cropCategories = [
      'Fruits',
      'Grains',
      'Spices',
      'Root Crops',
      'Highland Vegetables',
      'Lowland Vegetables'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Farming Categories'),
      ),
      body: ListView.builder(
        itemCount: cropCategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cropCategories[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TitleViewer(
                    category: 'Crop Farming',
                    cropCategory: cropCategories[index],
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
              return ListTile(
                title: Text(doc['title']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoViewer(docId: doc.id),
                    ),
                  );
                },
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
