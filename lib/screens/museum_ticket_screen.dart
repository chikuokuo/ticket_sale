import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/attendee.dart';
import '../providers/ticket_order_provider.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';
import 'ticket_details_screen.dart';

class MuseumTicketScreen extends ConsumerStatefulWidget {
  const MuseumTicketScreen({super.key});

  @override
  ConsumerState<MuseumTicketScreen> createState() => _MuseumTicketScreenState();
}

class _MuseumTicketScreenState extends ConsumerState<MuseumTicketScreen> {
  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(ticketOrderProvider(TicketType.museum));
    final orderNotifier = ref.read(ticketOrderProvider(TicketType.museum).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Museum Tickets'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColorScheme.primary.withAlpha(13), // 0.05 opacity
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Uffizi Galleries',
                style: AppTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'World-Class Art Museum',
                style: AppTheme.bodyLarge.copyWith(color: AppColorScheme.neutral600),
              ),
              const SizedBox(height: 24),

              // Date selection
              _buildDateSelection(context, orderState, orderNotifier),
              const SizedBox(height: 24),

              // Ticket counters
              _buildTicketCounters(orderState, orderNotifier),
              const SizedBox(height: 24),

              // Important information
              _buildImportantInfo(),
              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: orderState.attendees.isNotEmpty
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TicketDetailsScreen(
                                ticketType: TicketType.museum,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    backgroundColor: AppColorScheme.primary,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods to build sections of the UI
  Widget _buildDateSelection(
    BuildContext context,
    TicketOrderState orderState,
    TicketOrderNotifier orderNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date', style: AppTheme.headlineSmall),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context, orderNotifier),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColorScheme.neutral300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderState.selectedDate != null
                      ? DateFormat('EEEE, MMMM dd, yyyy').format(orderState.selectedDate!)
                      : 'Select a date',
                  style: AppTheme.bodyLarge.copyWith(
                    color: orderState.selectedDate != null ? AppColorScheme.neutral900 : AppColorScheme.neutral500,
                  ),
                ),
                Icon(Icons.calendar_today, color: AppColorScheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TicketOrderNotifier orderNotifier,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      orderNotifier.selectDate(picked);
    }
  }

  Widget _buildTicketCounters(
    TicketOrderState orderState,
    TicketOrderNotifier orderNotifier,
  ) {
    final int adultCount = orderState.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = orderState.attendees.where((a) => a.type == AttendeeType.child).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Tickets', style: AppTheme.headlineSmall),
        const SizedBox(height: 16),
        _buildTicketCounter(
          title: 'Adults',
          subtitle: 'Ages 18+',
          price: '€20.00',
          count: adultCount,
          onIncrement: () => orderNotifier.addAttendee(AttendeeType.adult),
          onDecrement: () => orderNotifier.removeAttendee(AttendeeType.adult),
        ),
        const SizedBox(height: 16),
        _buildTicketCounter(
          title: 'Children',
          subtitle: 'Ages 0-17',
          price: 'Free',
          count: childCount,
          onIncrement: () => orderNotifier.addAttendee(AttendeeType.child),
          onDecrement: () => orderNotifier.removeAttendee(AttendeeType.child),
        ),
      ],
    );
  }

  Widget _buildTicketCounter({
    required String title,
    required String subtitle,
    required String price,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColorScheme.neutral300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '$subtitle • $price',
                style: AppTheme.bodyMedium.copyWith(color: AppColorScheme.neutral600),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: AppColorScheme.neutral400),
            onPressed: count > 0 ? onDecrement : null,
          ),
          Text(
            '$count',
            style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: AppColorScheme.primary),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }

  Widget _buildImportantInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorScheme.info50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColorScheme.info, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Information',
                  style: AppTheme.titleMedium.copyWith(color: AppColorScheme.info700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Opening hours: 9 AM - 6 PM. Last admission is 30 minutes before closing. Photography without flash is permitted.',
                  style: AppTheme.bodyMedium.copyWith(color: AppColorScheme.info700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
