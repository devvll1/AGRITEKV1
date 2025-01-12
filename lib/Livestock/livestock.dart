import 'package:flutter/material.dart';

class LivestockScreen extends StatefulWidget {
  const LivestockScreen({super.key});

  @override
  LivestockScreenState createState() => LivestockScreenState();
}

class LivestockScreenState extends State<LivestockScreen> {
  final String _description =
      'Livestock are the domesticated animals raised in an agricultural setting in order to provide labour and produce diversified products for consumption such as meat, eggs, milk, fur, leather, and wool. The term is sometimes used to refer solely to animals who are raised for consumption, and sometimes used to refer solely to farmed ruminants, such as cattle, sheep, and goats.';

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
        title: const Text("Livestock"),
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
                      'assets/images/livestock.jpeg',
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
                            'Livestock',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Raising of Domesticated Animals',
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
              width: double.infinity, // This makes the button fill the width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/livestocklist');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 32.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('View List Of Livestock'),
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
