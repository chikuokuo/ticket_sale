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

  final List<String> importantInfo = const [
    'Tickets are excluded from exchange and refund.',
    'Please inform yourself about current visitor information and accessibility before purchasing your ticket and before your arrival.',
    'Even babies and (small) children require their own ticket for the royal castles.',
    'You must present proof of eligibility for free or reduced tickets at the castle entrance. Please have the appropriate documents and your ticket ready at the entrance.',
    'Audio devices are only available in "Audio Guide" tours due to the limited number of devices.',
    'Currently, there are only limited capacities for tours in the royal castles. An early sell-out must be expected.',
    'If you wish to visit both castles (Hohenschwangau and Neuschwanstein) on the same day, we generally recommend allowing at least 2.5 hours between the admission times of the tours so that you have enough time to get from one castle to the other.',
    'The Museum of the Bavarian Kings can be visited at any time on the booked day between 9:00 and 16:30 (closing at 17:00).',
  ];


  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(ticketOrderProvider(TicketType.neuschwanstein).notifier);
    final selectedDate = ref.read(ticketOrderProvider(TicketType.neuschwanstein)).selectedDate;
    final earliestDate = DateTime.now().add(const Duration(days: 2));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? earliestDate,
      firstDate: earliestDate, // Only allow dates 2 days from now
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
    final orderState = ref.read(ticketOrderProvider(TicketType.neuschwanstein));
    
    // Validate required fields
    if (orderState.selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a visit date (minimum 2 days in advance)'),
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
        builder: (context) => const TicketDetailsScreen(ticketType: TicketType.neuschwanstein),
      ),
    );
  }

  // Helper method to get background image with fallback
  ImageProvider _getBackgroundImage() {
    try {
      return const AssetImage('assets/images/Bg-NeuschwansteinCastle.jpg');
    } catch (e) {
      // Fallback to network image if local asset is not available
      return const NetworkImage(
        'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80'
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(ticketOrderProvider(TicketType.neuschwanstein));
    final orderNotifier = ref.read(ticketOrderProvider(TicketType.neuschwanstein).notifier);

    final int adultCount = orderState.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = orderState.attendees.where((a) => a.type == AttendeeType.child).length;
    final double adultPrice = 21.0;
    final double childPrice = 0.0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with background image
            Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _getBackgroundImage(),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Handle image loading error silently - fallback will be used
                  },
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Main title
                        Text(
                          'Neuschwanstein Castle',
                          style: AppTheme.displayLarge.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Subtitle
                        Text(
                          'Hohenschwangau, Bavaria',
                          style: AppTheme.titleLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Main content area with overlapping effect
            Transform.translate(
              offset: const Offset(0, -32), // Move cards up to overlap background
              child: Column(
                children: [
                  // Ticket Selection Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section title
                            Text(
                              'Book Your Visit',
                              style: AppTheme.headlineSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColorScheme.primary,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Official guided tours available',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppColorScheme.neutral600,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Select Visit Date
                            Text(
                              'Select Visit Date',
                              style: AppTheme.headlineSmall.copyWith(
                                color: AppColorScheme.neutral900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 4),
                            
                            Text(
                              'Bookings must be made at least 2 days in advance',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppColorScheme.neutral600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            InkWell(
                              onTap: () => _selectDate(context, ref),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
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
                                            ? DateFormat('MMMM dd, yyyy').format(DateTime.now().add(const Duration(days: 2)))
                                            : DateFormat('MMMM dd, yyyy').format(orderState.selectedDate!),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: orderState.selectedDate != null 
                                            ? AppColorScheme.primary 
                                            : AppColorScheme.neutral900,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.expand_more,
                                      color: AppColorScheme.neutral500,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Select Time Slot
                            Text(
                              'Select Time Slot',
                              style: AppTheme.headlineSmall.copyWith(
                                color: AppColorScheme.neutral900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
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
                            
                            const SizedBox(height: 24),
                            
                            // Tickets
                            Text(
                              'Tickets',
                              style: AppTheme.headlineSmall.copyWith(
                                color: AppColorScheme.neutral900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Select number of visitors',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppColorScheme.neutral600,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Adult tickets
                            _buildTicketCounter(
                              title: 'Adult (18+)',
                              price: '€${adultPrice.toStringAsFixed(2)}',
                              count: adultCount,
                              onDecrement: adultCount > 0 
                                ? () {
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
                            
                            // Child tickets
                            _buildTicketCounter(
                              title: 'Child (0-17)',
                              price: childPrice == 0.0 ? 'Free' : '€${childPrice.toStringAsFixed(2)}',
                              count: childCount,
                              onDecrement: childCount > 0
                                ? () {
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
                            
                            const SizedBox(height: 24),
                            
                            // Tours schedule info
                            Container(
                              width: double.infinity,
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
                            
                            const SizedBox(height: 24),
                            
                            // Continue to booking button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: orderState.attendees.isNotEmpty 
                                  ? () => _navigateToNextPage(context, ref)
                                  : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: orderState.attendees.isNotEmpty 
                                    ? AppColorScheme.primary
                                    : AppColorScheme.neutral300,
                                  foregroundColor: orderState.attendees.isNotEmpty
                                    ? Colors.white
                                    : AppColorScheme.neutral500,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: orderState.attendees.isNotEmpty ? 2 : 0,
                                ),
                                child: Text(
                                  'Continue Booking',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: orderState.attendees.isNotEmpty
                                      ? Colors.white
                                      : AppColorScheme.neutral500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Features row
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Important Information Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColorScheme.info,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Important Information',
                                  style: AppTheme.headlineSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColorScheme.info700,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Important information list
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: importantInfo.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(top: 8, right: 12),
                                      decoration: BoxDecoration(
                                        color: AppColorScheme.info,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        importantInfo[index],
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppColorScheme.neutral700,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColorScheme.primary50 : AppColorScheme.neutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral600,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.titleSmall.copyWith(
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
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
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
            // Decrement button
            InkWell(
              onTap: onDecrement,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: onDecrement != null 
                    ? AppColorScheme.neutral200
                    : AppColorScheme.neutral100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove,
                  color: onDecrement != null 
                    ? AppColorScheme.neutral700
                    : AppColorScheme.neutral400,
                  size: 18,
                ),
              ),
            ),
            
            // Count display
            Container(
              width: 50,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Text(
                count.toString(),
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorScheme.neutral900,
                ),
              ),
            ),
            
            // Increment button
            InkWell(
              onTap: onIncrement,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
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
          size: 16,
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

}