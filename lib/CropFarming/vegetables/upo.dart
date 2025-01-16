import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Upo extends StatelessWidget {
  const Upo({super.key});

  @override
  Widget build(BuildContext context) {
    return const UpoDetailScreen();
  }
}

class UpoDetailScreen extends StatefulWidget {
  const UpoDetailScreen({super.key});

  @override
  UpoDetailScreenState createState() => UpoDetailScreenState();
}

class UpoDetailScreenState extends State<UpoDetailScreen> {

   final storage = FirebaseStorage.instance;
    // URLs for Firebase images
    late List<String> imageUrls;
    late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text:
          "Upo, also known as bottle gourd or calabash, is a popular vegetable in many parts of the world. It is a long, cylindrical-shaped vegetable that can grow up to 60 cm in length and has a pale green color. Upo is a warm-season crop that can be grown in most tropical and subtropical regions. It is rich in vitamins, minerals, and fiber, making it a healthy addition to any diet."
          );
    
    imageUrls = List.filled(15, ''); // Initialize with empty strings
    getImagesFromFirebase();
  }

 Future<void> getImagesFromFirebase() async {
    List<String> imageNames = [
      '1.png', '2.png', '3.png', '4.png', '5.png',
    ];

    for (int i = 0; i < imageNames.length; i++) {
      final ref = storage.ref().child('CropFarming/vegetables/Upo/${imageNames[i]}');
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
        title: const Text('Vegetables'),
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
                      '/images/Upo.jpg',
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
                            'Upo (Bottle Gourd)',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lagenaria siceraria',
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
              '• Upo Seeds\n'
              '• Straw\n'
              '• Bamboos\n'
              '• Wires\n'
              '• Plow\n'
              '• Harrow\n'
              '• Fertilizer',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Step-by-Step Guide to Planting Upo:',
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
                'Prepare the field as early as possible to give enough time for the weeds and stubbles of previous crops to decompose. Plow and Plow at a depth of 15 to 20 cm. Harrow twice to break the clods and level the field. A well-pulverized soil promotes good soil aeration and enhances root formation',                
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
             _buildTitleCard(
                'Seed Preparation'),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'a. A hectare of farm requires 1 to 2 kg of seeds.\n'
                'b. Soak the seeds in clean water for 24 hours.\n '
                'c. Pre-germinate the seeds by wrapping in a moist cloth and place in cool and dark place. Incubate until the seed coat breaks.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            _buildStepCard('Planting',imageUrls[0]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ' Direct Planting \n'
                '\n'
                'a. Plant one pre-germinated seeds per hill at a distance of one meter between hills.'
                'b. Cover the seeds with thin layer of soil. '
                'c. During wet season, plant in ridges or above furrows to prevent rotting of seedlings due to flooding.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
           _buildStepCard(
                'Transplanting', imageUrls[1]),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'a. Use a prepared media of one part compost or organic fertilizer, one part clay soil and one part carbonized rice hull.'
                'b. A ready mixed commercial soil media for seedling production can also be used.\n'
                'c. Fill in plastic bags, potlets or seedling trays with the prepared media.\n'
                'd. Water the potting media before sowing. Sow one pregerminated seed per potlet.\n'
                'e. Place the seedling trays/ potlets under a temporary shade.\n'
                'f. Maintain the seedlings by watering regularly when needed.\n'
                'g. Harden the seedlings by gradually reducing the frequency of watering and exposing to direct sunlight.\n'
                'h. Transplant one seedling per hill at a distance of one meter between hills 15 days after emergence or when true leaves have developed.\n'
                'i. Transplant in the afternoon or during cloudy days.\n'
                'j. Replant missing hills immediately.'
                ,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
             _buildStepCard(
                'Fertilizer Application', imageUrls[2]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'a. The kind and amount of fertilizer to apply depends on soil fertility and soil type. To achieve optimum yield, have your soil analyzed at the Soils Laboratory nearest you to determine the right nutrient requirement of the soil. In the absence of soil analysis, apply the following fertilizers at the time and amount specified:Cover the basal fertilizer with thin soil before planting to avoid direct contact with the roots of the seedlings.\n'
                'b. Place the sidedress fertilizer 10 cm away from the base of the plants to avoid burning effects.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildStepCard(
                'Trellising', imageUrls[3]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'a. Provide the plants with trellis to produce fruits of good quality. Trellising is also essential during the wet season to minimize fruit rotting and malformation.\n'
                'b. Construct overhead trellises at a distance of 2 to 3 m wide and 2 m high using ipil-ipil or bamboo poles. Provide strong roof trellis by intertwining tie wire or nylon twine crosswise and lengthwise on top of the trellis. Provide a ladder-like trellis or vertical pole for each upo plant to facilitate the vines to climb up.\n'
                'c. Train the vines to climb the trellis by tying the stem lightly on the vertical pole or ladder-like trellis until it reaches the top. \n',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            _buildTitleCard(
                'Pruning'),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ' a. To promote branching and fruiting, remove the tip of the main vine and the lower lateral branches that appear on the climbing part of the main stem.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildTitleCard(
                'Weed Control'),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ' a.Bottle gourd is moderately deep-rooted with extensive lateral root system.Weeds near the row of the plants can be controlled by off-barring or re-plowing 14 days after planting. Hill-up at 15 to 20 days after emergence or 1 month after planting if un-mulched. Minimize cultivation during the fruiting stage to avoid disturbing the roots. Hand weeding is recommended during this stage.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            _buildTitleCard(
                'Irrigation and Water Management'),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'a. Irrigate the field 14 days after emergence by flooding. Repeat irrigation every seven days throughout the growing season or as need arises.\n'
                'b. Bottle gourd is sensitive to excessive soil moisture, which favors disease infection. Provide adequate drainage during wet season to avoid water logging. Furrow irrigation is recommended during dry season at weekly interval. Spread rice straw around the base of the plants as mulch to conserve moisture and minimize watering during dry season.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            _buildStepCard(
                'Harvesting', imageUrls[4]),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ' a. Fruits develop very fast and require much attention at harvest time. Harvesting can be done when fruits meet the standard size base on the varietal characteristics. It usually takes 15 days to reach marketable size from the day of fruit set or 60 to 80 days from sowing. Harvest fruits using a sharp knife by cutting the peduncle, leaving approximately 5 cm length. Put harvested fruits in a woven basket lined with banana leaves to avoid skin bruises. Pack marketable fruits in plastic bags.',
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
            _buildGuideCard('Upo Farming: How to Grow Upo',
                'Feb 15, 2016 - 4:45', 'images/vegetables/guide1.png'),
            _buildGuideCard(
                'Upo Farming: How to Grow Upo or Bittergourd',
                'Feb 16, 2016 - 4:45',
                'images/vegetables/guide2.png'),
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
              ? Container(
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
