import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/attendee.dart';
import '../models/time_slot.dart';
import '../providers/ticket_order_provider.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';
import 'ticket_details_screen.dart';

class SelectTicketScreen extends ConsumerWidget {
  const SelectTicketScreen({super.key});

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(ticketOrderProvider.notifier);
    final selectedDate = ref.read(ticketOrderProvider).selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppColorScheme.lightColorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      notifier.selectDate(picked);
    }
  }

  void _navigateToNextPage(BuildContext context, WidgetRef ref) {
    final orderState = ref.read(ticketOrderProvider);
    
    // Validate required fields
    if (orderState.selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a date'),
          backgroundColor: AppColorScheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (orderState.selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select time slot (AM/PM)'),
          backgroundColor: AppColorScheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (orderState.attendees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one ticket'),
          backgroundColor: AppColorScheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigate to next page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TicketDetailsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(ticketOrderProvider);
    final orderNotifier = ref.read(ticketOrderProvider.notifier);

    final int adultCount = orderState.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = orderState.attendees.where((a) => a.type == AttendeeType.child).length;
    final double adultPrice = 23.5;
    final double childPrice = 2.5;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header image area
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppTheme.castleGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Castle icon
                      Positioned(
                        right: 20,
                        top: 20,
                        child: Icon(
                          Icons.castle,
                          color: Colors.white.withOpacity(0.3),
                          size: 100,
                        ),
                      ),
                      // Title text
                      const Positioned(
                        left: 24,
                        bottom: 32,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hohenschwangau, Bavaria',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Book Your Visit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Official guided tours available',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main content area
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date selection area
                      _buildSectionCard(
                        title: 'Select Visit Date',
                        child: InkWell(
                          onTap: () => _selectDate(context, ref),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: orderState.selectedDate != null 
                                  ? AppColorScheme.primary 
                                  : AppColorScheme.neutral300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: orderState.selectedDate != null 
                                ? AppColorScheme.primary50 
                                : AppColorScheme.neutral50,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: orderState.selectedDate != null 
                                    ? AppColorScheme.primary 
                                    : AppColorScheme.neutral500,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    orderState.selectedDate == null
                                        ? 'Select Date'
                                        : DateFormat('EEEE, MMMM dd, yyyy').format(orderState.selectedDate!),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: orderState.selectedDate != null 
                                        ? AppColorScheme.primary 
                                        : AppColorScheme.neutral600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColorScheme.neutral500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Time slot selection area
                      _buildSectionCard(
                        title: 'Select Time Slot',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimeSlotCard(
                                    title: 'Morning',
                                    subtitle: '9:00 AM - 12:00 PM',
                                    icon: Icons.wb_sunny,
                                    isSelected: orderState.selectedTimeSlot == TimeSlot.am,
                                    onTap: () => orderNotifier.selectTimeSlot(TimeSlot.am),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTimeSlotCard(
                                    title: 'Afternoon',
                                    subtitle: '1:00 PM - 5:00 PM',
                                    icon: Icons.wb_sunny_outlined,
                                    isSelected: orderState.selectedTimeSlot == TimeSlot.pm,
                                    onTap: () => orderNotifier.selectTimeSlot(TimeSlot.pm),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Ticket selection area
                      _buildSectionCard(
                        title: 'Tickets',
                        subtitle: 'Select number of visitors',
                        child: Column(
                          children: [
                            _buildTicketCounter(
                              title: 'Adult (18+)',
                              price: '€${adultPrice.toStringAsFixed(2)}',
                              count: adultCount,
                              onDecrement: adultCount > 0 
                                ? () {
                                    // Find and remove the first adult ticket
                                    final adultIndex = orderState.attendees.indexWhere((a) => a.type == AttendeeType.adult);
                                    if (adultIndex != -1) {
                                      orderNotifier.removeAttendee(adultIndex);
                                    }
                                  }
                                : null,
                              onIncrement: () {
                                orderNotifier.addAttendee(AttendeeType.adult);
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTicketCounter(
                              title: 'Child (0-17)',
                              price: '€${childPrice.toStringAsFixed(2)}',
                              count: childCount,
                              onDecrement: childCount > 0
                                ? () {
                                    // Find and remove the first child ticket
                                    final childIndex = orderState.attendees.indexWhere((a) => a.type == AttendeeType.child);
                                    if (childIndex != -1) {
                                      orderNotifier.removeAttendee(childIndex);
                                    }
                                  }
                                : null,
                              onIncrement: () {
                                orderNotifier.addAttendee(AttendeeType.child);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Business hours information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColorScheme.info50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColorScheme.info200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppColorScheme.info,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tours: Tue - Sun, 9:00 AM - 5:00 PM',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColorScheme.info700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // CTA button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _navigateToNextPage(context, ref),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Find Available Times',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Feature highlights
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureItem(
                            icon: Icons.check_circle,
                            text: 'Instant\nconfirmation',
                          ),
                          _buildFeatureItem(
                            icon: Icons.phone_android,
                            text: 'Mobile\ntickets',
                          ),
                          _buildFeatureItem(
                            icon: Icons.cancel,
                            text: 'Cancel up\nto 24h',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColorScheme.neutral900.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  isSelected: true,
                ),
                _buildBottomNavItem(
                  icon: Icons.confirmation_number,
                  label: 'My Tickets',
                  isSelected: false,
                ),
                _buildBottomNavItem(
                  icon: Icons.castle,
                  label: 'Castle Info',
                  isSelected: false,
                ),
                _buildBottomNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isSelected: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.headlineSmall,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTheme.bodyMedium.copyWith(
              color: AppColorScheme.neutral600,
            ),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildTimeSlotCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColorScheme.primary50 : AppColorScheme.neutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.titleMedium.copyWith(
                color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(
                color: isSelected ? AppColorScheme.primary700 : AppColorScheme.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCounter({
    required String title,
    required String price,
    required int count,
    VoidCallback? onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.titleMedium,
              ),
              Text(
                price,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColorScheme.neutral600,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_circle_outline),
              color: onDecrement != null 
                ? AppColorScheme.primary 
                : AppColorScheme.neutral400,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColorScheme.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add_circle_outline),
              color: AppColorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColorScheme.success,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: AppTheme.labelSmall.copyWith(
            color: AppColorScheme.neutral700,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral500,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral500,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
