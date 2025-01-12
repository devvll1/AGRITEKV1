import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Chicken extends StatelessWidget {
  const Chicken({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChickenDetailScreen();
  }
}

class ChickenDetailScreen extends StatefulWidget {
  const ChickenDetailScreen({super.key});

  @override
  ChickenDetailScreenState createState() => ChickenDetailScreenState();
}

class ChickenDetailScreenState extends State<ChickenDetailScreen> {

   final storage = FirebaseStorage.instance;
    // URLs for Firebase images
    late List<String> imageUrls;
    late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text:
          "Chicken are primarily raised for its meat and eggs, and is one of the most widely kept livestock worldwide; chickens are known for their social behavior, adaptability to various environments, and a range of breeds that vary in size, color, and purpose, including broilers for meat production and layers for egg production.",
          );
    
    imageUrls = List.filled(30, ''); // Initialize with empty strings
    getImagesFromFirebase();
  }

 Future<void> getImagesFromFirebase() async {
    List<String> imageNames = [
  '1.png', '2.png', '3.png', '4.png', '5.jpg', 
  '6.jpg', '7.jpg', '8.jpg', '9.jpg', '10.jpg', 
  '11.jpg', '12.jpg', '13.jpg', '14.jpg', '15.jpg', 
  '16.jpg', '17.jpg', '18.jpg', '19.jpg', '20.jpg', 
  '21.jpg', '22.jpg', '23.jpg', '24.jpg', '25.jpg',
  '26.jpg', '27.jpg', '28.jpg', '29.jpg',
];


    for (int i = 0; i < imageNames.length; i++) {
      final ref = storage.ref().child('LiveStock/Chicken/${imageNames[i]}');
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
        title: const Text('Livestock'),
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
                      'images/livestock/chicken.png',
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
                            'Chicken',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gallus gallus domesticus',
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

            const Text(
              'Types of Chicken',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),
            _buildTitleCard(
                'Broilers'),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'a.  are chickens specifically bred for meat production, known for their rapid growth and efficient feed conversion.\n',                
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildCard(
              '1. COBB 500', 
              imageUrls[0],  // Your image URL
              'is a commercial broiler chicken breed known for its rapid growth and efficiency in meat production. Developed by Cobb-Vantress, it’s highly valued in the poultry industry for its ability to reach market weight quickly while being efficient in feed conversion. The breed typically has a good meat yield and is often used in large-scale poultry farming operations. \n',  // The text description
            ),

            _buildCard(
              '2. ROSS 308', 
              imageUrls[1],  // Your image URL
              'is a commercial broiler chicken breed, developed by Aviagen. Known for its impressive growth rate and feed efficiency, it’s widely used in commercial meat production. This breed typically offers excellent carcass quality and uniformity, making it a favorite for producers aiming for high yields.',  // The text description
            ),

             _buildTitleCard(
                'Layers'),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'a.  are hens bred primarily for high egg production, usually raised in larger flocks to maximize output.\n',                
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            _buildCard(
              '1.Leghorn', 
              imageUrls[2],  // Your image URL
              'are renowned for their exceptional egg-laying abilities, especially producing white eggs. Originating from Italy, they are lightweight, active birds known for their hardiness and good foraging skills. They typically have a calm temperament, but can be a bit flighty. Leghorns are efficient in feed conversion, making them ideal for commercial egg production. \n',  // The text description
            ),

            _buildCard(
              '2. Hy-line Brown', 
              imageUrls[3],  // Your image URL
              'is a popular commercial layer breed known for its exceptional egg production, specifically brown eggs. Developed by Hy-Line International, this breed is recognized for its hardiness, adaptability, and efficiency in feed conversion. Hy-Line Browns are typically good foragers and have a calm temperament, making them suitable for both free-range and conventional systems.'
              ),

              _buildTitleCard(
                'Native Chicken'),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'a.  are local breeds adapted to the environment, often free-range, and valued for their hardiness, unique flavors, and ability to thrive in diverse conditions. \n',                
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            _buildCard(
              '1.Darag', 
              imageUrls[4],  // Your image URL
              'A native breed from Central Visayas region, this breed is known for its hardiness and adaptability. It has a reddish-brown plumage, is dual-purpose (good for meat and eggs), and produces medium-sized eggs. \n',  // The text description
            ),
            const SizedBox(height: 24),

            const Text(
              'Step-by-Step Guide to Raising Chicken:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildStepCard(
                'Planning Chicken Coop', imageUrls[5]),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '1: Find out if it is legal to raise chickens on your land.\n'
                'b. Many cities have ordinances against raising chickens in city lines.\n It is a good idea to search for town ordinances and to check with your homeowner’s association. They may have additional restrictions. \n Most cities have stricter laws about roosters than chickens. If you want a rooster in order to grow chickens for meat, you may have more trouble.',                
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
             _buildStepCard(
                '', imageUrls[6]),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '2: Talk to your neighbors\n'
                "a. Chickens make a fair amount of noise. Don't have roosters if you have neighbors close by; the roosters may disturb the neighbors!\n "
                'b. Chickens will still squawk, but rest assured they will not crow like roosters.\n'
                'c. Consider offering your neighbors free eggs every few weeks. They may be more amenable to the idea if they reap some benefits.\n',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            _buildStepCard('',imageUrls[7]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '3: Make sure you have enough time in your schedule to care for chicks and chickens\n'
                'a. You will need to stay at home the first day the chicks arrive, and clean and harvest eggs most days of the year. If you have to work long hours, this responsibility may not be for you.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard('',imageUrls[8]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '4: Set aside an area in your backyard for the chicken coop. \n'
                "a. If you are raising the birds from chicks, you'll have a little bit of time to build it while they grow. If you are buying older hens, you will need the coop immediately.",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard(
                'Making a Chicken Brooder/Coop', imageUrls[9]),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '1: Buy a chicken coop before your chickens are 2 months old. Search online for people who make chicken coops in your area, and you may be able to pick up a newly made model to avoid shipping. You can also get plan to build a coop online.\n'
                'a. Look for a coop or design with lots of light, so your chickens will be happy.\n'
                'b. Choose a coop with a run, so that chickens can roam, but be protected during the day.\n'
                'c. You can buy a chicken coop from Amazon, Williams Sonoma, Petco and numerous other outlets.\n'
                'd. You can also buy a chicken tractor, which is a portable chicken run.',                
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard('',imageUrls[10]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '2: Reinforce your chicken coop \n'
                "a. Predators, such as raccoons, mountain lions, bobcats and even dogs, can slip through cracks or underneath coops. Invest some money in extra chicken wire, nails and wooden or stone borders.",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard('',imageUrls[11]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ' 3: Prepare your brooder/coop before you bring chicks home. Add bedding, feeders and a heat lamp. \n',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard(
               'Choosing Chicken', imageUrls[12]),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '1: Consider buying hens.'
                'a. They are often available in the fall, after people have raised too many chicks for their needs. However, it is hard to distinguish hens that are near the end of their egg-laying years (over 2 years old) from those who are young with many egg-laying years ahead of them, so vet your farm or seller well.\n',         
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard('',imageUrls[13]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ' 2: Opt for buying chicks rather than hatching eggs the first year you raise chickens. \n'
                'a. Hatching eggs are available through purchase by mail order and in stores. While they may be cheaper than chicks, they may not have the sex determined and some eggs do not hatch.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard('',imageUrls[14]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '3: Set up your brooder before you take the chicks home. \n'
                'a. A brooder is a heated nesting place that will keep chicks warm. They cannot regulate their body temperature for the first few weeks of life.\n'
                'c. Find a thick cardboard or plastic box. It should be smaller when the chicks are small, and then you should replace it incrementally as they grow.\n'
                'd. Place the box in an area of your house that has a steady temperature.\n'
                'e. Pour 1 inch (2.5 cm) of pine shavings into the bottom of the box.\n'
                'f. Place a heat lamp on the side of the box. Use a thermometer to keep the temperature at a steady 95 degrees Fahrenheit (35 degrees Celsius).',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard('',imageUrls[15]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '4: Purchase a chick waterer, chick feeder and chick starter feed from your local feed store.\n',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

             _buildStepCard('',imageUrls[16]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '5: Buy day-old chicks at the local feed store or online. \n'
                'a. You can usually buy them between February and April. Look for “pullets” because they are female.\n'
                'b. A full grown chicken between 2 months and 2 years old will lay approximately 5 eggs per week. In order to get a dozen per week, buy 3 to 4 chickens.\n'
                'c. Make sure your coop size is large enough to accommodate them. There should be 3 to 4 square feet (0.9 to 1.2 square meters) of space per chicken inside the coop and 10 square feet (3 square meters) of space per chicken outside the coop.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

             _buildStepCard('',imageUrls[17]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '6: Purchase several types of broilers and egg-laying chickens\n'
                'a. A mixed group will provide varied sizes and colors. The following are some breeds to consider: \n'
                'COBB 500, White LegHorn, Hy-Line Brown, Ross 308, and also the native chickens like Darag.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

             _buildStepCard(
               'Raising Chicken', imageUrls[18]),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '1: Move the heat lamp slightly farther away every week for 8 weeks\n'
                'a. Move the heat lamp slightly farther away every week for 8 weeks. Keep it at 95 degrees the first week and decrease by 5 degrees each week until you reach 65 degrees (18 degrees Celsius).\n'
                'b. The week after you reach 65 degrees, you can take the lamp away completely.\n'
                'c. Keep a thermometer in the box so you can accurately judge the temperature.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard('',imageUrls[19]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '2: Dip the chick’s beaks in water the first day you bring them home.\n'
                'a. They are possibly dehydrated and don’t know how to drink yet. Keep an eye on water levels for the next few months to ensure they are staying hydrated.\n'
                'b. Thirsty/hot chicks will have their beak open and pant.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            _buildStepCard('',imageUrls[20]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '3: Buy chick feed for the first few months. \n'
                'a. Chickens need food with a little sand in it, and baby chick crumbles have already accounted for this. When you replace chickens in later years, you can try mixing your own scraps with sand.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            _buildStepCard('',imageUrls[21]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '4: Move the chickens outdoors to their coop after 2 months\n'
                'a. If it is still very cold in your area, you might want to wait a little longer.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard('',imageUrls[22]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '5: Feed your chickens varied food to make deeper yolks.\n'
                'a. They can eat store-bought chicken crumbles, food scraps, insects from the lawn, night crawlers, grass and corn. Cracked corn is essential in the winter to keep their body temperature up.\n'
                'b. Free-range eggs have lower cholesterol and saturated fats than store bought eggs. They also have higher omega-3 fatty acids',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

             _buildStepCard('',imageUrls[23]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '6: Avoid letting your chickens roam free without supervision.\n'
                'a. Although you may want them to have freedom, they will become prey.\n'
                'Let them out to run around when you are doing yard work or playing in the lawn.\n'
                'Keep them on the run until nightfall, and then close up the coop.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard(
               'Gathering Eggs', imageUrls[24]),
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '1: Place a fake egg in the nesting boxes of young hens.\n'
                'a. Make sure it is not a real egg, or they can get into the habit of eating eggs. They need to be shown where to lay their eggs.\n'
                'b. In later years, having chickens of varying ages helps teach new hens how to behave. Most sources suggest replacing 1/4 to 1/3 of the flock each year.\n'
                'c. Keep a thermometer in the box so you can accurately judge the temperature.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard('',imageUrls[25]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '2: Gather eggs each day to free up the nesting boxes. \n',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard('',imageUrls[26]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '3: Wipe the eggs with a soft cloth, which removes mess, but not the anti-bacterial bloom on the egg. \n'
                'a. Mother hens produce this coating to protect their eggs from disease.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

             _buildStepCard('',imageUrls[27]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '4: Store eggs at approximately 45 degrees Fahrenheit (7.2 degrees Celsius).\n'
                'a. They should be stored in the refrigerator rather than at room temperature. Warmer temperatures can promote bacterial growth.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            _buildStepCard('',imageUrls[28]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '5: Protect against salmonella. \n The following habits will prevent backyard hens from producing contaminated eggs.\n'
                'a. Wash eggs that are covered with chicken feces. Roll them around in a sanitizer with 1/2 oz. (14.8 ml) of chlorine to 1 gallon (3.8 l) of water.'
                'b. Eat or Sell eggs quickly. Older eggs have a higher risk of contamination as the egg white breaks down.\n'
                'c. Place chicken manure in a composter for 45 to 60 days before adding it to vegetable beds. Fresh chicken manure may contaminate vegetables with salmonella.\n'
                'd. Keep potentially contaminated eggs away from pregnant people, young children or chronically ill people, who have a higher chance of infection.',
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
            _buildGuideCard('Chicken Farming: How to Grow Chicken',
                'Feb 15, 2016 - 4:45', 'images/guide1.png'),
            _buildGuideCard(
                'Chicken Farming: How to Grow Chicken or Bittergourd',
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

  Widget _buildCard(String stepTitle, String imageUrl, String description) {
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
          const SizedBox(height: 8), // Space between image and text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              description,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12), // Bottom padding for a clean look
        ],
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
