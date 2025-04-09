// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api
import 'package:agritek/Track/Planting%20Season/add_season_info.dart';
import 'package:agritek/Track/Planting%20Season/view_seasons.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agritek/Track/Plant%20Tracker/addplant.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<String>> _selectedEvents;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  Map<DateTime, List<String>> _events = {};
  Map<String, List<Map<String, dynamic>>> _plantData = {}; // Store plant data

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedEvents = ValueNotifier([]);
    _loadNotes();
    _fetchPlantsFromDatabase(); // Fetch plants from Firestore

    // Check for today's reminders after the first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForTodayReminder();
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Track Your Plant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _removeAllNotesGlobally,
            tooltip: 'Remove All Notes',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green[50],
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) =>
                  _events[DateTime(day.year, day.month, day.day)] ?? [],
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _selectedEvents.value = _events[DateTime(
                      _selectedDay.year,
                      _selectedDay.month,
                      _selectedDay.day,
                    )] ??
                    [];

                if (_selectedEvents.value.isNotEmpty) {
                  _showNotesDialog(_selectedDay, _selectedEvents.value);
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.green[300], // Softer green for today
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green[700], // Darker green for selected day
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.brown, // Brown markers for events
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading:
                            const Icon(Icons.event_note, color: Colors.green),
                        title: Text(
                          events[index],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          final plantName = events[index]
                              .split('\n')
                              .first; // Extract plant name
                          if (_plantData.containsKey(plantName)) {
                            _showPlantTimelineDialog(
                                plantName, _plantData[plantName]!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'No timeline data available for $plantName')),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        tooltip: 'Add Options',
        children: [
          SpeedDialChild(
            child: const Icon(Icons.track_changes),
            label: 'Track Your Plant',
            backgroundColor: Colors.green,
            onTap: () {
              _showPlantSelectionDialog(); // Opens the plant selection dialog
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_circle),
            label: 'Add Plant',
            backgroundColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlantTrackerPage(),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.info),
            label: 'View Seasons',
            backgroundColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ViewSeasons(), // Ensure ViewSeasons is imported
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_box),
            label: 'Add Season',
            backgroundColor: const Color.fromARGB(255, 243, 160, 36),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AddSeasonInfo(), // Ensure ViewSeasons is imported
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPlantSelectionDialog() async {
    try {
      // Fetch plants from Firestore
      final querySnapshot =
          await FirebaseFirestore.instance.collection('plants').get();
      final List<Map<String, dynamic>> plants = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'plantName': data['plantName'],
          'category': data['cropType'], // Assuming cropType is the category
          'events': data['events'] ?? [], // Events for the plant
        };
      }).toList();

      final categories =
          plants.map((plant) => plant['category'] as String).toSet().toList();
      categories.insert(0, 'All Categories'); // Add "All Categories" option

      String selectedCategory = 'All Categories';
      TextEditingController searchController = TextEditingController();
      List<Map<String, dynamic>> filteredPlants = plants;

      void filterPlants() {
        filteredPlants = plants.where((plant) {
          final matchesCategory = selectedCategory == 'All Categories' ||
              plant['category'] == selectedCategory;
          final matchesSearch = plant['plantName']
              .toLowerCase()
              .contains(searchController.text.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();
      }

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Select Plant to Track'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                          filterPlants();
                        });
                      },
                      decoration:
                          const InputDecoration(labelText: 'Select Category'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Plant',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filterPlants();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredPlants.length,
                        itemBuilder: (context, index) {
                          final plant = filteredPlants[index];
                          return ListTile(
                            title: Text(plant['plantName']),
                            subtitle: Text('Category: ${plant['category']}'),
                            onTap: () {
                              _addPlantEventsFromFirestore(plant);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load plants: $e')),
      );
    }
  }

  void _addPlantEventsFromFirestore(Map<String, dynamic> plant) {
    final plantingDate =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

    final String plantName = plant['plantName'];
    final String cropType = plant['category'];
    final List<dynamic> events = plant['events'];

    for (var task in events) {
      final eventDate =
          plantingDate.add(Duration(days: task['daysAfterPlanting']));
      final normalizedDate =
          DateTime(eventDate.year, eventDate.month, eventDate.day);

      if (_events[normalizedDate] == null) {
        _events[normalizedDate] = [];
      }

      // Add event details to the calendar
      _events[normalizedDate]!.add(
        '$plantName\n'
        '$cropType\n\n'
        'Event: ${task['event']}\n\n'
        'Note: ${task['note']}',
      );
    }

    // Update selected events and save notes
    _selectedEvents.value = _events[plantingDate] ?? [];
    _saveNotes();
    setState(() {});
  }

  Future<void> _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> encodedEvents = {
      for (var entry in _events.entries)
        entry.key.toIso8601String(): entry.value
    };
    await prefs.setString('plant_events', jsonEncode(encodedEvents));
  }

  void _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('plant_events');
    if (savedData != null) {
      final Map<String, dynamic> decodedEvents =
          Map<String, dynamic>.from(jsonDecode(savedData));
      final Map<DateTime, List<String>> loadedEvents = {};
      for (var entry in decodedEvents.entries) {
        final DateTime date = DateTime.parse(entry.key);
        final List<String> events = List<String>.from(entry.value);
        loadedEvents[date] = events;
      }
      setState(() {
        _events = loadedEvents;
        _selectedEvents.value = _events[_selectedDay] ?? [];
      });
    }
  }

  void _showNotesDialog(DateTime date, List<String> notes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green[50], // Light green background
          title: Text(
            'Notes for ${DateFormat.yMMMd().format(date)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green, // Earthy green text
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width *
                0.8, // Slightly larger width
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: notes
                    .asMap()
                    .entries
                    .map((entry) => Card(
                          color:
                              Colors.green[100], // Light green card background
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(7.0), // Add padding
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      wordSpacing: 1,
                                      color: Colors.brown, // Earthy brown text
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  iconSize: 18, // Smaller icon size
                                  constraints: const BoxConstraints(
                                    minWidth: 30, // Reduce button width
                                    minHeight: 30, // Reduce button height
                                  ),
                                  padding: EdgeInsets
                                      .zero, // Remove internal padding
                                  onPressed: () {
                                    _removeNoteForDate(date, entry.key);
                                    Navigator.pop(context);
                                    _showNotesDialog(date, _events[date] ?? []);
                                  },
                                  tooltip: 'Delete Note',
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _removeAllNotesForDate(date);
                Navigator.pop(context);
              },
              child: const Text(
                'Remove All',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.green), // Green close button
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeNoteForDate(DateTime date, int index) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (_events[normalizedDate] != null &&
        _events[normalizedDate]!.isNotEmpty) {
      _events[normalizedDate]!.removeAt(index);
      if (_events[normalizedDate]!.isEmpty) {
        _events.remove(normalizedDate); // Remove the date if no notes remain
      }
      _saveNotes(); // Save updated notes to SharedPreferences
      setState(() {
        _selectedEvents.value = _events[_selectedDay] ?? [];
      });
    }
  }

  void _removeAllNotesForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (_events[normalizedDate] != null) {
      _events.remove(normalizedDate); // Remove all notes for the date
      _saveNotes(); // Save updated notes to SharedPreferences
      setState(() {
        _selectedEvents.value = _events[_selectedDay] ?? [];
      });
    }
  }

  void _checkForTodayReminder() {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    if (_events[normalizedToday]?.isNotEmpty ?? false) {
      _showNotesDialog(normalizedToday, _events[normalizedToday]!);
    }
  }

  Future<void> _fetchPlantsFromDatabase() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('plants').get();
      final Map<String, List<Map<String, dynamic>>> plantData = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final List<dynamic> events = data['events'] ?? [];
        final String plantName = data['plantName'];
        plantData[plantName] = events.map((event) {
          return {
            'event': event['event'],
            'daysAfterPlanting': event['daysAfterPlanting'],
          };
        }).toList();
      }

      setState(() {
        // Store plant data but do not automatically add events to the calendar
        _plantData = plantData; // Store plant data for manual addition
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch plants: $e')),
      );
    }
  }

  void _removeAllNotesGlobally() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove All Notes'),
          content: const Text(
              'Are you sure you want to remove all notes from the calendar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _events.clear(); // Clear all events
                  _selectedEvents.value = [];
                });
                _saveNotes(); // Save the cleared state to SharedPreferences
                Navigator.pop(context); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'All notes have been removed.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green[700],
                  ),
                );
              },
              child:
                  const Text('Remove All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showPlantTimelineDialog(
      String plantName, List<Map<String, dynamic>> timeline) {
    // Retrieve the planting date for the selected plant
    final plantingDate = _events.keys.firstWhere(
      (date) => _events[date]!.any((event) => event.contains(plantName)),
      orElse: () => _selectedDay, // Fallback to _selectedDay if not found
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Timeline for $plantName',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9, // Constrain width
            height:
                MediaQuery.of(context).size.height * 0.6, // Constrain height
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: timeline.length,
              itemBuilder: (context, index) {
                final event = timeline[index];
                final DateTime expectedDate = plantingDate.add(
                  Duration(days: event['daysAfterPlanting'] - 1),
                ); // Calculate the expected date based on planting date
                return ListTile(
                  leading: const Icon(Icons.timeline, color: Colors.green),
                  title: Text(
                    '${event['event']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${event['daysAfterPlanting']} Day/Days After Planting\n'
                    '${DateFormat.yMMMd().format(expectedDate)}\n',
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
