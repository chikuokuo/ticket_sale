import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/attendee.dart';
import '../models/time_slot.dart';
import '../providers/ticket_order_provider.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';
import 'ticket_details_screen.dart';

class MuseumTicketScreen extends ConsumerWidget {
  const MuseumTicketScreen({super.key});

  final List<String> importantInfo = const [
    'Tickets are excluded from exchange and refund.',
    'Please inform yourself about current visitor information and accessibility before purchasing your ticket and before your arrival.',
    'Even babies and (small) children require their own ticket for the Uffizi Galleries.',
    'You must present proof of eligibility for free or reduced tickets at the museum entrance. Please have the appropriate documents and your ticket ready at the entrance.',
    'Audio guides are only available in limited quantities due to the limited number of devices.',
    'Currently, there are only limited capacities for tours in the Uffizi Galleries. An early sell-out must be expected.',
    'If you wish to visit multiple museums on the same day, we generally recommend allowing at least 3 hours between the admission times.',
    'The Uffizi Galleries can be visited at any time on the booked day between 8:15 and 18:30 (closing at 19:00).',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(ticketOrderProvider);
    
    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Background and Title Section
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _getBackgroundImage(),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Text(
                          'Uffizi Galleries',
                          style: AppTheme.headlineLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Florence, Italy',
                          style: AppTheme.titleMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Content with Overlap
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Ticket Selection Card
                    _buildTicketSelectionCard(context, ref, orderState),
                    
                    const SizedBox(height: 20),
                    
                    // Important Information Card
                    _buildImportantInfoCard(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getBackgroundImage() {
    // Try to load the background image with fallback
    try {
      return const AssetImage('assets/images/Bg-UffiziGalleries.jpg');
    } catch (e) {
      // Fallback to network image if asset is not found
      return const NetworkImage(
        'https://images.unsplash.com/photo-1541362939442-1cf2d9e45d96?w=800&h=600&fit=crop'
      );
    }
  }

  Widget _buildTicketSelectionCard(BuildContext context, WidgetRef ref, TicketOrderState orderState) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Your Museum Visit',
              style: AppTheme.titleLarge.copyWith(
                color: AppColorScheme.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Select Visit Date
            _buildDateSelection(context, ref, orderState),
            
            const SizedBox(height: 20),
            
            // Select Time Slot
            _buildTimeSlotSelection(ref, orderState),
            
            const SizedBox(height: 20),
            
            // Tickets Selection
            _buildTicketCounters(ref, orderState),
            
            const SizedBox(height: 24),
            
            // Continue Booking Button
            _buildContinueButton(context, ref, orderState),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection(BuildContext context, WidgetRef ref, TicketOrderState orderState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Visit Date',
          style: AppTheme.titleMedium.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectDate(context, ref),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColorScheme.neutral300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  orderState.selectedDate != null
                      ? DateFormat('EEEE, MMM dd, yyyy').format(orderState.selectedDate!)
                      : 'Available from ${DateFormat('MMM dd').format(DateTime.now().add(const Duration(days: 2)))}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: orderState.selectedDate != null
                        ? AppColorScheme.neutral900
                        : AppColorScheme.neutral600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: AppColorScheme.neutral400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelection(WidgetRef ref, TicketOrderState orderState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time Slot',
          style: AppTheme.titleMedium.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTimeSlotCard(ref, TimeSlot.am, orderState)),
            const SizedBox(width: 12),
            Expanded(child: _buildTimeSlotCard(ref, TimeSlot.pm, orderState)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSlotCard(WidgetRef ref, TimeSlot timeSlot, TicketOrderState orderState) {
    final isSelected = orderState.selectedTimeSlot == timeSlot;
    final notifier = ref.read(ticketOrderProvider.notifier);
    
    return InkWell(
      onTap: () => notifier.selectTimeSlot(timeSlot),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColorScheme.primary100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              timeSlot == TimeSlot.am ? Icons.wb_sunny : Icons.nights_stay,
              color: isSelected ? AppColorScheme.primary700 : AppColorScheme.neutral500,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              timeSlot == TimeSlot.am ? 'Morning' : 'Afternoon',
              style: AppTheme.titleSmall.copyWith(
                color: isSelected ? AppColorScheme.primary700 : AppColorScheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              timeSlot == TimeSlot.am ? '08:15 - 13:00' : '13:30 - 18:30',
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

  Widget _buildTicketCounters(WidgetRef ref, TicketOrderState orderState) {
    const double adultPrice = 21.0;
    const double childPrice = 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tickets',
          style: AppTheme.titleMedium.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Adult Tickets
        _buildTicketCounter(
          ref: ref,
          title: 'Adult',
          subtitle: adultPrice > 0 ? '€${adultPrice.toStringAsFixed(2)}' : 'Free',
          count: orderState.attendees.where((a) => a.type == AttendeeType.adult).length,
          onIncrement: () => ref.read(ticketOrderProvider.notifier).addAttendee(AttendeeType.adult),
          onDecrement: () {
            final adults = orderState.attendees.where((a) => a.type == AttendeeType.adult).toList();
            if (adults.isNotEmpty) {
              // Find the last adult index and remove it
              int lastAdultIndex = -1;
              for (int i = orderState.attendees.length - 1; i >= 0; i--) {
                if (orderState.attendees[i].type == AttendeeType.adult) {
                  lastAdultIndex = i;
                  break;
                }
              }
              if (lastAdultIndex != -1) {
                ref.read(ticketOrderProvider.notifier).removeAttendee(lastAdultIndex);
              }
            }
          },
        ),
        
        const SizedBox(height: 12),
        
        // Child Tickets
        _buildTicketCounter(
          ref: ref,
          title: 'Child (0-17)',
          subtitle: childPrice > 0 ? '€${childPrice.toStringAsFixed(2)}' : 'Free',
          count: orderState.attendees.where((a) => a.type == AttendeeType.child).length,
          onIncrement: () => ref.read(ticketOrderProvider.notifier).addAttendee(AttendeeType.child),
          onDecrement: () {
            final children = orderState.attendees.where((a) => a.type == AttendeeType.child).toList();
            if (children.isNotEmpty) {
              // Find the last child index and remove it
              int lastChildIndex = -1;
              for (int i = orderState.attendees.length - 1; i >= 0; i--) {
                if (orderState.attendees[i].type == AttendeeType.child) {
                  lastChildIndex = i;
                  break;
                }
              }
              if (lastChildIndex != -1) {
                ref.read(ticketOrderProvider.notifier).removeAttendee(lastChildIndex);
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildTicketCounter({
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorScheme.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorScheme.neutral200),
      ),
      child: Row(
        children: [
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
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: count > 0 ? onDecrement : null,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: count > 0 ? AppColorScheme.primary100 : AppColorScheme.neutral200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: count > 0 ? AppColorScheme.primary : AppColorScheme.neutral400,
                    size: 20,
                  ),
                ),
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: AppTheme.titleMedium.copyWith(
                    color: AppColorScheme.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColorScheme.primary100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, WidgetRef ref, TicketOrderState orderState) {
    final hasTickets = orderState.attendees.isNotEmpty;
    
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: hasTickets ? () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TicketDetailsScreen(),
            ),
          );
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasTickets ? AppColorScheme.primary : AppColorScheme.neutral300,
          foregroundColor: Colors.white,
          elevation: hasTickets ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue Booking',
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

  Widget _buildImportantInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
                  color: AppColorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Important Information',
                  style: AppTheme.titleLarge.copyWith(
                    color: AppColorScheme.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...importantInfo.map((text) => _buildInfoItem(text)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColorScheme.neutral600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: AppTheme.labelSmall.copyWith(
                color: AppColorScheme.neutral700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(ticketOrderProvider.notifier);
    final selectedDate = ref.read(ticketOrderProvider).selectedDate;
    final earliestDate = DateTime.now().add(const Duration(days: 2));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? earliestDate,
      firstDate: earliestDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      notifier.selectDate(picked);
    }
  }
}
