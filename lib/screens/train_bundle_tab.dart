import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/colors.dart';

class TrainBundleTab extends StatelessWidget {
  const TrainBundleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColorScheme.secondary, AppColorScheme.warning],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColorScheme.secondary.withAlpha(51), // 0.2 opacity
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Bundle Packages',
                  style: AppTheme.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save more with our pre-made travel packages',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white.withAlpha(230), // 0.9 opacity
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Featured Bundle
          _buildFeaturedBundle(),

          const SizedBox(height: 32),

          // Popular Bundles Section
          Text(
            'Popular Bundles',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Bundle Cards
          _buildBundleCard(
            title: 'Bavaria Explorer',
            description: 'Munich to Füssen roundtrip with castle tickets',
            originalPrice: '€89.00',
            bundlePrice: '€69.00',
            savings: 'Save €20.00',
            includes: [
              'Roundtrip train tickets',
              'Neuschwanstein Castle entry',
              'Hohenschwangau Castle entry',
              'Free seat reservation',
            ],
            isPopular: true,
          ),

          const SizedBox(height: 16),

          _buildBundleCard(
            title: 'Weekend Getaway',
            description: 'Berlin to Munich with 2 nights accommodation',
            originalPrice: '€299.00',
            bundlePrice: '€239.00',
            savings: 'Save €60.00',
            includes: [
              'One-way train tickets',
              '2 nights hotel stay',
              'City transport pass',
              'Tourist information pack',
            ],
          ),

          const SizedBox(height: 16),

          _buildBundleCard(
            title: 'Family Adventure',
            description: 'Special family package for 2 adults + 2 children',
            originalPrice: '€179.00',
            bundlePrice: '€149.00',
            savings: 'Save €30.00',
            includes: [
              'Family train tickets',
              'Kids travel entertainment',
              'Snack vouchers',
              'Priority boarding',
            ],
          ),

          const SizedBox(height: 32),

          // Custom Bundle Section
          _buildCustomBundleSection(),
        ],
      ),
    );
  }

  Widget _buildFeaturedBundle() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColorScheme.primary, AppColorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColorScheme.primary.withAlpha(76), // 0.3 opacity
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Featured Badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColorScheme.secondary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25), // 0.1 opacity
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'FEATURED',
                style: AppTheme.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.star,
                  color: AppColorScheme.secondary,
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  'Castle Discovery Premium',
                  style: AppTheme.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ultimate castle experience with VIP access and guided tour',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white.withAlpha(230), // 0.9 opacity
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white.withAlpha(204), // 0.8 opacity
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '€159.00',
                              style: AppTheme.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '€199.00',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white.withAlpha(179), // 0.7 opacity
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => _showBundleDetails(null, 'Castle Discovery Premium'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorScheme.secondary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'View Details',
                        style: AppTheme.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundleCard({
    required String title,
    required String description,
    required String originalPrice,
    required String bundlePrice,
    required String savings,
    required List<String> includes,
    bool isPopular = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPopular
          ? Border.all(color: AppColorScheme.secondary, width: 2)
          : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 opacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Popular Badge
          if (isPopular)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'POPULAR',
                  style: AppTheme.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.titleLarge.copyWith(
                    color: AppColorScheme.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColorScheme.neutral600,
                  ),
                ),
                const SizedBox(height: 16),

                // Price Section
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              bundlePrice,
                              style: AppTheme.titleLarge.copyWith(
                                color: AppColorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              originalPrice,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppColorScheme.neutral500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          savings,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColorScheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Includes Section
                Text(
                  'Includes:',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppColorScheme.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...includes.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColorScheme.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColorScheme.neutral700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

                const SizedBox(height: 20),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => _showBundleDetails(null, title),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Select Bundle',
                      style: AppTheme.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBundleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColorScheme.neutral100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColorScheme.neutral300,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                color: AppColorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Create Custom Bundle',
                style: AppTheme.titleLarge.copyWith(
                  color: AppColorScheme.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Need something specific? Build your own custom travel package.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColorScheme.neutral600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => _showCustomBundleBuilder(null),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColorScheme.primary,
                side: BorderSide(color: AppColorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Build Custom Bundle',
                    style: AppTheme.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBundleDetails(BuildContext? context, String bundleName) {
    // TODO: Navigate to bundle details page
    print('Show details for: $bundleName');
  }

  void _showCustomBundleBuilder(BuildContext? context) {
    // TODO: Navigate to custom bundle builder
    print('Show custom bundle builder');
  }
}