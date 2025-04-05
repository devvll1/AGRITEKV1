import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Import for date formatting

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  String weather = 'Loading...';
  String location = 'Fetching location...';
  double temperature = 0;
  int humidity = 0;
  double windSpeed = 0;
  double windGust = 0;
  double precipChance = 0;
  double lat = 0;
  double lon = 0;
  String currentTime = ''; // Add a field for the current time
  String currentDate = ''; // Add a field for the current date
  List<Map<String, dynamic>> nextTwoDaysForecast = [];
  bool isLoadingForecast = true;

  // Add a list to store hourly forecast data
  List<Map<String, dynamic>> hourlyForecast = [];
  bool isLoadingHourlyForecast = true;

  // Add a variable to store tomorrow's forecast
  Map<String, dynamic>? tomorrowsForecast;
  bool isLoadingTomorrowsForecast = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _updateTime(); // Fetch the time when the widget is initialized
    _fetchHourlyForecast(); // Fetch the hourly forecast
    _fetchTomorrowsForecast(); // Fetch tomorrow's forecast
  }

  Future<void> _getCurrentLocation() async {
    Position position = await _determinePosition();
    lat = position.latitude;
    lon = position.longitude;
    _fetchWeather(lat, lon);
    _fetchLocationName(lat, lon);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check location permissions
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

    // Get the current position with high accuracy
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relativehumidity_2m,windspeed_10m,windgusts_10m,precipitation_probability';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (mounted) {
        setState(() {
          weather =
              _getWeatherDescription(data['current_weather']['weathercode']);
          temperature = data['current_weather']['temperature'];
          humidity = data['hourly']['relativehumidity_2m']?[0] ?? 0;
          windSpeed = data['current_weather']['windspeed'];
          windGust = data['hourly']['windgusts_10m']?[0] ?? 0;
          precipChance =
              (data['hourly']['precipitation_probability']?[0] ?? 0).toDouble();
          _updateTime();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          weather = 'Failed to load weather data';
        });
      }
    }
  }

  Future<void> _fetchLocationName(double lat, double lon) async {
    final url =
        'https://api.opencagedata.com/geocode/v1/json?q=$lat+$lon&key=269b80706cd84223a9ac0155bb6b285c';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (mounted) {
        setState(() {
          // Extract the necessary components
          final components = data['results'][0]['components'];
          String formattedLocation = '';

          // Include city and province (or state)
          if (components['city'] != null) {
            formattedLocation += components['city'] + ', ';
          } else if (components['town'] != null) {
            // Fallback to town if city is not available
            formattedLocation += components['town'] + ', ';
          }

          if (components['state'] != null) {
            formattedLocation += components['state'];
          } else if (components['region'] != null) {
            // Fallback to region if state is not available
            formattedLocation += components['region'];
          }

          // Remove trailing comma and space if necessary
          formattedLocation =
              formattedLocation.replaceAll(RegExp(r',\s*$'), '');

          location = formattedLocation.isNotEmpty
              ? formattedLocation
              : 'Unknown location';
          _updateTime(); // Update the time when location data is fetched
        });
      }
    } else {
      if (mounted) {
        setState(() {
          location = 'Unknown location';
        });
      }
    }
  }

  // Function to update the current time
  void _updateTime() {
    final now = DateTime.now();
    final formattedDate =
        DateFormat('EEEE, d MMM').format(now); // e.g., "Monday, 4 Oct"

    setState(() {
      currentTime =
          '${now.hour}:${now.minute.toString().padLeft(2, '0')}'; // Format time as HH:MM
      currentDate = formattedDate; // Add formatted date
    });
  }

  // Updated _fetchHourlyForecast to use _getWeatherIcon
  Future<void> _fetchHourlyForecast() async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,precipitation_probability,weathercode&timezone=auto';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['hourly'] != null) {
          setState(() {
            hourlyForecast = List.generate(48, (index) {
              final time = DateTime.parse(data['hourly']['time'][index]);
              final temperature = data['hourly']['temperature_2m'][index];
              final precipitationChance =
                  data['hourly']['precipitation_probability'][index];
              final weatherCode = data['hourly']['weathercode'][index];
              final description = _getWeatherDescription(weatherCode);

              return {
                'time':
                    DateFormat('h a').format(time), // Format time as "12 PM"
                'temperature': temperature,
                'precipitationChance': precipitationChance,
                'description': description,
                'icon': _getWeatherIcon(description), // Use _getWeatherIcon
              };
            });
            isLoadingHourlyForecast = false;
          });
        }
      } else {
        throw Exception('Failed to fetch hourly forecast data');
      }
    } catch (e) {
      setState(() {
        isLoadingHourlyForecast = false;
      });
      debugPrint(e.toString());
    }
  }

  Future<void> _fetchTomorrowsForecast() async {
    // Use the current location's latitude and longitude
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode&timezone=auto';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['daily'] != null) {
          setState(() {
            // Debug the API response to verify the structure
            debugPrint('Daily Forecast Data: ${data['daily']}');

            // Use the same logic as the 7-day forecast
            final date =
                DateTime.parse(data['daily']['time'][1]); // Tomorrow's date
            final maxTemp = data['daily']['temperature_2m_max'][1];
            final minTemp = data['daily']['temperature_2m_min'][1];
            final avgTemp = ((maxTemp + minTemp) / 2)
                .toStringAsFixed(1); // Average temperature
            final precipitationChance =
                data['daily']['precipitation_probability_max'][1];
            final weatherCode = data['daily']['weathercode'][1];
            final description = _getWeatherDescription(weatherCode);

            tomorrowsForecast = {
              'date': DateFormat('EEEE, MMM d').format(date),
              'avgTemp': avgTemp,
              'precipitationChance': precipitationChance,
              'description': description,
              'icon': _getWeatherIcon(description),
            };
            isLoadingTomorrowsForecast = false;
          });
        }
      } else {
        throw Exception('Failed to fetch tomorrow\'s forecast data');
      }
    } catch (e) {
      setState(() {
        isLoadingTomorrowsForecast = false;
      });
      debugPrint('Error fetching tomorrow\'s forecast: $e');
    }
  }

  // Helper method to get weather description based on weather code
  String _getWeatherDescription(int code) {
    // Check if the location is in a tropical region (e.g., Philippines)
    bool isTropicalRegion = location.toLowerCase().contains('philippines');

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
        return isTropicalRegion ? 'Heavy rain' : 'Freezing light rain';
      case 67:
        return isTropicalRegion ? 'Heavy rain' : 'Freezing heavy rain';
      case 71:
        return isTropicalRegion ? 'Rain' : 'Slight snowfall';
      case 73:
        return isTropicalRegion ? 'Rain' : 'Moderate snowfall';
      case 75:
        return isTropicalRegion ? 'Rain' : 'Heavy snowfall';
      case 77:
        return isTropicalRegion ? 'Rain' : 'Snow grains';
      case 80:
        return 'Slight rain showers';
      case 81:
        return 'Moderate rain showers';
      case 82:
        return 'Violent rain showers';
      case 85:
        return isTropicalRegion ? 'Rain showers' : 'Slight snow showers';
      case 86:
        return isTropicalRegion ? 'Rain showers' : 'Heavy snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
        return isTropicalRegion
            ? 'Thunderstorm'
            : 'Thunderstorm with slight hail';
      case 99:
        return isTropicalRegion
            ? 'Thunderstorm'
            : 'Thunderstorm with heavy hail';
      default:
        return 'Unknown';
    }
  }

  // Helper method to get weather icon based on weather description
  IconData _getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case 'clear skies':
        return CupertinoIcons.sun_max_fill;
      case 'mainly clear':
      case 'partly cloudy':
        return CupertinoIcons.cloud_sun_fill;
      case 'overcast':
        return CupertinoIcons.cloud_fill;
      case 'foggy':
        return CupertinoIcons.cloud_fog_fill;
      case 'light drizzle':
      case 'moderate drizzle':
      case 'dense drizzle':
        return CupertinoIcons.cloud_drizzle_fill;
      case 'slight rain':
      case 'moderate rain':
      case 'heavy rain':
        return CupertinoIcons.cloud_rain_fill;
      case 'slight rain showers':
      case 'moderate rain showers':
      case 'violent rain showers':
        return CupertinoIcons.cloud_bolt_rain_fill;
      case 'slight snowfall':
      case 'moderate snowfall':
      case 'heavy snowfall':
        return CupertinoIcons.snow;
      case 'snow grains':
        return CupertinoIcons.snow;
      case 'thunderstorm':
        return CupertinoIcons.cloud_bolt_fill;
      case 'thunderstorm with slight hail':
      case 'thunderstorm with heavy hail':
        return CupertinoIcons.cloud_hail_fill;
      default:
        // Fallback icon for unknown weather descriptions
        return CupertinoIcons.question_circle_fill;
    }
  }

  // Reusable widget for weather details
  Widget _buildWeatherCard(String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the main weather info card
  Widget _buildWeatherInfoCard() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Weather Icon and Temperature
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getWeatherIcon(weather), // Dynamically get the weather icon
                  size: 55,
                  color: Colors.blue,
                ),
                Text(
                  '${temperature.toStringAsFixed(0)}°C',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(temperature * 1.8 + 32).toStringAsFixed(1)}°F',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            // Weather Description and Location
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  weather,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  currentDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  currentTime,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the weather details card
  Widget _buildWeatherDetailsCard() {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWeatherCard('Wind Speed',
                '${windSpeed.toStringAsFixed(1)} km/h', CupertinoIcons.wind),
            _buildWeatherCard(
                'Humidity', '$humidity%', CupertinoIcons.drop_fill),
            _buildWeatherCard(
                'Precipitation',
                '${precipChance.toStringAsFixed(0)}%',
                CupertinoIcons.cloud_rain),
          ],
        ),
      ),
    );
  }

  // Updated _buildHourlyForecast to display icons from _getWeatherIcon
  Widget _buildHourlyForecast() {
    if (isLoadingHourlyForecast) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title for the Hourly Forecast
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Hourly Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        // Horizontal ListView for Hourly Forecast
        SizedBox(
          height: 140, // Height for larger cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyForecast.length,
            itemBuilder: (context, index) {
              final hour = hourlyForecast[index];
              return SizedBox(
                width: 130, // Set a fixed width for wider cards
                child: Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(10.0), // Padding inside the card
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hour['icon'], // Use icon from _getWeatherIcon
                          size: 30, // Icon size
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          hour['time'],
                          style: const TextStyle(
                            fontSize: 14, // Font size for time
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${hour['temperature']}°C',
                          style: const TextStyle(
                            fontSize: 14, // Font size for temperature
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${hour['precipitationChance']}% Rain',
                          style: const TextStyle(
                            fontSize: 12, // Font size for precipitation chance
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Updated _buildTomorrowsForecast to display average temperature, precipitation, and description
  Widget _buildTomorrowsForecast() {
    if (isLoadingTomorrowsForecast) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tomorrowsForecast == null) {
      return const Center(
        child: Text(
          'Failed to load tomorrow\'s forecast',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title for Tomorrow's Forecast
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Tomorrow\'s Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        // Tomorrow's Forecast Card
        Card(
          color: Colors.white.withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Weather Details (Left Side)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tomorrowsForecast!['date'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Avg Temp: ${tomorrowsForecast!['avgTemp']}°C',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Precipitation: ${tomorrowsForecast!['precipitationChance']}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tomorrowsForecast!['description'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                // Weather Icon (Right Side)
                Icon(
                  tomorrowsForecast!['icon'], // Use icon from _getWeatherIcon
                  size: 55,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(
            color: const Color.fromARGB(
                255, 110, 175, 227), // Set background color
          ),
          // Back button and title in the upper left corner
          Positioned(
            top: 17,
            left: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pushNamed(context, '/homepage');
                  },
                ),
                const SizedBox(
                    width: 5), // Space between the back button and title
                const Text(
                  'Current Weather',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                  height: 50), // Space below the back button and title
              // Weather Card
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    _buildWeatherInfoCard(),
                    // Wind, Humidity, Precipitation Section
                    _buildWeatherDetailsCard(),
                    // Hourly Forecast Section
                    _buildHourlyForecast(),
                    // Tomorrow's Forecast Section
                    _buildTomorrowsForecast(),
                    // Weekly Forecast Button
                    Align(
                      alignment:
                          Alignment.centerRight, // Align button to the right
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forecast');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                          ),
                          child: const Text(
                            'View Weekly Forecast',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
