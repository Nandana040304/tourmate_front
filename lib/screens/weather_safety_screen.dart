import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherSafetyScreen extends StatefulWidget {
  const WeatherSafetyScreen({super.key});

  @override
  State<WeatherSafetyScreen> createState() => _WeatherSafetyScreenState();
}

class _WeatherSafetyScreenState extends State<WeatherSafetyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDestination = '';
  bool _isLoading = false;
  bool _hasLocationPermission = false;
  bool _isSearching = false;
  String? _locationError;
  TouristDestination? _nearestDestination;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.request();
      
      if (status.isGranted) {
        setState(() {
          _hasLocationPermission = true;
        });
        await _getCurrentLocationAndFindNearestPlace();
      } else if (status.isDenied || status.isPermanentlyDenied) {
        setState(() {
          _hasLocationPermission = false;
          _locationError = "Location access is required to show weather and safety information.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasLocationPermission = false;
        _locationError = "Location access is required to show weather and safety information.";
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocationAndFindNearestPlace() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would use geolocator to get actual GPS coordinates
      // For now, we'll simulate getting location and then find the nearest place
      final userLat = 9.9312; // Example: Kochi coordinates
      final userLon = 76.2673;
      
      // Find nearest tourist destination dynamically
      await _findNearestTouristDestination(userLat, userLon);
      
    } catch (e) {
      setState(() {
        _locationError = "Failed to get location. Please try again.";
        _isLoading = false;
      });
    }
  }

  // Find the nearest tourist destination dynamically
  Future<void> _findNearestTouristDestination(double userLat, double userLon) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, this would call a backend API with user coordinates
    // The API would return the nearest tourist destination
    final nearestPlace = await _fetchNearestDestinationFromAPI(userLat, userLon);

    setState(() {
      _nearestDestination = nearestPlace;
      _selectedDestination = nearestPlace.name;
      _searchController.text = nearestPlace.name;
      _isLoading = false;
    });
  }

  // Simulate API call to fetch nearest destination based on location
  Future<TouristDestination> _fetchNearestDestinationFromAPI(double userLat, double userLon) async {
    // This would be a real API call in production
    // For demonstration, we'll generate a random nearby destination
    
    final placeNames = [
      'Scenic Beach', 'Historic Temple', 'City Museum', 'Mountain Viewpoint',
      'Cultural Center', 'Nature Park', 'Waterfront Garden', 'Ancient Monument'
    ];
    
    final random = DateTime.now().millisecond;
    final selectedName = placeNames[random % placeNames.length];
    
    // Generate random weather conditions
    final weatherConditions = ['Sunny', 'Partly Cloudy', 'Light Rain', 'Heavy Rain', 'Cloudy'];
    final selectedWeather = weatherConditions[random % weatherConditions.length];
    
    // Generate weather data based on condition
    double temperature, humidity, windSpeed, rainfall;
    switch (selectedWeather) {
      case 'Sunny':
        temperature = 28 + (random % 5);
        humidity = 60 + (random % 15);
        windSpeed = 5 + (random % 10);
        rainfall = 0;
        break;
      case 'Partly Cloudy':
        temperature = 26 + (random % 4);
        humidity = 70 + (random % 15);
        windSpeed = 10 + (random % 10);
        rainfall = 0;
        break;
      case 'Light Rain':
        temperature = 24 + (random % 3);
        humidity = 80 + (random % 15);
        windSpeed = 15 + (random % 10);
        rainfall = 1.0 + (random % 30) / 10.0;
        break;
      case 'Heavy Rain':
        temperature = 22 + (random % 3);
        humidity = 85 + (random % 10);
        windSpeed = 20 + (random % 15);
        rainfall = 5.0 + (random % 50) / 10.0;
        break;
      case 'Cloudy':
        temperature = 25 + (random % 3);
        humidity = 75 + (random % 15);
        windSpeed = 8 + (random % 8);
        rainfall = 0;
        break;
      default:
        temperature = 26;
        humidity = 70;
        windSpeed = 10;
        rainfall = 0;
    }
    
    // Generate random distance (1-5 km)
    final distance = 1.0 + (random % 40) / 10.0;
    
    return TouristDestination(
      name: selectedName,
      distance: distance,
      latitude: userLat + (random % 100 - 50) / 10000.0,
      longitude: userLon + (random % 100 - 50) / 10000.0,
      weather: WeatherCondition(
        temperature: temperature,
        condition: selectedWeather,
        humidity: humidity.toInt(),
        windSpeed: windSpeed,
        rainfall: rainfall,
      ),
    );
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather & Safety',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildBodyContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (!_hasLocationPermission || _locationError != null) {
      return _buildLocationPermissionError();
    }
    
    if (_nearestDestination == null) {
      return _buildNoDestinationFound();
    }
    
    return _buildWeatherSafetyContent();
  }

  Widget _buildLocationPermissionError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _locationError ?? "Location access is required to show weather and safety information.",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _requestLocationPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
            child: const Text('Enable Location'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDestinationFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.place_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No nearby destinations found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Where are you going?',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherSafetyContent() {
    if (_nearestDestination == null) return const SizedBox();

    final destination = _nearestDestination!;
    final weather = destination.weather;
    final safetyStatus = _calculateSafetyStatus(weather, destination.name);
    final risks = _getTravelRisks(weather, destination.name);
    final recommendations = _getRecommendations(safetyStatus, weather);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeatherCard(weather, destination.name),
          const SizedBox(height: 16),
          _buildSafetyStatusCard(safetyStatus),
          const SizedBox(height: 16),
          if (risks.isNotEmpty) ...[
            _buildTravelRisksCard(risks),
            const SizedBox(height: 16),
          ],
          _buildRecommendationsCard(recommendations),
          const SizedBox(height: 16),
          _buildTripQualityCard(weather),
          const SizedBox(height: 16),
          _buildEmergencyCard(destination),
          const SizedBox(height: 80), // Bottom navigation padding
        ],
      ),
    );
  }

  SafetyStatus _calculateSafetyStatus(WeatherCondition weather, String destination) {
    bool isHilly = destination.toLowerCase().contains('hill') || 
                  destination.toLowerCase().contains('mountain');
    
    if (weather.rainfall > 5.0) {
      return SafetyStatus.notSafe;
    } else if (weather.rainfall > 2.0 && isHilly) {
      return SafetyStatus.notSafe;
    } else if (weather.rainfall > 2.0) {
      return SafetyStatus.caution;
    } else if (weather.windSpeed > 25) {
      return SafetyStatus.caution;
    } else {
      return SafetyStatus.safe;
    }
  }

  List<String> _getTravelRisks(WeatherCondition weather, String destination) {
    List<String> risks = [];
    bool isHilly = destination.toLowerCase().contains('hill') || 
                  destination.toLowerCase().contains('mountain');
    
    if (weather.rainfall > 5.0) {
      risks.add('Heavy rainfall - avoid outdoor activities');
    }
    if (weather.rainfall > 2.0 && isHilly) {
      risks.add('Rain in hilly area - risk of landslides');
    }
    if (weather.rainfall > 2.0) {
      risks.add('Slippery roads - drive carefully');
    }
    if (weather.windSpeed > 20) {
      risks.add('Strong winds - avoid boat rides');
    }
    if (weather.humidity > 85) {
      risks.add('High humidity - stay hydrated');
    }
    
    return risks;
  }

  List<String> _getRecommendations(SafetyStatus status, WeatherCondition weather) {
    List<String> recommendations = [];
    
    switch (status) {
      case SafetyStatus.safe:
        recommendations.addAll([
          'Perfect weather for sightseeing',
          'Great conditions for photography',
          'Safe for outdoor activities',
        ]);
        break;
      case SafetyStatus.caution:
        recommendations.addAll([
          'Carry umbrella or raincoat',
          'Check road conditions before travel',
          'Keep emergency contacts ready',
        ]);
        break;
      case SafetyStatus.notSafe:
        recommendations.addAll([
          'Postpone travel if possible',
          'Avoid outdoor activities',
          'Stay updated with weather alerts',
        ]);
        break;
    }
    
    return recommendations;
  }

  Widget _buildWeatherCard(WeatherCondition weather, String destination) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Weather at $destination',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherItem(
                'Temperature',
                '${weather.temperature}°C',
                Icons.thermostat,
                Colors.orange,
              ),
              _buildWeatherItem(
                'Condition',
                weather.condition,
                _getWeatherIcon(weather.condition),
                Colors.blue,
              ),
              _buildWeatherItem(
                'Humidity',
                '${weather.humidity}%',
                Icons.water_drop,
                Colors.cyan,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherItem(
                'Wind Speed',
                '${weather.windSpeed} km/h',
                Icons.air,
                Colors.grey,
              ),
              _buildWeatherItem(
                'Rainfall',
                '${weather.rainfall} mm',
                Icons.grain,
                Colors.indigo,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'partly cloudy':
        return Icons.cloud;
      case 'light rain':
        return Icons.grain;
      case 'heavy rain':
        return Icons.thunderstorm;
      default:
        return Icons.cloud;
    }
  }

  Widget _buildSafetyStatusCard(SafetyStatus status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    String statusMessage;

    switch (status) {
      case SafetyStatus.safe:
        statusColor = Colors.green;
        statusText = 'Safe to Go';
        statusIcon = Icons.check_circle;
        statusMessage = 'Weather conditions are favorable for travel';
        break;
      case SafetyStatus.caution:
        statusColor = Colors.orange;
        statusText = 'Caution Advised';
        statusIcon = Icons.warning;
        statusMessage = 'Travel with caution, be prepared';
        break;
      case SafetyStatus.notSafe:
        statusColor = Colors.red;
        statusText = 'Not Safe to Go';
        statusIcon = Icons.dangerous;
        statusMessage = 'Avoid travel if possible';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelRisksCard(List<String> risks) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Travel Risks',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...risks.map((risk) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.arrow_right,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    risk,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(List<String> recommendations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Recommended Actions',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((recommendation) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTripQualityCard(WeatherCondition weather) {
    final sightseeingQuality = _getSightseeingQuality(weather);
    final photographyQuality = _getPhotographyQuality(weather);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Trip Quality Indicators',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildQualityIndicator('Sightseeing', sightseeingQuality),
          const SizedBox(height: 8),
          _buildQualityIndicator('Photography', photographyQuality),
        ],
      ),
    );
  }

  Widget _buildQualityIndicator(String label, String quality) {
    Color qualityColor = quality == 'Excellent' ? Colors.green :
                        quality == 'Good' ? Colors.blue :
                        quality == 'Fair' ? Colors.orange : Colors.red;

    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: qualityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            quality,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: qualityColor,
            ),
          ),
        ),
      ],
    );
  }

  String _getSightseeingQuality(WeatherCondition weather) {
    if (weather.rainfall > 5.0) return 'Poor';
    if (weather.rainfall > 2.0) return 'Fair';
    if (weather.windSpeed > 25) return 'Fair';
    if (weather.condition == 'Sunny') return 'Excellent';
    return 'Good';
  }

  String _getPhotographyQuality(WeatherCondition weather) {
    if (weather.rainfall > 2.0) return 'Poor';
    if (weather.condition == 'Sunny') return 'Excellent';
    if (weather.condition == 'Partly Cloudy') return 'Good';
    return 'Fair';
  }

  Widget _buildEmergencyCard(TouristDestination destination) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Emergency Details',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEmergencyItem(
                  'Network Strength',
                  'Good',
                  Icons.signal_cellular_4_bar,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildEmergencyItem(
                  'Medical Help',
                  '2.5 km',
                  Icons.local_hospital,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildEmergencyItem(
                  'Police Station',
                  '1.8 km',
                  Icons.local_police,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildEmergencyItem(
                  'Emergency Contact',
                  '112',
                  Icons.phone,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', false),
          _buildNavItem(Icons.place, 'Places', false),
          _buildSOSButton(),
          _buildNavItem(Icons.book, 'Diary', false),
          _buildNavItem(Icons.more_horiz, 'More', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == 'Home') {
          Navigator.pop(context);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? const Color(0xFF2196F3) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFF2196F3) : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Emergency SOS'),
            content: const Text('Are you sure you want to send an emergency alert?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Send SOS alert
                },
                child: const Text('Send Alert', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.sos,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// Data models
class TouristDestination {
  final String name;
  final double distance;
  final double latitude;
  final double longitude;
  final WeatherCondition weather;

  TouristDestination({
    required this.name,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.weather,
  });
}

class WeatherCondition {
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double rainfall;

  WeatherCondition({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.rainfall,
  });
}

enum SafetyStatus {
  safe,
  caution,
  notSafe,
}
