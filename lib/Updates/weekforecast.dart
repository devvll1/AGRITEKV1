// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino icons
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class SevenDaysForecastScreen extends StatefulWidget {
  const SevenDaysForecastScreen({super.key});

  @override
  _SevenDaysForecastScreenState createState() =>
      _SevenDaysForecastScreenState();
}

class _SevenDaysForecastScreenState extends State<SevenDaysForecastScreen> {
  List<Map<String, dynamic>> forecast = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      double lat = position.latitude;
      double lon = position.longitude;
      _fetchSevenDayForecast(lat, lon);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching location: $e");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchSevenDayForecast(double lat, double lon) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode&timezone=auto';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['daily'] != null) {
          setState(() {
            forecast = List.generate(7, (index) {
              final date = DateTime.parse(data['daily']['time'][index]);
              final maxTemp = data['daily']['temperature_2m_max'][index];
              final minTemp = data['daily']['temperature_2m_min'][index];
              final precipitationChance =
                  data['daily']['precipitation_probability_max'][index];

              return {
                'date': DateFormat('EEEE, MMM d').format(date),
                'maxTemp': maxTemp,
                'minTemp': minTemp,
                'precipitationChance': precipitationChance,
                'description':
                    _getWeatherDescription(data['daily']['weathercode'][index]),
              };
            });
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch forecast data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  String _getWeatherDescription(int code) {
  switch (code) {
    case 0:
      return 'Clear skies';
    case 1:
      return 'Mainly clear';
    case 2:
      return 'Partly cloudy';
    case 3:
      return 'Overcast';
    case 45:
    case 48:
      return 'Foggy';
    case 51:
      return 'Light drizzle';
    case 53:
      return 'Moderate drizzle';
    case 55:
      return 'Dense drizzle';
    case 56:
      return 'Freezing light drizzle';
    case 57:
      return 'Freezing dense drizzle';
    case 61:
      return 'Slight rain';
    case 63:
      return 'Moderate rain';
    case 65:
      return 'Heavy rain';
    case 66:
      return 'Freezing light rain';
    case 67:
      return 'Freezing heavy rain';
    case 71:
      return 'Slight snowfall';
    case 73:
      return 'Moderate snowfall';
    case 75:
      return 'Heavy snowfall';
    case 77:
      return 'Snow grains';
    case 80:
      return 'Slight rain showers';
    case 81:
      return 'Moderate rain showers';
    case 82:
      return 'Violent rain showers';
    case 85:
      return 'Slight snow showers';
    case 86:
      return 'Heavy snow showers';
    case 95:
      return 'Thunderstorm';
    case 96:
      return 'Thunderstorm with slight hail';
    case 99:
      return 'Thunderstorm with heavy hail';
    default:
      return 'Unknown';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('7-Day Weather Forecast'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: forecast.length,
              itemBuilder: (context, index) {
                final day = forecast[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day['date'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.thermometer,
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Text('Max Temp: ${day['maxTemp']}°C'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.snow, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Min Temp: ${day['minTemp']}°C'),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.cloud_rain,
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Precipitation: ${day['precipitationChance']}%'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.cloud, size: 20),
                                    const SizedBox(width: 8),
                                    Text(day['description']),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
