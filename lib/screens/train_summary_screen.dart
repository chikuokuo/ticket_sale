import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../models/train_trip.dart';
import '../models/train_passenger.dart';
import '../providers/train_order_provider.dart';

class TrainSummaryScreen extends ConsumerWidget {
  const TrainSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainState = ref.watch(trainOrderProvider);
    final trainNotifier = ref.read(trainOrderProvider.notifier);

    if (trainState.selectedTrip == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Summary'),
        ),
        body: const Center(
          child: Text('No booking found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: const Text('Order Summary'),
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
            // Trip Information
            _buildTripInformationCard(trainState.selectedTrip!),

            const SizedBox(height: 24),

            // Passenger Details
            _buildPassengerDetailsCard(trainState),

            const SizedBox(height: 24),

            // Contact Information
            _buildContactInformationCard(trainState),

            const SizedBox(height: 24),

            // Price Breakdown
            _buildPriceBreakdownCard(trainState),

            const SizedBox(height: 24),

            // Total Amount
            _buildTotalAmountCard(trainState),

            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(context, trainState, trainNotifier),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInformationCard(TrainTrip trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 opacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Information',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColorScheme.primary,
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
              Text(
                DateFormat('MMM dd, yyyy').format(trip.departureTime),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColorScheme.neutral700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Departure',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColorScheme.neutral600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.formattedDepartureTime,
                      style: AppTheme.titleLarge.copyWith(
                        color: AppColorScheme.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.fromStation.name,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppColorScheme.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Icon(
                      Icons.train,
                      color: AppColorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trip.formattedDuration,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColorScheme.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Arrival',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColorScheme.neutral600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.formattedArrivalTime,
                      style: AppTheme.titleLarge.copyWith(
                        color: AppColorScheme.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.toStation.name,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppColorScheme.neutral700,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerDetailsCard(TrainOrderState trainState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 opacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passengers (${trainState.passengers.length})',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          ...trainState.passengers.asMap().entries.map((entry) {
            final index = entry.key;
            final passenger = entry.value;
            
            return Container(
              margin: EdgeInsets.only(bottom: index < trainState.passengers.length - 1 ? 16 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorScheme.neutral50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          passenger.fullName,
                          style: AppTheme.titleMedium.copyWith(
                            color: AppColorScheme.neutral900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColorScheme.primary100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          passenger.ticketClass.displayName,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColorScheme.primary700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Type: ${passenger.type.displayName}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppColorScheme.neutral600,
                              ),
                            ),
                            if (passenger.birthDate != null)
                              Text(
                                'DOB: ${passenger.formattedBirthDate}',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppColorScheme.neutral600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '€${trainState.selectedTrip!.getPriceForClass(passenger.ticketClass).toStringAsFixed(2)}',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppColorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContactInformationCard(TrainOrderState trainState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 opacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: AppColorScheme.neutral600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trainState.contactEmail,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColorScheme.neutral900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard(TrainOrderState trainState) {
    final trip = trainState.selectedTrip!;
    final classGroups = <TicketClass, List<String>>{};
    
    // Group passengers by ticket class
    for (final passenger in trainState.passengers) {
      if (!classGroups.containsKey(passenger.ticketClass)) {
        classGroups[passenger.ticketClass] = [];
      }
      classGroups[passenger.ticketClass]!.add(passenger.type.displayName);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 opacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          ...classGroups.entries.map((entry) {
            final ticketClass = entry.key;
            final passengers = entry.value;
            final price = trip.getPriceForClass(ticketClass);
            final total = price * passengers.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ticketClass.displayName} × ${passengers.length}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppColorScheme.neutral900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          passengers.join(', '),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColorScheme.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '€${total.toStringAsFixed(2)}',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppColorScheme.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTotalAmountCard(TrainOrderState trainState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColorScheme.primary700, AppColorScheme.primary],
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount',
                  style: AppTheme.headlineSmall.copyWith(
                    color: Colors.white.withAlpha(230), // 0.9 opacity
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '€${trainState.totalAmount.toStringAsFixed(2)}',
                  style: AppTheme.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.train,
            color: Colors.white,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    TrainOrderState trainState,
    TrainOrderNotifier trainNotifier,
  ) {
    return Column(
      children: [
        // Confirm and Pay Button
        Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: trainState.isLoading
                ? null
                : () => _processPayment(context, trainNotifier),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AppColorScheme.neutral300,
            ),
            child: trainState.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Processing...',
                        style: AppTheme.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Confirm Order & Pay',
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

        // Back to Booking Button
        TextButton(
          onPressed: trainState.isLoading
              ? null
              : () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Text(
            'Back to Booking',
            style: AppTheme.titleMedium.copyWith(
              color: AppColorScheme.neutral600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    TrainOrderNotifier trainNotifier,
  ) async {
    try {
      await trainNotifier.processPayment(context);
      
      if (!context.mounted) return;
      
      // Show success message and navigate back to main screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking confirmed! Tickets sent to your email.'),
          backgroundColor: AppColorScheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Navigate back to the main screen
      Navigator.of(context).popUntil((route) => route.isFirst);
      
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: AppColorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
