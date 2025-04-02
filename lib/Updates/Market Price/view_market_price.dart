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
        title: Text('View Market Prices'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCommodity,
              decoration: InputDecoration(labelText: 'Filter by Commodity'),
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
            SizedBox(height: 16),
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
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No data available'));
                  }
                  final data = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return Card(
                        color: Colors.lightBlue[
                            50], // Light blue background color for the card
                        margin: EdgeInsets.symmetric(vertical: 6.0),
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
                                    style: TextStyle(
                                      fontSize: 16.0, // Larger font size
                                      fontWeight: FontWeight.bold, // Bold text
                                    ),
                                  ),
                                  Text(
                                    _formatDate(item['date']),
                                    style: TextStyle(
                                      fontSize: 12.0, // Smaller font size
                                      color: Colors.grey, // Lighter color
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4), // Add space
                              Text(
                                '${item['commodity']}',
                                style: TextStyle(
                                  fontSize: 11.0, // Smaller font size
                                ),
                              ),
                              Text(
                                'Specification: ${item['specification']}',
                                style: TextStyle(
                                  fontSize: 10.0, // Smaller font size
                                ),
                              ),
                              SizedBox(height: 12), // Add space
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Highest: ₱${item['highest_price'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 13.0, // Smaller font size
                                      color: Colors
                                          .red, // Red color for highest price
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Lowest: ₱${item['lowest_price'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 13.0, // Smaller font size
                                      color: Colors
                                          .green, // Green color for lowest price
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Prevailing: ₱${item['prevailing_price'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 13.0, // Smaller font size
                                      color: Colors
                                          .blue, // Blue color for prevailing price
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10), // Add space
                              // Visual representation of prices
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Price Comparison',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: (item['prevailing_price']
                                                  as double) /
                                              (item['highest_price'] as double),
                                          backgroundColor: Colors.grey[300],
                                          color: Colors.blue,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Prevailing vs Highest',
                                          style: TextStyle(
                                              fontSize: 10.0,
                                              color: Colors.grey),
                                        ),
                                      ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMarketPrice()),
          );
        },
        child: Icon(Icons.add),
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
