import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMarketPrice extends StatefulWidget {
  @override
  _AddMarketPriceState createState() => _AddMarketPriceState();
}

class _AddMarketPriceState extends State<AddMarketPrice> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _specificationController =
      TextEditingController();
  final TextEditingController _highestPriceController = TextEditingController();
  final TextEditingController _lowestPriceController = TextEditingController();
  final TextEditingController _prevailingPriceController =
      TextEditingController();

  String? _selectedCommodity;
  DateTime? _selectedDate;

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

  void _saveToFirebase() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        await FirebaseFirestore.instance.collection('market_prices').add({
          'commodity': _selectedCommodity,
          'product_name': _productNameController.text,
          'specification': _specificationController.text,
          'highest_price': double.parse(_highestPriceController.text),
          'lowest_price': double.parse(_lowestPriceController.text),
          'prevailing_price': double.parse(_prevailingPriceController.text),
          'date': _selectedDate!.toIso8601String(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Market price added successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedCommodity = null;
          _selectedDate = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add market price: $e')),
        );
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date')),
      );
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Market Price'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCommodity,
                  decoration: InputDecoration(labelText: 'Commodity'),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a commodity';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _productNameController,
                  decoration: InputDecoration(labelText: 'Name of the Product'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _specificationController,
                  decoration: InputDecoration(labelText: 'Specification'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the specification';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _highestPriceController,
                  decoration: InputDecoration(labelText: 'Highest Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the highest price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lowestPriceController,
                  decoration: InputDecoration(labelText: 'Lowest Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the lowest price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _prevailingPriceController,
                  decoration: InputDecoration(labelText: 'Prevailing Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the prevailing price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No date selected'
                            : 'Selected Date: ${_selectedDate!.toLocal()}'
                                .split(' ')[0],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickDate,
                      child: Text('Pick Date'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveToFirebase,
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
