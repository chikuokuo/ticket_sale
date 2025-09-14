import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../models/rail_pass.dart';
import 'rail_pass_purchase_screen.dart';

class TrainBundleTab extends StatefulWidget {
  const TrainBundleTab({super.key});

  @override
  State<TrainBundleTab> createState() => _TrainBundleTabState();
}

class _TrainBundleTabState extends State<TrainBundleTab> {
  TicketCategory selectedCategory = TicketCategory.individual;

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
                colors: [AppColorScheme.primary, AppColorScheme.info],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColorScheme.primary.withAlpha(51), // 0.2 opacity
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.train,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'European Rail Passes',
                  style: AppTheme.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Flexible train travel across Europe with unlimited journeys',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white.withAlpha(230), // 0.9 opacity
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Available Rail Passes Section
          Text(
            'Available Rail Passes',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Rail Pass Cards
          ...RailPassData.passes.map((pass) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildRailPassCard(pass),
          )),

          const SizedBox(height: 32),

          // Custom Bundle Section
          _buildCustomBundleSection(),
        ],
      ),
    );
  }

  Widget _buildFeaturedRailPass() {
    final italyPass = RailPassData.getPassById('italy')!;
    final pricing = italyPass.pricing.first; // 3-day pricing
    final currentPrice = _getPriceForCategory(pricing);

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
                Text(
                  italyPass.flagIcon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  italyPass.name,
                  style: AppTheme.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  italyPass.description,
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
                          'From (${pricing.days} days)',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white.withAlpha(204), // 0.8 opacity
                          ),
                        ),
                        Text(
                          '${pricing.currency}${currentPrice.toStringAsFixed(0)}',
                          style: AppTheme.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => _showPassDetails(italyPass),
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

  Widget _buildRailPassCard(RailPass pass) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: pass.isPopular
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
          if (pass.isPopular)
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
                Row(
                  children: [
                    Text(
                      pass.flagIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pass.name,
                            style: AppTheme.titleLarge.copyWith(
                              color: AppColorScheme.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            pass.description,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppColorScheme.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pricing Options
                Text(
                  'Flexible Days (Individual):',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppColorScheme.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: pass.pricing.map((pricing) {
                    final price = _getPriceForCategory(pricing);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColorScheme.primary100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColorScheme.primary200),
                      ),
                      child: Text(
                        '${pricing.days} days: ${pricing.currency}${price.toStringAsFixed(0)}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppColorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Features
                Text(
                  'Features:',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppColorScheme.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...pass.features.take(3).map((feature) => Padding(
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
                          feature,
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
                    onPressed: () => _showPassDetails(pass),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Select Pass',
                      style: AppTheme.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white
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
                'Custom Multi-Country Pass',
                style: AppTheme.titleLarge.copyWith(
                  color: AppColorScheme.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Need to travel across multiple countries? Build your own custom European rail pass.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColorScheme.neutral600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => _showCustomPassBuilder(),
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
                    'Build Custom Pass',
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

  double _getPriceForCategory(RailPassPricing pricing) {
    return pricing.individualPrice;
  }

  void _showPassDetails(RailPass pass) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RailPassPurchaseScreen(railPass: pass),
      ),
    );
  }

  void _showCustomPassBuilder() {
    // TODO: Navigate to custom multi-country pass builder
    print('Show custom multi-country pass builder');
  }
}