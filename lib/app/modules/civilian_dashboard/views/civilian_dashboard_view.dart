import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:d_m/app/common/widgets/common_scaffold.dart'; // Adjust your import path
import 'package:d_m/app/modules/login_page.dart';

class CivilianDashboardView extends StatelessWidget {
  const CivilianDashboardView({super.key});

  // Dummy function to check if the user is in a risk-free zone
  bool isRiskFree() {
    return DateTime.now().second % 2 == 0; // Example: Changes every second
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFF5F6898);
    final Color communityBackground = const Color(0xFFE3F2FD);

    // Determine the risk status dynamically
    bool riskFree = isRiskFree();
    Color riskCardColor = riskFree ? Colors.green[100]! : Colors.red[100]!;
    String riskText = riskFree ? "You are in a Risk-Free Zone" : "You are in a High-Risk Zone!";
    Color riskTextColor = riskFree ? Colors.green[900]! : Colors.red[900]!;

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
                  children: [
                    _buildDashboardTile(
                      context: context,
                      title: 'PREDICTIVE AI',
                      color: accentColor,
                      routeName: '/predictive_ai',
                    ),
                    _buildDashboardTile(
                      context: context,
                      title: 'LEARN',
                      color: accentColor,
                      routeName: '/learn',
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // RISK STATUS SECTION
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: riskCardColor,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
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
                      Text(
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

                // COMMUNITY SECTION
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: communityBackground,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Community Post Header
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'NDRF',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                // TODO: Show post options
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Community Post Content
                        const Text(
                          'This is a sample community post showing real-time updates on disaster management. Stay alert and follow the instructions provided.',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        // Reaction Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildReactionIcon(icon: Icons.thumb_up_alt_outlined, label: 'Like'),
                            _buildReactionIcon(icon: Icons.mode_comment_outlined, label: 'Comment'),
                            _buildReactionIcon(icon: Icons.share_outlined, label: 'Share'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // History Button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/community_history');
                            },
                            child: const Text('History'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // WEATHER CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud, size: 48, color: Colors.blue),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Manipur, Imphal',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text('28° | Sunny'),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          // Floating AI Chatbot Button
          Positioned(
            bottom: 101, // Adjusted position
            right: 16,
            child: FloatingActionButton(
              backgroundColor: accentColor,
              onPressed: () {
                Navigator.pushNamed(context, '/ai_chatbot'); // Navigate to chatbot page
              },
              child: Image.asset(
                'assets/images/chatbot.png',
                width: 28, // Set the width
                height: 28, // Set the height
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
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
