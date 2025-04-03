import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_market_price.dart'; // Import the AddMarketPrice page

class ViewMarketPrice extends StatefulWidget {
  const ViewMarketPrice({super.key});

  @override
  _ViewMarketPriceState createState() => _ViewMarketPriceState();
}

class _ViewMarketPriceState extends State<ViewMarketPrice> {
  String? _selectedCommodity;
  final List<String> _commodities = [
    'IMPORTED COMMERCIAL RICE',
    'LOCAL COMMERCIAL RICE',
    'CORN',
    'FISH',
    'DRIED FISH',
    'LIVESTOCK AND POULTRY',
    'LOWLAND VEGETABLES',
    'HIGHLAND VEGETABLES',
    'SPICES',
    'ROOTCROPS',
    'FRUITS',
    'OTHER BASIC COMMODITIES',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Market Prices'),
      ),
      body: SafeArea(
        // Wrap the body in SafeArea
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCommodity,
                decoration:
                    const InputDecoration(labelText: 'Filter by Commodity'),
                items: _commodities.map((commodity) {
                  return DropdownMenuItem(
                    value: commodity,
                    child: Text(commodity),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCommodity = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _selectedCommodity == null
                      ? FirebaseFirestore.instance
                          .collection('market_prices')
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('market_prices')
                          .where('commodity', isEqualTo: _selectedCommodity)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No data available'));
                    }
                    final data = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return Card(
                          color: Colors.lightBlue[50],
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['product_name'],
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(item['date']),
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item['commodity']}',
                                  style: const TextStyle(
                                    fontSize: 11.0,
                                  ),
                                ),
                                Text(
                                  'Specification: ${item['specification']}',
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Highest: ₱${item['highest_price'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Lowest: ₱${item['lowest_price'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Prevailing: ₱${item['prevailing_price'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMarketPrice()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Market Price',
      ),
    );
  }

  // Helper function to format the date
  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return 'as of ${_getMonthName(parsedDate.month)} ${parsedDate.day}, ${parsedDate.year}';
  }

  // Helper function to get the month name
  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
