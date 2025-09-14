import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_theme.dart';
import 'select_ticket_screen.dart';
import 'museum_ticket_screen.dart';

class TicketsHomeScreen extends StatelessWidget {
  const TicketsHomeScreen({super.key});

  // Helper method to get image provider with fallback
  ImageProvider _getImageProvider(String imagePath) {
    try {
      return AssetImage(imagePath);
    } catch (e) {
      // Fallback to network images if local assets are not available
      if (imagePath.contains('NeuschwansteinCastle')) {
        return const NetworkImage(
          'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80'
        );
      } else if (imagePath.contains('UffiziGallery')) {
        return const NetworkImage(
          'https://images.unsplash.com/photo-1541362939442-1cf2d9e45d96?w=800&h=600&fit=crop'
        );
      } else {
        // Default fallback
        return const NetworkImage(
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80'
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: const Text('Select Tickets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTheme.headlineSmall.copyWith(
          color: AppColorScheme.neutral900,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTicketCard(
              context: context,
              title: 'Neuschwanstein Castle',
              subtitle: 'Royal Castle Tour',
              imagePath: 'assets/images/Bg-NeuschwansteinCastle.jpg',
              price: 'from €23.50',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectTicketScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildTicketCard(
              context: context,
              title: 'Uffizi Galleries',
              subtitle: 'World-Class Art Museum',
              imagePath: 'assets/images/Bg-UffiziGallery.jpg',
              price: 'from €20.00',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MuseumTicketScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String imagePath,
    required String price,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColorScheme.primary.withOpacity(0.1),
                AppColorScheme.primary.withOpacity(0.3),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 背景圖片
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _getImageProvider(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 漸變覆蓋層
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),

              // 內容
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: AppTheme.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      price,
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // 右上角箭頭圖示
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}