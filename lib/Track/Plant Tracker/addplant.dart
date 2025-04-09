// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'package:agritek/Track/Planting%20Season/add_season_info.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlantTrackerPage extends StatefulWidget {
  const PlantTrackerPage({super.key});

  @override
  _PlantTrackerPageState createState() => _PlantTrackerPageState();
}

class _PlantTrackerPageState extends State<PlantTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _plantNameController = TextEditingController();
  final TextEditingController _cropTypeController = TextEditingController();

  final List<Map<String, dynamic>> _events = [];

  void _addEventField() {
    setState(() {
      _events.add({
        "description": TextEditingController(),
        "days": TextEditingController(),
        "note": TextEditingController(),
      });
    });
  }

  void _removeEventField(int index) {
    setState(() {
      _events.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String plantName = _plantNameController.text;
      final String cropType = _cropTypeController.text;

      // Validate and generate events based on user input
      final List<Map<String, dynamic>> events = [];
      for (var event in _events) {
        final description = event["description"]?.text;
        final daysText = event["days"]?.text;
        final note = event["note"]?.text;

        if (description == null || description.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please fill in all event descriptions.')),
          );
          return;
        }

        if (daysText == null ||
            daysText.isEmpty ||
            int.tryParse(daysText) == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please enter valid days for all events.')),
          );
          return;
        }

        events.add({
          "event": description,
          "daysAfterPlanting": int.parse(daysText),
          "note": note ?? "",
        });
      }

      try {
        // Save data to Firestore
        await FirebaseFirestore.instance.collection('plants').add({
          "plantName": plantName,
          "cropType": cropType,
          "events": events,
          "createdAt": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plant added successfully!')),
        );

        // Clear the form after submission
        _formKey.currentState!.reset();
        _plantNameController.clear();
        _cropTypeController.clear();
        setState(() {
          _events.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add plant: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Plant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              // Navigate to the CalendarScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddSeasonInfo()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Plant Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _plantNameController,
                        decoration: const InputDecoration(
                          labelText: 'Plant Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the plant name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cropTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Crop Type',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the crop type';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Significant Events',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._events.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: event["description"],
                                decoration: const InputDecoration(
                                  labelText: 'Event Description',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the event description';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: event["days"],
                                decoration: const InputDecoration(
                                  labelText: 'Days After Planting',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the number of days';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => _removeEventField(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: event["note"],
                          decoration: const InputDecoration(
                            labelText: 'Note',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _addEventField,
                icon: const Icon(Icons.add, color: Colors.green),
                label: const Text('Add Event'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Add Plant',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
