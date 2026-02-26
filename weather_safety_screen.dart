import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

class WeatherSafetyScreen extends StatefulWidget {
  const WeatherSafetyScreen({super.key});

  @override
  State<WeatherSafetyScreen> createState() => _WeatherSafetyScreenState();
}

class _WeatherSafetyScreenState extends State<WeatherSafetyScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  TouristDestination? _result;
  String _safetyStatus = "";

  Future<void> _searchWeather() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
          "http://127.0.0.1:8000/api/weather/?destination=${Uri.encodeComponent(_searchController.text.trim())}");

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      final weather = data['weather'];

      setState(() {
        _result = TouristDestination(
          name: data['destination'],
          distance: 0,
          latitude: 0,
          longitude: 0,
          weather: WeatherCondition(
            temperature: (weather['temperature'] as num).toDouble(),
            condition: weather['condition'],
            humidity: weather['humidity'],
            windSpeed: (weather['windSpeed'] as num).toDouble(),
            rainfall: (weather['rainfall'] as num).toDouble(),
          ),
        );
        _safetyStatus = data['safetyStatus'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Color _getSafetyColor() {
    return _safetyStatus.toLowerCase() == "safe"
        ? Colors.green
        : Colors.red;
  }

  IconData _getWeatherIcon(String condition) {
    if (condition.toLowerCase().contains("rain")) {
      return Icons.cloud;
    } else if (condition.toLowerCase().contains("cloud")) {
      return Icons.cloud_queue;
    } else {
      return Icons.wb_sunny;
    }
  }

  Widget _buildWeatherCard() {
    if (_result == null) return const SizedBox();

    final weather = _result!.weather;

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _result!.name.toUpperCase(),
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),

            Icon(
              _getWeatherIcon(weather.condition),
              size: 70,
              color: Colors.white,
            ),

            const SizedBox(height: 10),
            Text(
              "${weather.temperature}°C",
              style: const TextStyle(
                  fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),

            Text(
              weather.condition,
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoTile(Icons.water_drop, "Humidity", "${weather.humidity}%"),
                _infoTile(Icons.air, "Wind", "${weather.windSpeed} m/s"),
                _infoTile(Icons.umbrella, "Rain", "${weather.rainfall} mm"),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: _getSafetyColor(),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "Safety: ${_safetyStatus.toUpperCase()}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Weather & Safety"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
      ),

      // 🔥 FIXED OVERFLOW HERE
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(15),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search destination (e.g., Munnar)",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _searchWeather,
                icon: const Icon(Icons.cloud),
                label: const Text("Get Weather"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: const Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
              if (!_isLoading) _buildWeatherCard(),
            ],
          ),
        ),
      ),
    );
  }
}