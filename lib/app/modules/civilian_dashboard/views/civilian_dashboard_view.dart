import 'package:d_m/services/location_service.dart';
import 'package:d_m/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:d_m/app/common/widgets/common_scaffold.dart';
import 'package:d_m/app/common/widgets/language_selection_dialog.dart';
import 'package:d_m/app/common/widgets/translatable_text.dart';
import 'package:d_m/widgets/active_disaster_card.dart';

import 'package:d_m/app/modules/user_marketplace.dart'; // Make sure this path is correct

// Import the chatbot scree

class CivilianDashboardView extends StatefulWidget {
  const CivilianDashboardView({super.key});

  @override
  State<CivilianDashboardView> createState() => _CivilianDashboardViewState();
}

class _CivilianDashboardViewState extends State<CivilianDashboardView> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  final WeatherService _weatherService = WeatherService();

  // Dummy function to check if the user is in a risk-free zone
  bool isRiskFree() {
    return DateTime.now().second % 2 == 0; // Example: Changes every second
  }

  @override
  void initState() {
    super.initState();
    _initializeDashboardData();
  }

  Future<void> _initializeDashboardData() async {
    // Attempt to get location and FCM token first.
    // This will populate LocationService.currentCity and LocationService.currentPosition
    try {
      await LocationService.requestLocationAndFCM();
    } catch (e) {
      print("Error initializing location/FCM in dashboard: $e");
      // Decide if you want to set an error message for the whole dashboard here
    }
    // Then fetch weather data, which might use LocationService.currentCity
    _fetchWeatherData();
  }

  String _getCityName() {
    if (_errorMessage != null) {
      return 'Weather Unavailable';
    }
    return LocationService.currentCity ?? 'Current Location';
  }

  String _getWeatherInfo() {
    if (_errorMessage != null) {
      return 'Tap to retry';
    }

    if (_weatherData == null) {
      return '--°C | No data available';
    }

    final temp = _weatherData?['main']?['temp'];
    final description = _weatherData?['weather']?[0]?['description'];

    final tempString = temp != null ? '${temp.toStringAsFixed(1)}°C' : '--°C';

    final descString =
        description != null
            ? description
                .toString()
                .toLowerCase()
                .split(' ')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' ')
            : 'Weather info unavailable';

    return '$tempString | $descString';
  }

  IconData _getWeatherIcon() {
    if (_errorMessage != null) {
      return Icons.cloud_off;
    }

    if (_weatherData == null) {
      return Icons.cloud_outlined;
    }

    final weatherMain =
        _weatherData?['weather']?[0]?['main']?.toString().toLowerCase();

    switch (weatherMain) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.umbrella;
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.cloud;
    }
  }

  Color _getWeatherColor() {
    if (_errorMessage != null) {
      return Colors.red;
    }

    final weatherMain =
        _weatherData?['weather']?[0]?['main']?.toString().toLowerCase();

    switch (weatherMain) {
      case 'clear':
        return Colors.orange;
      case 'rain':
      case 'drizzle':
        return Colors.blue;
      case 'thunderstorm':
        return Colors.purple;
      case 'snow':
        return Colors.lightBlue;
      case 'clouds':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? city = LocationService.currentCity;

    if (city == null || city.isEmpty) {
      setState(() {
        _errorMessage = 'City not found.';
        _isLoading = false;
      });
      return;
    }

    try {
      _weatherData = await _weatherService.fetchWeather(city);
    } catch (e) {
      _errorMessage = 'Could not fetch weather.';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFF5F6898);
    final Color communityBackground = const Color(0xFFE3F2FD);

    // Determine the risk status dynamically
    bool riskFree = isRiskFree();
    Color riskCardColor = riskFree ? Colors.green[100]! : Colors.green[100]!;

    String riskText =
        riskFree
            ? "You are in a Risk-Free Zone"
            : "You are in a Risk-Free Zone!";

    Color riskTextColor = riskFree ? Colors.green[900]! : Colors.green[900]!;

    return CommonScaffold(
      title: 'Dashboard',
      currentIndex: 0, // Home index
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // BUTTON TILES (Predictive AI and Learn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [],
                ),
                const SizedBox(height: 8),

                // RISK STATUS SECTION
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: riskCardColor,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        riskFree ? Icons.check_circle : Icons.warning,
                        color: riskTextColor,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      TranslatableText(
                        riskText,
                        style: TextStyle(
                          color: riskTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // ACTIVE DISASTER SECTION
                const ActiveDisasterCard(),

                // COMMUNITY SECTION
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: communityBackground,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Community Post Header
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundImage: AssetImage(
                                  "assets/images/default_user.png",
                                ),
                              ),
                              const SizedBox(width: 8),
                              const TranslatableText(
                                'NDRF - Disaster Response',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {},
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Post Content
                          const TranslatableText(
                            'A 6.2 magnitude earthquake struck Manipur today, causing tremors across the region. Our teams are assessing damage, and emergency relief camps have been set up in Imphal and nearby areas. Citizens are advised to stay alert and follow safety protocols.',
                            style: TextStyle(fontSize: 14),
                          ),

                          const SizedBox(height: 8),

                          // Earthquake Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              "assets/images/dummy_img.jpg",
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Reaction Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildReactionIcon(
                                icon: Icons.thumb_up_alt_outlined,
                                label: 'Like',
                              ),
                              _buildReactionIcon(
                                icon: Icons.mode_comment_outlined,
                                label: 'Comment',
                              ),
                              _buildReactionIcon(
                                icon: Icons.share_outlined,
                                label: 'Share',
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // History Button
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/community_history',
                                  arguments: {
                                    'author': 'Disaster Response team',
                                    'content':
                                        'A 6.2 magnitude earthquake struck Manipur today. Relief camps are being set up. Stay alert and follow safety protocols.',
                                  },
                                );
                              },
                              child: const TranslatableText('View Community'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // WEATHER CARD
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getWeatherIcon(),
                        size: 48,
                        color: _getWeatherColor(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child:
                            _isLoading
                                ? const Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Loading weather...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatableText(
                                      _getCityName(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _errorMessage != null
                                                ? Colors.red
                                                : null,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    TranslatableText(
                                      _getWeatherInfo(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            _errorMessage != null
                                                ? Colors.red.shade700
                                                : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Ecommerce button
          Positioned(
            bottom: 165, // Adjusted to avoid overlap
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Color(0xFF5F6898),
              heroTag: "marketplace", // Add unique hero tag
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserMarketplacePage(),
                    ),
                  ),
              child: const Icon(Icons.shopping_cart, color: Colors.white),
            ),
          ),

          // Floating AI Chatbot Button
          Positioned(
            bottom: 101,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: accentColor,
              heroTag: "chatbot", // Add unique hero tag
              onPressed: () {
                Navigator.pushNamed(context, '/ai_chatbot');
              },
              child: Image.asset(
                'assets/images/chatbot1.png',
                width: 28,
                height: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for dashboard tile
  Widget _buildDashboardTile({
    required BuildContext context,
    required String title,
    required Color color,
    required String routeName,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: TranslatableText(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for reaction icons
  Widget _buildReactionIcon({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        TranslatableText(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
