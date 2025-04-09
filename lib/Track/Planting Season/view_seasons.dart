// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewSeasons extends StatefulWidget {
  const ViewSeasons({super.key});

  @override
  _ViewSeasonsState createState() => _ViewSeasonsState();
}

class _ViewSeasonsState extends State<ViewSeasons> {
  final CollectionReference _firestoreCollection =
      FirebaseFirestore.instance.collection('planting_seasons');

  String _selectedClimate = 'All Climates';
  String _selectedCropType = 'All Crop Types';
  String _searchQuery = '';

  List<String> _climates = ['All Climates'];
  List<String> _cropTypes = ['All Crop Types'];

  @override
  void initState() {
    super.initState();
    _fetchFilterOptions();
  }

  Future<void> _fetchFilterOptions() async {
    final querySnapshot = await _firestoreCollection.get();
    final docs = querySnapshot.docs;

    final climates = docs
        .map((doc) => doc['climate'] as String)
        .toSet()
        .toList(); // Unique climates
    final cropTypes = docs
        .map((doc) => doc['cropType'] as String)
        .toSet()
        .toList(); // Unique crop types

    setState(() {
      _climates.addAll(climates);
      _cropTypes.addAll(cropTypes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Planting Seasons'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedClimate,
                    items: _climates
                        .map((climate) => DropdownMenuItem(
                              value: climate,
                              child: Text(climate),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClimate = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Filter by Climate',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCropType,
                    items: _cropTypes
                        .map((cropType) => DropdownMenuItem(
                              value: cropType,
                              child: Text(cropType),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCropType = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Filter by Crop Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search by Crop Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No planting seasons found.'),
                  );
                }

                final data = snapshot.data!.docs.where((doc) {
                  final season = doc.data() as Map<String, dynamic>;
                  final matchesClimate = _selectedClimate == 'All Climates' ||
                      season['climate'] == _selectedClimate;
                  final matchesCropType =
                      _selectedCropType == 'All Crop Types' ||
                          season['cropType'] == _selectedCropType;
                  final matchesSearch = season['cropName']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery);

                  return matchesClimate && matchesCropType && matchesSearch;
                }).toList();

                if (data.isEmpty) {
                  return const Center(
                    child: Text('No planting seasons match your filters.'),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final season = data[index].data() as Map<String, dynamic>;
                    final periods = season['periods'] as List<dynamic>? ?? [];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Climate: ${season['climate']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'Description: ${season['climateDescription']}'),
                            const SizedBox(height: 8),
                            Text('Crop Type: ${season['cropType']}'),
                            const SizedBox(height: 8),
                            Text('Crop Name: ${season['cropName']}'),
                            const SizedBox(height: 8),
                            const Text(
                              'Planting Periods:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...periods.map((period) {
                              return Text(
                                  '${period['start']} - ${period['end']}');
                            }).toList(),
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
    );
  }
}
