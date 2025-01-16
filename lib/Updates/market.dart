import 'package:flutter/material.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
    final List<Category> categories = [
  Category(
  name: 'Vegetables',
  products: [
    Product(
      name: 'Tomatoes',
      currentPrice: 25.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-10', price: 23.0),
        PriceRecord(date: '2025-01-05', price: 20.0),
      ],
    ),
    Product(
      name: 'Carrots',
      currentPrice: 30.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-08', price: 28.0),
        PriceRecord(date: '2025-01-01', price: 26.0),
      ],
    ),
    Product(
      name: 'Cabbage',
      currentPrice: 20.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 19.0),
        PriceRecord(date: '2025-01-03', price: 18.0),
      ],
    ),
    Product(
      name: 'Lettuce',
      currentPrice: 35.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-10', price: 32.0),
        PriceRecord(date: '2025-01-05', price: 30.0),
      ],
    ),
    Product(
      name: 'Spinach',
      currentPrice: 40.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-08', price: 38.0),
        PriceRecord(date: '2025-01-03', price: 36.0),
      ],
    ),
    Product(
      name: 'Onions',
      currentPrice: 45.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 42.0),
        PriceRecord(date: '2025-01-02', price: 40.0),
      ],
    ),
    Product(
      name: 'Garlic',
      currentPrice: 60.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-08', price: 58.0),
        PriceRecord(date: '2025-01-03', price: 55.0),
      ],
    ),
    Product(
      name: 'Potatoes',
      currentPrice: 50.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 48.0),
        PriceRecord(date: '2025-01-04', price: 45.0),
      ],
    ),
    Product(
      name: 'Peppers',
      currentPrice: 80.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-10', price: 75.0),
        PriceRecord(date: '2025-01-05', price: 70.0),
      ],
    ),
    Product(
      name: 'Eggplant',
      currentPrice: 35.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 33.0),
        PriceRecord(date: '2025-01-03', price: 30.0),
      ],
    ),
    Product(
      name: 'Zucchini',
      currentPrice: 45.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-08', price: 42.0),
        PriceRecord(date: '2025-01-02', price: 40.0),
      ],
    ),
    Product(
      name: 'Broccoli',
      currentPrice: 55.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-07', price: 52.0),
        PriceRecord(date: '2025-01-01', price: 50.0),
      ],
    ),
    Product(
      name: 'Cauliflower',
      currentPrice: 50.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 48.0),
        PriceRecord(date: '2025-01-03', price: 45.0),
      ],
    ),
    Product(
      name: 'Beans',
      currentPrice: 70.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-08', price: 68.0),
        PriceRecord(date: '2025-01-02', price: 65.0),
      ],
    ),
    Product(
      name: 'Sweet Corn',
      currentPrice: 25.0,
      unit: 'per cob',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 23.0),
        PriceRecord(date: '2025-01-03', price: 20.0),
      ],
    ),
  ],
),
  Category(
    name: 'Dairy',
    products: [
        Product(
            name: 'Milk',
            currentPrice: 15.0,
            unit: 'per liter',
            priceHistory: [
                PriceRecord(date: '2025-01-09', price: 14.5),
                PriceRecord(date: '2025-01-03', price: 14.0),
            ],
        ),
        Product(
            name: 'Cheese',
            currentPrice: 50.0,
            unit: 'per 500 grams',
            priceHistory: [
                PriceRecord(date: '2025-01-07', price: 48.0),
                PriceRecord(date: '2025-01-02', price: 45.0),
            ],
        ),
        Product(
            name: 'Butter',
            currentPrice: 60.0,
            unit: 'per 500 grams',
            priceHistory: [
                PriceRecord(date: '2025-01-09', price: 58.0),
                PriceRecord(date: '2025-01-05', price: 56.0),
            ],
        ),
        Product(
            name: 'Carabao’s Milk',
            currentPrice: 18.0,
            unit: 'per liter',
            priceHistory: [
                PriceRecord(date: '2025-01-08', price: 17.5),
                PriceRecord(date: '2025-01-04', price: 17.0),
            ],
        ),
        Product(
            name: 'Kesong Puti',
            currentPrice: 75.0,
            unit: 'per 250 grams',
            priceHistory: [
                PriceRecord(date: '2025-01-08', price: 72.0),
                PriceRecord(date: '2025-01-03', price: 70.0),
            ],
        ),
        Product(
            name: 'Yogurt',
            currentPrice: 45.0,
            unit: 'per 200 grams',
            priceHistory: [
                PriceRecord(date: '2025-01-07', price: 43.0),
                PriceRecord(date: '2025-01-01', price: 42.0),
            ],
        ),
        Product(
            name: 'Evaporated Milk',
            currentPrice: 25.0,
            unit: 'per 410 ml can',
            priceHistory: [
                PriceRecord(date: '2025-01-06', price: 24.0),
                PriceRecord(date: '2025-01-02', price: 23.5),
            ],
        ),
        Product(
            name: 'Condensed Milk',
            currentPrice: 30.0,
            unit: 'per 390 grams',
            priceHistory: [
                PriceRecord(date: '2025-01-08', price: 29.0),
                PriceRecord(date: '2025-01-03', price: 28.5),
            ],
        ),
        Product(
            name: 'Cream Cheese',
            currentPrice: 120.0,
            unit: 'per 200 grams',
            priceHistory: [
                PriceRecord(date: '2025-01-09', price: 115.0),
                PriceRecord(date: '2025-01-04', price: 110.0),
            ],
        ),
    ],
),
  Category(
    name: 'Meats',
    products: [
      Product(
        name: 'Chicken',
        currentPrice: 120.0,
        unit: 'per kilo',
        priceHistory: [
          PriceRecord(date: '2025-01-10', price: 118.0),
          PriceRecord(date: '2025-01-06', price: 115.0),
        ],
      ),
      Product(
        name: 'Pork',
        currentPrice: 250.0,
        unit: 'per kilo',
        priceHistory: [
          PriceRecord(date: '2025-01-09', price: 245.0),
          PriceRecord(date: '2025-01-03', price: 240.0),
        ],
      ),
      Product(
        name: 'Beef',
        currentPrice: 300.0,
        unit: 'per kilo',
        priceHistory: [
          PriceRecord(date: '2025-01-08', price: 290.0),
          PriceRecord(date: '2025-01-02', price: 280.0),
        ],
      ),
    ],
  ),
Category(
  name: 'Fruits',
  products: [
    Product(
      name: 'Bananas',
      currentPrice: 40.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-10', price: 38.0),
        PriceRecord(date: '2025-01-05', price: 35.0),
      ],
    ),
    Product(
      name: 'Mangoes',
      currentPrice: 80.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 75.0),
        PriceRecord(date: '2025-01-03', price: 70.0),
      ],
    ),
    Product(
      name: 'Apples',
      currentPrice: 150.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-08', price: 145.0),
        PriceRecord(date: '2025-01-02', price: 140.0),
      ],
    ),
    Product(
      name: 'Pineapples',
      currentPrice: 50.0,
      unit: 'per piece',
      priceHistory: [
        PriceRecord(date: '2025-01-10', price: 48.0),
        PriceRecord(date: '2025-01-05', price: 45.0),
      ],
    ),
    Product(
      name: 'Papayas',
      currentPrice: 30.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 28.0),
        PriceRecord(date: '2025-01-03', price: 25.0),
      ],
    ),
    Product(
      name: 'Coconuts',
      currentPrice: 20.0,
      unit: 'per piece',
      priceHistory: [
        PriceRecord(date: '2025-01-08', price: 18.0),
        PriceRecord(date: '2025-01-02', price: 15.0),
      ],
    ),
    Product(
      name: 'Lanzones',
      currentPrice: 120.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-07', price: 115.0),
        PriceRecord(date: '2025-01-01', price: 110.0),
      ],
    ),
    Product(
      name: 'Rambutans',
      currentPrice: 100.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 95.0),
        PriceRecord(date: '2025-01-04', price: 90.0),
      ],
    ),
    Product(
      name: 'Durian',
      currentPrice: 250.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-08', price: 240.0),
        PriceRecord(date: '2025-01-02', price: 230.0),
      ],
    ),
    Product(
      name: 'Mangosteen',
      currentPrice: 200.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-10', price: 190.0),
        PriceRecord(date: '2025-01-05', price: 185.0),
      ],
    ),
    Product(
      name: 'Guavas',
      currentPrice: 70.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 68.0),
        PriceRecord(date: '2025-01-03', price: 65.0),
      ],
    ),
    Product(
      name: 'Calamansi',
      currentPrice: 90.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-08', price: 85.0),
        PriceRecord(date: '2025-01-02', price: 80.0),
      ],
    ),
    Product(
      name: 'Jackfruit',
      currentPrice: 60.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 58.0),
        PriceRecord(date: '2025-01-03', price: 55.0),
      ],
    ),
    Product(
      name: 'Avocados',
      currentPrice: 120.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-08', price: 115.0),
        PriceRecord(date: '2025-01-02', price: 110.0),
      ],
    ),
    Product(
      name: 'Watermelons',
      currentPrice: 35.0,
      unit: 'per kilo',
      priceHistory: [
        PriceRecord(date: '2025-01-09', price: 32.0),
        PriceRecord(date: '2025-01-04', price: 30.0),
      ],
    ),
  ],
),
 Category(
    name: 'Plant Seeds',
    products: [
        Product(
            name: 'Corn Seeds',
            currentPrice: 200.0,
            unit: 'per kilo',
            priceHistory: [
                PriceRecord(date: '2025-01-07', price: 195.0),
                PriceRecord(date: '2025-01-01', price: 190.0),
            ],
        ),
        Product(
            name: 'Rice Seeds',
            currentPrice: 180.0,
            unit: 'per kilo',
            priceHistory: [
                PriceRecord(date: '2025-01-06', price: 175.0),
                PriceRecord(date: '2025-01-02', price: 170.0),
            ],
        ),
        Product(
            name: 'Vegetable Seeds',
            currentPrice: 100.0,
            unit: 'per pack',
            priceHistory: [
                PriceRecord(date: '2025-01-05', price: 95.0),
                PriceRecord(date: '2025-01-01', price: 90.0),
            ],
        ),
        Product(
            name: 'Eggplant Seeds',
            currentPrice: 120.0,
            unit: 'per pack',
            priceHistory: [
                PriceRecord(date: '2025-01-07', price: 115.0),
                PriceRecord(date: '2025-01-02', price: 110.0),
            ],
        ),
        Product(
            name: 'Tomato Seeds',
            currentPrice: 150.0,
            unit: 'per pack',
            priceHistory: [
                PriceRecord(date: '2025-01-06', price: 145.0),
                PriceRecord(date: '2025-01-01', price: 140.0),
            ],
        ),
        Product(
            name: 'Ampalaya (Bitter Gourd) Seeds',
            currentPrice: 140.0,
            unit: 'per pack',
            priceHistory: [
                PriceRecord(date: '2025-01-05', price: 135.0),
                PriceRecord(date: '2025-01-01', price: 130.0),
            ],
        ),
        Product(
            name: 'Okra Seeds',
            currentPrice: 110.0,
            unit: 'per pack',
            priceHistory: [
                PriceRecord(date: '2025-01-08', price: 105.0),
                PriceRecord(date: '2025-01-03', price: 100.0),
            ],
        ),
        Product(
            name: 'Pechay (Pak Choi) Seeds',
            currentPrice: 90.0,
            unit: 'per pack',
            priceHistory: [
                PriceRecord(date: '2025-01-07', price: 85.0),
                PriceRecord(date: '2025-01-02', price: 80.0),
            ],
        ),
        Product(
            name: 'Malunggay (Moringa) Seeds',
            currentPrice: 130.0,
            unit: 'per pack',
            priceHistory: [
                PriceRecord(date: '2025-01-06', price: 125.0),
                PriceRecord(date: '2025-01-02', price: 120.0),
            ],
        ),
        Product(
            name: 'Squash Seeds',
            currentPrice: 150.0,
            unit: 'per pack',
            priceHistory: [
                PriceRecord(date: '2025-01-07', price: 145.0),
                PriceRecord(date: '2025-01-03', price: 140.0),
            ],
        ),
        Product(
            name: 'String Beans Seeds',
            currentPrice: 140.0,
            unit: 'per pack',
            priceHistory: [
                PriceRecord(date: '2025-01-05', price: 135.0),
                PriceRecord(date: '2025-01-01', price: 130.0),
            ],
        ),
    ],
), 
Category(
    name: 'Seedlings',
    products: [
        Product(
            name: 'Mango Seedlings',
            currentPrice: 300.0,
            unit: 'per piece',
            priceHistory: [
                PriceRecord(date: '2025-01-08', price: 290.0),
                PriceRecord(date: '2025-01-03', price: 280.0),
            ],
        ),
        Product(
            name: 'Banana Seedlings',
            currentPrice: 100.0,
            unit: 'per piece',
            priceHistory: [
                PriceRecord(date: '2025-01-09', price: 95.0),
                PriceRecord(date: '2025-01-04', price: 90.0),
            ],
        ),
        Product(
            name: 'Coconut Seedlings',
            currentPrice: 200.0,
            unit: 'per piece',
            priceHistory: [
                PriceRecord(date: '2025-01-08', price: 195.0),
                PriceRecord(date: '2025-01-02', price: 190.0),
            ],
        ),
        Product(
            name: 'Papaya Seedlings',
            currentPrice: 120.0,
            unit: 'per piece',
            priceHistory: [
                PriceRecord(date: '2025-01-07', price: 115.0),
                PriceRecord(date: '2025-01-03', price: 110.0),
            ],
        ),
        Product(
            name: 'Calamansi Seedlings',
            currentPrice: 150.0,
            unit: 'per piece',
            priceHistory: [
                PriceRecord(date: '2025-01-06', price: 145.0),
                PriceRecord(date: '2025-01-01', price: 140.0),
            ],
        ),
        Product(
            name: 'Guava Seedlings',
            currentPrice: 130.0,
            unit: 'per piece',
            priceHistory: [
                PriceRecord(date: '2025-01-08', price: 125.0),
                PriceRecord(date: '2025-01-04', price: 120.0),
            ],
        ),
        Product(
            name: 'Lanzones Seedlings',
            currentPrice: 400.0,
            unit: 'per piece',
            priceHistory: [
                PriceRecord(date: '2025-01-09', price: 390.0),
                PriceRecord(date: '2025-01-05', price: 380.0),
            ],
        ),
        Product(
            name: 'Rambutan Seedlings',
            currentPrice: 350.0,
            unit: 'per piece',
            priceHistory: [
                PriceRecord(date: '2025-01-08', price: 340.0),
                PriceRecord(date: '2025-01-02', price: 330.0),
            ],
        ),
        Product(
            name: 'Jackfruit Seedlings',
            currentPrice: 250.0,
            unit: 'per piece',
            priceHistory: [
                PriceRecord(date: '2025-01-07', price: 245.0),
                PriceRecord(date: '2025-01-03', price: 240.0),
            ],
        ),
        Product(
            name: 'Durian Seedlings',
            currentPrice: 500.0,
            unit: 'per piece',
            priceHistory: [
                PriceRecord(date: '2025-01-06', price: 490.0),
                PriceRecord(date: '2025-01-02', price: 480.0),
            ],
        ),
    ],
)


];


  String selectedCategory = 'Vegetables';

  @override
  Widget build(BuildContext context) {
    final filteredProducts = categories
        .firstWhere((category) => category.name == selectedCategory)
        .products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              children: [
                const Text(
                  'Filter by:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: categories
                        .map((category) => DropdownMenuItem(
                              value: category.name,
                              child: Text(category.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16.0,
                columns: const [
                  DataColumn(
                      label: Text(
                    'Product',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'Price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'Unit',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'History',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
                rows: filteredProducts.map((product) {
                  return DataRow(cells: [
                    DataCell(Row(
                      children: [
                        const Icon(Icons.local_offer, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(product.name),
                      ],
                    )),
                    DataCell(Text('₱${product.currentPrice.toStringAsFixed(2)}')),
                    DataCell(Text(product.unit)),
                    DataCell(SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: product.priceHistory
                            .map((record) => Text(
                                '${record.date}: ₱${record.price.toStringAsFixed(2)}'))
                            .toList(),
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Category {
  final String name;
  final List<Product> products;

  Category({required this.name, required this.products});
}

class Product {
  final String name;
  final double currentPrice;
  final String unit;
  final List<PriceRecord> priceHistory;

  Product({
    required this.name,
    required this.currentPrice,
    required this.unit,
    required this.priceHistory,
  });
}

class PriceRecord {
  final String date;
  final double price;

  PriceRecord({required this.date, required this.price});
}
