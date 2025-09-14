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
    final orderState = ref.watch(ticketOrderProvider(TicketType.museum));
    final orderNotifier = ref.read(ticketOrderProvider(TicketType.museum).notifier);
    
    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Background and Title Section
            _buildHeader(context),

            // Main Content with Overlap
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Ticket Selection Card
                    _buildTicketSelectionCard(context, orderState, orderNotifier),
                    
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

  Widget _buildHeader(BuildContext context) {
    return Container(
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
              Colors.black.withAlpha(77), // 0.3 opacity
              Colors.black.withAlpha(153), // 0.6 opacity
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar with back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.3),
                        shape: const CircleBorder(),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // Original content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    color: Colors.white.withAlpha(230), // 0.9 opacity
                  ),
                ),
                const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _getBackgroundImage() {
    // Try to load the background image with fallback
    try {
      return const AssetImage('assets/images/Bg-UffiziGallery.jpg');
    } catch (e) {
      // Fallback to network image if asset is not found
      return const NetworkImage(
        'https://images.unsplash.com/photo-1541362939442-1cf2d9e45d96?w=800&h=600&fit=crop'
      );
    }
  }

  Widget _buildTicketSelectionCard(BuildContext context, TicketOrderState orderState, TicketOrderNotifier orderNotifier) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), // 0.08 opacity
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
            _buildDateSelection(context, orderState, orderNotifier),
            
            const SizedBox(height: 20),
            
            // Select Time Slot
            _buildTimeSlotSelection(orderState, orderNotifier),
            
            const SizedBox(height: 20),
            
            // Tickets Selection
            _buildTicketCounters(orderState, orderNotifier),
            
            const SizedBox(height: 24),
            
            // Continue Booking Button
            _buildContinueButton(context, orderState),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection(BuildContext context, TicketOrderState orderState, TicketOrderNotifier orderNotifier) {
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
          onTap: () => _selectDate(context, orderState, orderNotifier),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: orderState.selectedDate != null 
                  ? AppColorScheme.primary 
                  : AppColorScheme.neutral300,
                width: orderState.selectedDate != null ? 2 : 1,
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
                        : AppColorScheme.neutral600,
                    ),
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

  Widget _buildTimeSlotSelection(TicketOrderState orderState, TicketOrderNotifier orderNotifier) {
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
            Expanded(child: _buildTimeSlotCard(TimeSlot.am, orderState, orderNotifier)),
            const SizedBox(width: 12),
            Expanded(child: _buildTimeSlotCard(TimeSlot.pm, orderState, orderNotifier)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSlotCard(TimeSlot timeSlot, TicketOrderState orderState, TicketOrderNotifier orderNotifier) {
    final isSelected = orderState.selectedTimeSlot == timeSlot;
    
    return InkWell(
      onTap: () => orderNotifier.selectTimeSlot(timeSlot),
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
              timeSlot == TimeSlot.am ? Icons.wb_sunny : Icons.wb_sunny_outlined,
              color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral900,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              timeSlot == TimeSlot.am ? 'Morning' : 'Afternoon',
              style: AppTheme.titleSmall.copyWith(
                color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral900,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              timeSlot == TimeSlot.am ? '9:00 AM - 12:00 PM' : '1:00 PM - 5:00 PM',
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

  Widget _buildTicketCounters(TicketOrderState orderState, TicketOrderNotifier orderNotifier) {
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
        
        const SizedBox(height: 8),
        
        Text(
          'Select number of visitors',
          style: AppTheme.bodyMedium.copyWith(
            color: AppColorScheme.neutral600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Adult Tickets
        _buildTicketCounter(
          title: 'Adult',
          price: adultPrice > 0 ? '€${adultPrice.toStringAsFixed(2)}' : 'Free',
          count: orderState.attendees.where((a) => a.type == AttendeeType.adult).length,
          onIncrement: () => orderNotifier.addAttendee(AttendeeType.adult),
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
                orderNotifier.removeAttendee(lastAdultIndex);
              }
            }
          },
        ),
        
        const SizedBox(height: 12),
        
        // Child Tickets
        _buildTicketCounter(
          title: 'Child (0-17)',
          price: childPrice > 0 ? '€${childPrice.toStringAsFixed(2)}' : 'Free',
          count: orderState.attendees.where((a) => a.type == AttendeeType.child).length,
          onIncrement: () => orderNotifier.addAttendee(AttendeeType.child),
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
                orderNotifier.removeAttendee(lastChildIndex);
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildTicketCounter({
    required String title,
    required String price,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
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

  Widget _buildContinueButton(BuildContext context, TicketOrderState orderState) {
    final hasTickets = orderState.attendees.isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: hasTickets ? () {
          // Navigate to next page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TicketDetailsScreen(ticketType: TicketType.museum),
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
            const Icon(Icons.arrow_forward, size: 20),
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
            color: Colors.black.withAlpha(20), // 0.08 opacity
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
                const SizedBox(width: 8),
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
    );
  }


  Future<void> _selectDate(BuildContext context, TicketOrderState orderState, TicketOrderNotifier orderNotifier) async {
    final earliestDate = DateTime.now().add(const Duration(days: 2));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: orderState.selectedDate ?? earliestDate,
      firstDate: earliestDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      orderNotifier.selectDate(picked);
    }
  }
}
