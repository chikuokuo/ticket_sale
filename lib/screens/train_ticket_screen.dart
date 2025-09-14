import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../models/train_station.dart';
import '../providers/train_order_provider.dart';
import 'train_results_screen.dart';

class TrainTicketScreen extends ConsumerWidget {
  const TrainTicketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainState = ref.watch(trainOrderProvider);
    final trainNotifier = ref.read(trainOrderProvider.notifier);

    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: const Text('Train Ticket'),
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
                    'Book Train Tickets',
                    style: AppTheme.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find and book train tickets across Germany',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Search Form
            _buildSearchForm(context, ref, trainState, trainNotifier),

            const SizedBox(height: 32),

            // Popular Routes Info (Optional)
            if (trainState.searchResults.isEmpty) ...[
              _buildPopularRoutesSection(),
              const SizedBox(height: 24),
            ],

            // Error Message
            if (trainState.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColorScheme.error100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColorScheme.error200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        trainState.errorMessage!,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColorScheme.error700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchForm(
    BuildContext context,
    WidgetRef ref,
    TrainOrderState trainState,
    TrainOrderNotifier trainNotifier,
  ) {
    return Container(
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
            'Search Trains',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // From/To Station Selection
          Column(
            children: [
              // From Station
              _buildStationDropdown(
                label: 'From',
                value: trainState.searchCriteria.fromStation,
                onChanged: trainNotifier.setFromStation,
                excludeStation: trainState.searchCriteria.toStation,
              ),
              
              // Swap Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const Spacer(),
                    InkWell(
                      onTap: trainNotifier.swapStations,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColorScheme.primary100,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColorScheme.primary200,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.swap_vert,
                          color: AppColorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              
              // To Station
              _buildStationDropdown(
                label: 'To',
                value: trainState.searchCriteria.toStation,
                onChanged: trainNotifier.setToStation,
                excludeStation: trainState.searchCriteria.fromStation,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date Selection
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  label: 'Departure Date',
                  date: trainState.searchCriteria.departureDate,
                  onDateSelected: trainNotifier.setDepartureDate,
                  context: context,
                ),
              ),
              // TODO: Add return date for round trips
            ],
          ),

          const SizedBox(height: 16),

          // Passenger Count
          Row(
            children: [
              Expanded(
                child: _buildPassengerCounter(
                  label: 'Adults',
                  count: trainState.searchCriteria.adultCount,
                  onChanged: (count) => trainNotifier.setPassengerCount(adults: count),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPassengerCounter(
                  label: 'Children (6-14)',
                  count: trainState.searchCriteria.childCount,
                  onChanged: (count) => trainNotifier.setPassengerCount(children: count),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Search Button
          Container(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: trainState.canProceedToSearch && !trainState.isLoading
                  ? () => _handleSearch(context, ref, trainNotifier)
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
                          'Searching...',
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
                        Icon(Icons.search, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Search Tickets',
                          style: AppTheme.titleMedium.copyWith(
                            color: Colors.white,
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

  Widget _buildStationDropdown({
    required String label,
    required TrainStation? value,
    required Function(TrainStation?) onChanged,
    TrainStation? excludeStation,
  }) {
    final availableStations = TrainStations.stations
        .where((station) => station != excludeStation)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: AppColorScheme.neutral700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TrainStation>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColorScheme.neutral300),
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
          items: availableStations.map((station) {
            return DropdownMenuItem<TrainStation>(
              value: station,
              child: Text(
                station.name,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColorScheme.neutral900,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          hint: Text(
            'Select station',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColorScheme.neutral500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onDateSelected,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: AppColorScheme.neutral700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, date, onDateSelected),
          borderRadius: BorderRadius.circular(8),
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
                  date != null
                      ? DateFormat('MMM dd, yyyy').format(date)
                      : 'Select date',
                  style: AppTheme.bodyMedium.copyWith(
                    color: date != null
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
      ],
    );
  }

  Widget _buildPassengerCounter({
    required String label,
    required int count,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: AppColorScheme.neutral700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColorScheme.neutral300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: count > 0 ? () => onChanged(count - 1) : null,
                icon: Icon(
                  Icons.remove,
                  color: count > 0 ? AppColorScheme.primary : AppColorScheme.neutral400,
                ),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              Text(
                count.toString(),
                style: AppTheme.titleMedium.copyWith(
                  color: AppColorScheme.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: count < 9 ? () => onChanged(count + 1) : null,
                icon: Icon(
                  Icons.add,
                  color: count < 9 ? AppColorScheme.primary : AppColorScheme.neutral400,
                ),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularRoutesSection() {
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
            'Popular Routes',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildPopularRoute('Munich → Füssen', '2h 15min', 'from €16.90'),
          _buildPopularRoute('Berlin → Munich', '4h 12min', 'from €79.00'),
          _buildPopularRoute('Hamburg → Munich', '6h 13min', 'from €119.00'),
          _buildPopularRoute('Frankfurt → Munich', '3h 30min', 'from €69.00'),
        ],
      ),
    );
  }

  Widget _buildPopularRoute(String route, String duration, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColorScheme.neutral900,
                  fontWeight: FontWeight.w500,
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
          Text(
            price,
            style: AppTheme.bodyMedium.copyWith(
              color: AppColorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime?) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _handleSearch(
    BuildContext context,
    WidgetRef ref,
    TrainOrderNotifier trainNotifier,
  ) async {
    await trainNotifier.searchTrains();
    
    final trainState = ref.read(trainOrderProvider);
    if (trainState.searchResults.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TrainResultsScreen(),
        ),
      );
    }
  }
}