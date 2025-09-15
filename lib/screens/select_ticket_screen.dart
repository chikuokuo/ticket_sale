import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/attendee.dart';
import '../models/time_slot.dart';
import '../providers/ticket_order_provider.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'ticket_details_screen.dart';

class SelectTicketScreen extends ConsumerStatefulWidget {
  const SelectTicketScreen({super.key});

  @override
  ConsumerState<SelectTicketScreen> createState() => _SelectTicketScreenState();
}

class _SelectTicketScreenState extends ConsumerState<SelectTicketScreen> {
  bool _submitted = false;

  void _handleContinue() {
    setState(() {
      _submitted = true;
    });

    final l10n = AppLocalizations.of(context)!;
    final orderState = ref.read(ticketOrderProvider(TicketType.neuschwanstein));

    if (orderState.selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectDate),
          backgroundColor: AppColorScheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (orderState.selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectTimeSlot),
          backgroundColor: AppColorScheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TicketDetailsScreen(
          ticketType: TicketType.neuschwanstein,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orderState = ref.watch(ticketOrderProvider(TicketType.neuschwanstein));
    final orderNotifier = ref.read(ticketOrderProvider(TicketType.neuschwanstein).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookTickets),
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
                l10n.neuschwansteinCastle,
                style: AppTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.selectVisitDetails,
                style: AppTheme.bodyLarge.copyWith(color: AppColorScheme.neutral600),
              ),
              const SizedBox(height: 24),

              // Date selection
              _buildDateSelection(context, l10n, orderState, orderNotifier),
              const SizedBox(height: 24),

              // Time slot selection
              _buildTimeSlotSelection(orderState, orderNotifier),
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
                  onPressed: orderState.attendees.isNotEmpty ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    backgroundColor: orderState.attendees.isNotEmpty
                        ? AppColorScheme.primary
                        : AppColorScheme.neutral300,
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
    AppLocalizations l10n,
    TicketOrderState orderState,
    TicketOrderNotifier orderNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.selectDate, style: AppTheme.headlineSmall),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context, orderNotifier),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                  color: _submitted && orderState.selectedDate == null
                      ? AppColorScheme.error
                      : AppColorScheme.neutral300),
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

  Widget _buildTimeSlotSelection(
    TicketOrderState orderState,
    TicketOrderNotifier orderNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Time Slot', style: AppTheme.headlineSmall),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTimeSlotCard(
                'Morning',
                '9:00 AM - 12:00 PM',
                Icons.wb_sunny,
                orderState,
                orderState.selectedTimeSlot == TimeSlot.am,
                () => orderNotifier.selectTimeSlot(TimeSlot.am),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeSlotCard(
                'Afternoon',
                '1:00 PM - 5:00 PM',
                Icons.brightness_3,
                orderState,
                orderState.selectedTimeSlot == TimeSlot.pm,
                () => orderNotifier.selectTimeSlot(TimeSlot.pm),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTimeSlotCard(
    String title,
    String subtitle,
    IconData icon,
    TicketOrderState orderState,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final bool showError = _submitted && orderState.selectedTimeSlot == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColorScheme.primary.withAlpha(26) : Colors.white,
          border: Border.all(
            color: isSelected
                ? AppColorScheme.primary
                : (showError ? AppColorScheme.error : AppColorScheme.neutral300),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColorScheme.primary, size: 32),
            const SizedBox(height: 12),
            Text(title, style: AppTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(color: AppColorScheme.neutral600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
          'Adults',
          'Ages 18+',
          '€21.00',
          adultCount,
          () => orderNotifier.addAttendee(AttendeeType.adult),
          () => orderNotifier.removeAttendee(AttendeeType.adult),
        ),
        const SizedBox(height: 16),
        _buildTicketCounter(
          'Children',
          'Ages 0-17',
          'Free',
          childCount,
          () => orderNotifier.addAttendee(AttendeeType.child),
          () => orderNotifier.removeAttendee(AttendeeType.child),
        ),
      ],
    );
  }

  Widget _buildTicketCounter(
    String title,
    String subtitle,
    String price,
    int count,
    VoidCallback onIncrement,
    VoidCallback onDecrement,
  ) {
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
        color: AppColorScheme.warning50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColorScheme.warning, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Information',
                  style: AppTheme.titleMedium.copyWith(color: AppColorScheme.warning700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please arrive 30 minutes before your selected time slot. Tickets are non-refundable. Valid ID is required for entry.',
                  style: AppTheme.bodyMedium.copyWith(color: AppColorScheme.warning700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}