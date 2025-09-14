import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

class TrainTicketScreen extends StatelessWidget {
  const TrainTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: const Text('Train Ticket'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorScheme.neutral900),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColorScheme.primary, AppColorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColorScheme.primary.withOpacity(0.2),
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
                    'Train to Neuschwanstein',
                    style: AppTheme.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book your train journey to the castle',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Route Information
            _buildSectionCard(
              title: 'Popular Train Routes',
              children: [
                _buildRouteItem(
                  from: 'Munich Hauptbahnhof',
                  to: 'Füssen',
                  duration: '2h 15min',
                  price: '€23.90',
                  type: 'Regional Express',
                ),
                const Divider(height: 32),
                _buildRouteItem(
                  from: 'Füssen',
                  to: 'Neuschwanstein Castle',
                  duration: '15min',
                  price: '€2.50',
                  type: 'Bus 73/78',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Journey Information
            _buildSectionCard(
              title: 'Journey Information',
              children: [
                _buildInfoItem(
                  icon: Icons.access_time,
                  title: 'Journey Time',
                  description: 'Approximately 2.5 hours from Munich to the castle',
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  icon: Icons.confirmation_number,
                  title: 'Ticket Types',
                  description: 'Bayern-Ticket, Single tickets, or DB Day Pass available',
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  icon: Icons.schedule,
                  title: 'Operating Hours',
                  description: 'Trains run every 1-2 hours, 6:00 AM - 10:00 PM',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Book Ticket Button
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement train ticket booking
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Train ticket booking coming soon!'),
                      backgroundColor: AppColorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.train, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Book Train Ticket',
                      style: AppTheme.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRouteItem({
    required String from,
    required String to,
    required String duration,
    required String price,
    required String type,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    from,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppColorScheme.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: AppColorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          to,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppColorScheme.neutral700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppColorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  duration,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColorScheme.neutral600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColorScheme.primary100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            type,
            style: AppTheme.bodySmall.copyWith(
              color: AppColorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorScheme.primary100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.titleSmall.copyWith(
                  color: AppColorScheme.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColorScheme.neutral700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
