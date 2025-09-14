import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

class TrainRecommendationDialog extends StatelessWidget {
  final VoidCallback onBookTrain;
  final VoidCallback onSkip;

  const TrainRecommendationDialog({
    super.key,
    required this.onBookTrain,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with train icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColorScheme.primary, AppColorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.train,
                color: Colors.white,
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              '🚂 Complete Your Journey!',
              style: AppTheme.headlineMedium.copyWith(
                color: AppColorScheme.neutral900,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Your castle tickets are booked! Now get there comfortably with our train booking service.',
              style: AppTheme.bodyLarge.copyWith(
                color: AppColorScheme.neutral700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Recommended route info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorScheme.primary50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColorScheme.primary200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColorScheme.secondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recommended Route',
                        style: AppTheme.titleSmall.copyWith(
                          color: AppColorScheme.primary700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Munich → Füssen',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppColorScheme.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '2h 15min journey',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppColorScheme.neutral600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'from €16.90',
                        style: AppTheme.titleSmall.copyWith(
                          color: AppColorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Benefits list
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why book with us?',
                    style: AppTheme.titleSmall.copyWith(
                      color: AppColorScheme.neutral800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBenefit('✅ Best prices guaranteed'),
                  _buildBenefit('🎫 Easy mobile tickets'),
                  _buildBenefit('🚄 Direct routes to castle area'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBookTrain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.train, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Book Train Tickets',
                          style: AppTheme.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onSkip,
                    child: Text(
                      'Skip for now',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppColorScheme.neutral600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTheme.bodyMedium.copyWith(
          color: AppColorScheme.neutral700,
        ),
      ),
    );
  }
}