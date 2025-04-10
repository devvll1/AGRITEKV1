import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPriceScreen extends StatelessWidget {
  final dynamic item;

  const EditPriceScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController highestPriceController =
        TextEditingController(text: item['highest_price'].toString());
    final TextEditingController lowestPriceController =
        TextEditingController(text: item['lowest_price'].toString());
    final TextEditingController prevailingPriceController =
        TextEditingController(text: item['prevailing_price'].toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Prices'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: highestPriceController,
              decoration: const InputDecoration(labelText: 'Highest Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lowestPriceController,
              decoration: const InputDecoration(labelText: 'Lowest Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: prevailingPriceController,
              decoration: const InputDecoration(labelText: 'Prevailing Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Update the prices in Firestore
                FirebaseFirestore.instance
                    .collection('market_prices')
                    .doc(item.id)
                    .update({
                  'highest_price': double.parse(highestPriceController.text),
                  'lowest_price': double.parse(lowestPriceController.text),
                  'prevailing_price':
                      double.parse(prevailingPriceController.text),
                }).then((_) {
                  Navigator.pop(context);
                });
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
