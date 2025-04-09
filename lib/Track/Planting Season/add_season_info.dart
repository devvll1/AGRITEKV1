// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSeasonInfo extends StatefulWidget {
  const AddSeasonInfo({super.key});

  @override
  _AddSeasonInfoState createState() => _AddSeasonInfoState();
}

class _AddSeasonInfoState extends State<AddSeasonInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _climateController = TextEditingController();
  final TextEditingController _climateDescriptionController =
      TextEditingController();
  final TextEditingController _cropTypeController = TextEditingController();
  final TextEditingController _cropNameController = TextEditingController();
  final List<Map<String, String>> _periods = [];

  final TextEditingController _startMonthController = TextEditingController();
  final TextEditingController _endMonthController = TextEditingController();

  final CollectionReference _firestoreCollection =
      FirebaseFirestore.instance.collection('planting_seasons');

  void _addPeriod() {
    if (_startMonthController.text.isNotEmpty &&
        _endMonthController.text.isNotEmpty) {
      setState(() {
        _periods.add({
          'start': _startMonthController.text,
          'end': _endMonthController.text,
        });
        _startMonthController.clear();
        _endMonthController.clear();
      });
    }
  }

  void _removePeriod(int index) {
    setState(() {
      _periods.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'climate': _climateController.text,
        'climateDescription': _climateDescriptionController.text,
        'cropType': _cropTypeController.text,
        'cropName': _cropNameController.text,
        'periods': _periods,
      };

      try {
        await _firestoreCollection.add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data submitted successfully!')),
        );
        _formKey.currentState!.reset();
        _periods.clear();
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Planting Season Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _climateController,
                  decoration: const InputDecoration(labelText: 'Climate'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the climate type';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _climateDescriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Climate Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the climate description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _cropTypeController,
                  decoration: const InputDecoration(labelText: 'Type of Crop'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the type of crop';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _cropNameController,
                  decoration: const InputDecoration(labelText: 'Name of Crop'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name of the crop';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Planting Periods (Month Ranges)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startMonthController,
                        decoration:
                            const InputDecoration(labelText: 'Start Month'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _endMonthController,
                        decoration:
                            const InputDecoration(labelText: 'End Month'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addPeriod,
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _periods.length,
                  itemBuilder: (context, index) {
                    final period = _periods[index];
                    return ListTile(
                      title: Text('${period['start']} - ${period['end']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removePeriod(index),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
