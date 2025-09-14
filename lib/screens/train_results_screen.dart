import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../models/train_trip.dart';
import '../providers/train_order_provider.dart';
import 'train_details_screen.dart';

class TrainResultsScreen extends ConsumerWidget {
  const TrainResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainState = ref.watch(trainOrderProvider);
    final trainNotifier = ref.read(trainOrderProvider.notifier);

    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: const Text('Train Results'),
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
      body: Column(
        children: [
          // Search Summary Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${trainState.searchCriteria.fromStation?.name}',
                            style: AppTheme.titleMedium.copyWith(
                              color: AppColorScheme.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trainState.searchCriteria.departureDate != null
                                ? DateFormat('MMM dd, yyyy').format(trainState.searchCriteria.departureDate!)
                                : '',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppColorScheme.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColorScheme.primary,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${trainState.searchCriteria.toStation?.name}',
                            style: AppTheme.titleMedium.copyWith(
                              color: AppColorScheme.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${trainState.searchCriteria.totalPassengers} passenger${trainState.searchCriteria.totalPassengers > 1 ? 's' : ''}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppColorScheme.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: trainState.searchResults.isEmpty
                ? _buildEmptyResults()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: trainState.searchResults.length,
                    itemBuilder: (context, index) {
                      final trip = trainState.searchResults[index];
                      return _buildTripCard(
                        context,
                        ref,
                        trip,
                        trainNotifier,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.train_outlined,
            size: 64,
            color: AppColorScheme.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            'No trains found',
            style: AppTheme.headlineMedium.copyWith(
              color: AppColorScheme.neutral700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: AppTheme.bodyLarge.copyWith(
              color: AppColorScheme.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    WidgetRef ref,
    TrainTrip trip,
    TrainOrderNotifier trainNotifier,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          // Trip Header - Times and Duration
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Train info and times
                Row(
                  children: [
                    // Train type and number
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getTrainTypeColor(trip.trainType),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trip.fullTrainName,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Available seats
                    if (trip.availableSeats < 50)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: trip.availableSeats < 20
                              ? AppColorScheme.error100
                              : AppColorScheme.warning100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${trip.availableSeats} seats left',
                          style: AppTheme.bodySmall.copyWith(
                            color: trip.availableSeats < 20
                                ? AppColorScheme.error700
                                : AppColorScheme.warning700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Times and route
                Row(
                  children: [
                    // Departure
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.formattedDepartureTime,
                            style: AppTheme.headlineMedium.copyWith(
                              color: AppColorScheme.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trip.fromStation.name,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppColorScheme.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Journey visualization
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: AppColorScheme.primary200,
                                ),
                              ),
                              Icon(
                                Icons.train,
                                color: AppColorScheme.primary,
                                size: 16,
                              ),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: AppColorScheme.primary200,
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trip.formattedDuration,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppColorScheme.neutral700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrival
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            trip.formattedArrivalTime,
                            style: AppTheme.headlineMedium.copyWith(
                              color: AppColorScheme.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trip.toStation.name,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppColorScheme.neutral600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Amenities and pricing
                Row(
                  children: [
                    // Amenities
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          if (trip.hasWifi)
                            _buildAmenityChip(Icons.wifi, 'WiFi'),
                          if (trip.hasRestaurant)
                            _buildAmenityChip(Icons.restaurant, 'Restaurant'),
                        ],
                      ),
                    ),

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'from',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColorScheme.neutral600,
                          ),
                        ),
                        Text(
                          '€${trip.lowestPrice.toStringAsFixed(2)}',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppColorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // View Details Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColorScheme.neutral200,
                  width: 1,
                ),
              ),
            ),
            child: TextButton(
              onPressed: () => _selectTripAndProceed(
                context,
                ref,
                trip,
                trainNotifier,
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Details',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppColorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColorScheme.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColorScheme.neutral600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppColorScheme.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrainTypeColor(TrainType trainType) {
    switch (trainType) {
      case TrainType.ice:
        return AppColorScheme.primary;
      case TrainType.ic:
        return AppColorScheme.tertiary;
      case TrainType.ec:
        return AppColorScheme.secondary700;
      case TrainType.re:
        return AppColorScheme.success;
      case TrainType.rb:
        return AppColorScheme.neutral600;
    }
  }

  void _selectTripAndProceed(
    BuildContext context,
    WidgetRef ref,
    TrainTrip trip,
    TrainOrderNotifier trainNotifier,
  ) {
    trainNotifier.selectTrip(trip);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TrainDetailsScreen(),
      ),
    );
  }
}
