import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: Text(l10n.appTitle.toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTheme.headlineSmall.copyWith(
          color: AppColorScheme.neutral900,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(l10n),
            const SizedBox(height: 32),
            _buildSectionTitle(l10n),
            const SizedBox(height: 20),
            _buildTicketCard(
              context: context,
              title: l10n.neuschwansteinCastle,
              subtitle: l10n.royalCastleTour,
              imagePath: 'assets/images/Bg-NeuschwansteinCastle.jpg',
              price: l10n.fromPrice('€23.50'),
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
              title: l10n.uffiziGalleries,
              subtitle: l10n.worldClassArtMuseum,
              imagePath: 'assets/images/Bg-UffiziGallery.jpg',
              price: l10n.fromPrice('€20.00'),
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
              // Background image
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

              // Gradient overlay
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

              // Content
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

              // Top-right arrow icon
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

  Widget _buildSectionTitle(AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          l10n.popularDestinations,
          style: AppTheme.headlineSmall.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // TODO: Navigate to all destinations
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.viewAll,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorScheme.primary,
            AppColorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flight_takeoff,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.appTitle.toLowerCase(),
                style: AppTheme.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.welcomeToYourDreamJourney,
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.discoverAmazingDestinations,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}