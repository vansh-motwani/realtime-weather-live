import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String selectedCity = '';
  Map<String, dynamic> weatherData = {};
  bool isLoading = false;
  bool hasError = false;

  List<String> cities = [
    'Delhi',
    'Mumbai',
    'Chennai',
    'Bangalore',
    'Kolkata',
    'Hyderabad'
  ];

  Future<void> fetchWeatherData(String city) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final url = 'https://vansh-backend.onrender.com/api/live_search';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'city': city}),
      );

      if (response.statusCode == 201) {
        setState(() {
          weatherData = json.decode(response.body);
          isLoading = false;
        });
        print('Weather data received: $weatherData');
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        print('Error status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  String _getWeatherCondition() {
    if (weatherData.containsKey('weatherData') && 
        weatherData['weatherData'].containsKey('weather') && 
        weatherData['weatherData']['weather'] is List && 
        weatherData['weatherData']['weather'].isNotEmpty) {
      return weatherData['weatherData']['weather'][0]['main'] ?? '-';
    }
    return '-';
  }

  String _getTemperature() {
    if (weatherData.containsKey('weatherData') && 
        weatherData['weatherData'].containsKey('main') && 
        weatherData['weatherData']['main'].containsKey('temp')) {
      return '${weatherData['weatherData']['main']['temp'].toStringAsFixed(1)}°C';
    }
    return '-';
  }

  String _getHumidity() {
    if (weatherData.containsKey('weatherData') && 
        weatherData['weatherData'].containsKey('main') && 
        weatherData['weatherData']['main'].containsKey('humidity')) {
      return '${weatherData['weatherData']['main']['humidity']}%';
    }
    return '-';
  }

  String _getWindSpeed() {
    if (weatherData.containsKey('weatherData') && 
        weatherData['weatherData'].containsKey('wind') && 
        weatherData['weatherData']['wind'].containsKey('speed')) {
      return '${weatherData['weatherData']['wind']['speed']} km/h';
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          image: DecorationImage(
            image: const NetworkImage('https://picsum.photos/1600/900?blur=2'),
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 1200,
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // City Selector
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Colors.white.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          child: DropdownButton<String>(
                            value: selectedCity.isEmpty ? null : selectedCity,
                            hint: const Text('Select a City',
                                style: TextStyle(color: Colors.white, fontSize: 20)),
                            isExpanded: true,
                            dropdownColor: Colors.black.withOpacity(0.8),
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedCity = newValue;
                                  fetchWeatherData(newValue);
                                });
                              }
                            },
                            items: cities.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            underline: Container(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Weather Information
                      if (isLoading)
                        const Center(child: CircularProgressIndicator(color: Colors.white))
                      else if (hasError)
                        Center(
                          child: Card(
                            color: Colors.red.withOpacity(0.3),
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Error fetching weather data',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        )
                      else if (weatherData.isNotEmpty)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Wrap(
                                spacing: 20,
                                runSpacing: 20,
                                alignment: WrapAlignment.center,
                                children: [
                                  // Temperature Tile - Made Larger
                                  _buildWeatherTile(
                                    icon: Icons.thermostat_outlined,
                                    title: 'Temperature',
                                    value: _getTemperature(),
                                    constraints: constraints,
                                    isLarge: true,
                                  ),
                                  
                                  // Weather Condition Tile - Made Larger
                                  _buildWeatherTile(
                                    icon: Icons.wb_sunny_outlined,
                                    title: 'Condition',
                                    value: _getWeatherCondition(),
                                    constraints: constraints,
                                    isLarge: true,
                                  ),

                                  // Other Weather Details
                                  _buildWeatherTile(
                                    icon: Icons.water_drop_outlined,
                                    title: 'Humidity',
                                    value: _getHumidity(),
                                    constraints: constraints,
                                  ),
                                  _buildWeatherTile(
                                    icon: Icons.wind_power_outlined,
                                    title: 'Wind Speed',
                                    value: _getWindSpeed(),
                                    constraints: constraints,
                                  ),
                                  _buildWeatherTile(
                                    icon: Icons.update_outlined,
                                    title: 'Last Updated',
                                    value: DateTime.now().toString().substring(0, 16),
                                    constraints: constraints,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherTile({
    required IconData icon,
    required String title,
    required String value,
    required BoxConstraints constraints,
    bool isLarge = false,
  }) {
    // Calculate tile width based on container width and if it's a large tile
    double tileWidth = constraints.maxWidth > 900 
        ? (constraints.maxWidth - 80) / 3   // 3 columns for large screens
        : constraints.maxWidth > 600 
            ? (constraints.maxWidth - 60) / 2   // 2 columns for medium screens
            : constraints.maxWidth - 40;        // 1 column for small screens

    // If it's a large tile, make it wider
    if (isLarge && constraints.maxWidth > 600) {
      tileWidth = (constraints.maxWidth - 60) / 2;
    }

    return Container(
      width: tileWidth,
      padding: EdgeInsets.all(isLarge ? 25 : 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isLarge ? 0.25 : 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: isLarge ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            size: isLarge ? 50 : 40, 
            color: Colors.white
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLarge ? 20 : 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLarge ? 32 : 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}