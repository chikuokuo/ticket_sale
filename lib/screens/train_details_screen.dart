import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../models/train_trip.dart';
import '../models/train_passenger.dart';
import '../providers/train_order_provider.dart';
import 'train_summary_screen.dart';

class TrainDetailsScreen extends ConsumerStatefulWidget {
  const TrainDetailsScreen({super.key});

  @override
  ConsumerState<TrainDetailsScreen> createState() => _TrainDetailsScreenState();
}

class _TrainDetailsScreenState extends ConsumerState<TrainDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize contact email from state if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trainState = ref.read(trainOrderProvider);
      _contactEmailController.text = trainState.contactEmail;
    });
  }

  @override
  void dispose() {
    _contactEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainState = ref.watch(trainOrderProvider);
    final trainNotifier = ref.read(trainOrderProvider.notifier);

    if (trainState.selectedTrip == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Train Details'),
        ),
        body: const Center(
          child: Text('No trip selected'),
        ),
      );
    }

    final trip = trainState.selectedTrip!;

    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: const Text('Booking Details'),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Summary Card
              _buildTripSummaryCard(trip),

              const SizedBox(height: 24),

              // Ticket Class Selection
              _buildTicketClassSelection(trainState, trainNotifier),

              const SizedBox(height: 24),

              // Passenger Details
              _buildPassengerDetails(trainState, trainNotifier),

              const SizedBox(height: 24),

              // Contact Information
              _buildContactInformation(trainNotifier),

              const SizedBox(height: 32),

              // Continue Button
              _buildContinueButton(trainState),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard(TrainTrip trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              const Spacer(),
              Text(
                trip.formattedDuration,
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
                        color: AppColorScheme.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: AppColorScheme.primary,
                size: 24,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                        color: AppColorScheme.neutral600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (trip.hasWifi || trip.hasRestaurant) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                if (trip.hasWifi)
                  _buildAmenityChip(Icons.wifi, 'WiFi'),
                if (trip.hasRestaurant)
                  _buildAmenityChip(Icons.restaurant, 'Restaurant'),
              ],
            ),
          ],
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

  Widget _buildTicketClassSelection(
    TrainOrderState trainState,
    TrainOrderNotifier trainNotifier,
  ) {
    final trip = trainState.selectedTrip!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            'Select Ticket Class',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Show class options for each passenger type
          ...trainState.passengers.map((passenger) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPassengerClassSelector(
                passenger,
                trip,
                trainNotifier,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPassengerClassSelector(
    TrainPassenger passenger,
    TrainTrip trip,
    TrainOrderNotifier trainNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${passenger.type.displayName} ${passenger.id.split('_')[1]}',
          style: AppTheme.titleMedium.copyWith(
            color: AppColorScheme.neutral700,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),

        Row(
          children: trip.prices.entries.map((entry) {
            final ticketClass = entry.key;
            final price = entry.value;
            final isSelected = passenger.ticketClass == ticketClass;

            return Expanded(
              child: GestureDetector(
                onTap: () => trainNotifier.updatePassengerTicketClass(
                  passenger.id,
                  ticketClass,
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColorScheme.primary100 : AppColorScheme.neutral50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ticketClass.displayName,
                            style: AppTheme.titleSmall.copyWith(
                              color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '€${price.toStringAsFixed(2)}',
                        style: AppTheme.titleMedium.copyWith(
                          color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPassengerDetails(
    TrainOrderState trainState,
    TrainOrderNotifier trainNotifier,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            'Passenger Information',
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
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorScheme.neutral50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColorScheme.neutral200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${passenger.type.displayName} ${index + 1} - ${passenger.ticketClass.displayName}',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppColorScheme.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Given Name
                  TextFormField(
                    controller: passenger.givenNameController,
                    decoration: InputDecoration(
                      labelText: 'Given Name',
                      labelStyle: AppTheme.bodyMedium.copyWith(
                        color: AppColorScheme.neutral600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColorScheme.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColorScheme.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Given name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Family Name
                  TextFormField(
                    controller: passenger.familyNameController,
                    decoration: InputDecoration(
                      labelText: 'Family Name',
                      labelStyle: AppTheme.bodyMedium.copyWith(
                        color: AppColorScheme.neutral600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColorScheme.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColorScheme.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Family name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Birth Date
                  InkWell(
                    onTap: () => _selectBirthDate(context, passenger, trainNotifier),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColorScheme.neutral300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            passenger.birthDate != null
                                ? passenger.formattedBirthDate
                                : 'Select birth date',
                            style: AppTheme.bodyMedium.copyWith(
                              color: passenger.birthDate != null
                                  ? AppColorScheme.neutral900
                                  : AppColorScheme.neutral500,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: AppColorScheme.neutral500,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Passport Number
                  TextFormField(
                    controller: passenger.passportNumberController,
                    decoration: InputDecoration(
                      labelText: 'Passport Number',
                      labelStyle: AppTheme.bodyMedium.copyWith(
                        color: AppColorScheme.neutral600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColorScheme.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColorScheme.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Passport number is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContactInformation(TrainOrderNotifier trainNotifier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            'Contact Information',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _contactEmailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: trainNotifier.setContactEmail,
            decoration: InputDecoration(
              labelText: 'Email Address',
              labelStyle: AppTheme.bodyMedium.copyWith(
                color: AppColorScheme.neutral600,
              ),
              hintText: 'your.email@example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColorScheme.neutral300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColorScheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(TrainOrderState trainState) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: trainState.canProceedToSummary
            ? () => _proceedToSummary()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppColorScheme.neutral300,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue to Summary',
              style: AppTheme.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(
    BuildContext context,
    TrainPassenger passenger,
    TrainOrderNotifier trainNotifier,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: passenger.birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      trainNotifier.updatePassengerBirthDate(passenger.id, picked);
    }
  }

  void _proceedToSummary() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TrainSummaryScreen(),
        ),
      );
    }
  }
}
