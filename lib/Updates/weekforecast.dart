// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
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
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,windspeed_10m_max,windgusts_10m_max,precipitation_probability_max,weathercode&timezone=auto';

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
              final windSpeed = data['daily']['windspeed_10m_max'][index];
              final windGust = data['daily']['windgusts_10m_max'][index];
              final precipitationChance =
                  data['daily']['precipitation_probability_max'][index];

              return {
                'date': DateFormat('EEEE, MMM d').format(date),
                'maxTemp': maxTemp,
                'minTemp': minTemp,
                'windSpeed': windSpeed,
                'windGust': windGust,
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
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snowfall';
      case 95:
        return 'Thunderstorm';
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
                                Text('Max Temp: ${day['maxTemp']}°C'),
                                Text('Min Temp: ${day['minTemp']}°C'),
                                Text(
                                    'Precipitation Chance: ${day['precipitationChance']}%'),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Wind: ${day['windSpeed']} km/h'),
                                Text('Wind Gust: ${day['windGust']} km/h'),
                                Text(day['description']),
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
