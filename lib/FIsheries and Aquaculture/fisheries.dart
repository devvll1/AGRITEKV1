import 'package:flutter/material.dart';

class AquacultureScreen extends StatefulWidget {
  const AquacultureScreen({super.key});

  @override
  AquacultureScreenState createState() => AquacultureScreenState();
}

class AquacultureScreenState extends State<AquacultureScreen> {
  final String _description =
      'Also known as aquafarming, is the controlled cultivation ("farming") of aquatic organisms such as fish, crustaceans, mollusks, algae and other organisms of value such as aquatic plants (e.g. lotus). Aquaculture involves cultivating freshwater, brackish water, and saltwater populations under controlled or semi-natural conditions and can be contrasted with commercial fishing, which is the harvesting of wild fish. Aquaculture is also a practice used for restoring and rehabilitating marine and freshwater ecosystems. ';

  void _onBottomNavItemTapped(int index) {
    switch (index) {
      case 0:
        // Navigate to HomePage or '/home' when 'Modules' is tapped
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
        title: const Text("Aquaculture"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
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
                      'assets/images/fisheries.jpg',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aquaculture',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cultivation of Aquatic Resources',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
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
              _description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, // Make the button fill the width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/croptypes');
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('View Types Of Aquaculture'),
              ),
            ),
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
}
