import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Corn extends StatelessWidget {
  const Corn({super.key});

  @override
  Widget build(BuildContext context) {
    return const CornDetailScreen();
  }
}

class CornDetailScreen extends StatefulWidget {
  const CornDetailScreen({super.key});

  @override
  CornDetailScreenState createState() => CornDetailScreenState();
}

class CornDetailScreenState extends State<CornDetailScreen> {

   final storage = FirebaseStorage.instance;
    // URLs for Firebase images
    late List<String> imageUrls;
    late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text:
          "Corn, cereal plant of the grass family (Poaceae) and its edible grain. The domesticated crop originated in the Americas and is one of the most widely distributed of the world’s food crops. Corn is used as livestock feed, as human food, as biofuel, and as raw material in industry."
          );
    
    imageUrls = List.filled(15, ''); // Initialize with empty strings
    getImagesFromFirebase();
  }

 Future<void> getImagesFromFirebase() async {
    List<String> imageNames = [
      '1.png', '2.png', '3.png',
    ];

    for (int i = 0; i < imageNames.length; i++) {
      final ref = storage.ref().child('CropFarming/grains/Corn/${imageNames[i]}');
      final url = await ref.getDownloadURL();
      setState(() {
        imageUrls[i] = url;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onBottomNavItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        // Handle other navigation items if needed
        break;
      case 2:
        // Handle other navigation items if needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grains'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Proper back navigation
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Add bookmark functionality here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Image.asset(
                      'images/grains/Corn.jpg',
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Corn',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Zea Mays',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Published date',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _descriptionController.text,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Materials and Tools Needed:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Corn Seeds\n'
              '• Plow\n'
              '• Harrow\n',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Step-by-Step Guide to Planting Corn:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTitleCard(
                'Land Preparation'),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'a.  Plow at a depth of 15-20 cm when soil moisture is right.  That is, when soil particles 15 cm below the surface separate and only thin portion sticks to the finger but no ball is formed.  Harrow twice with 2-3 passing to break the clods.\n'
                'b.  If a disc plow is used, plow under corn stubbles at a depth of 18-20 cm.  Use a disc plow to enable you to use corn stubbles as additional source of fertilizer.  Clayey and weedy fields require two or more plowing and several harrowing. \n'
                'c. Make furrows a day before or on the day of planting spaced at 75 cm and 8 cm deep. \n'
                'd. Ensure that the soil has been irrigated or rain-fed prior to planting for uniformity and promotion of seedling emergence. ',                
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
             _buildStepCard(
                'Planting', imageUrls[0]),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'a. Plant 1-2 seeds per hill, spaced at 25 cm apart and 3-5 cm deep.\n'
                'b. When available, use mechanical planters for more uniform depth of planting and consequent germination. \n ',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            _buildStepCard('Thinning',imageUrls[1]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'a. Thin seedlings to one plant per hill about 7-10 days after emergence.  Thinning out of undesirable seedling eases out overcrowding, which allows better penetration of sunlight, permits proper aeration and minimizes nutrient competition. \n'
                'b. Thinning is the removal of excess or undesirable seedlings.\n'
                'c. To minimize pest and disease problems, plant at almost the same period as farmers do nearby. ',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text(
              'Explore More Guides',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildGuideCard('Corn Farming: How to Grow Corn',
                'Feb 15, 2016 - 4:45', 'images/guide1.png'),
            _buildGuideCard(
                'Corn Farming: How to Grow Corn or Bittergourd',
                'Feb 16, 2016 - 4:45',
                'images/guide2.png'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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

  Widget _buildStepCard(String stepTitle, String imageUrl) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              stepTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          imageUrl.isNotEmpty
              ? SizedBox(
                  width: double.infinity, // Fill the width of the device
                  child: Image.network(  
                    imageUrl,
                    height: 250,
                    fit: BoxFit.cover, // Adjust this to fit your needs
                  ),
                )
              : const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                ),
        ],
      ),
    )
   );
  }
}


  Widget _buildTitleCard(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(String title, String date, String imagePath) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        title: Text(title),
        subtitle: Text(date),
        onTap: () {
          // Handle guide tap
        },
      ),
    );
  }
