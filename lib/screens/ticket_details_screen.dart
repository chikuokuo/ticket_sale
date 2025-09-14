import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/attendee.dart';
import '../models/time_slot.dart';
import '../providers/ticket_order_provider.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';
import 'order_summary_screen.dart';
import '../models/order_type.dart';

class TicketDetailsScreen extends ConsumerStatefulWidget {
  final TicketType ticketType;

  const TicketDetailsScreen({
    super.key,
    required this.ticketType,
  });

  @override
  ConsumerState<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends ConsumerState<TicketDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  void _navigateToSummary(BuildContext context, WidgetRef ref) {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final orderState = ref.read(ticketOrderProvider(widget.ticketType));
    // Validate contact information
    if (orderState.customerEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in Contact Email'),
          backgroundColor: AppColorScheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigate to confirmation page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderSummaryScreen(
          orderType: OrderType.ticket,
          ticketType: widget.ticketType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(ticketOrderProvider(widget.ticketType));
    final orderNotifier = ref.read(ticketOrderProvider(widget.ticketType).notifier);

    final int adultCount = orderState.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = orderState.attendees.where((a) => a.type == AttendeeType.child).length;
    final double totalAmount = orderNotifier.getTotalAmount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Holder Details'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order summary card
                _buildOrderSummaryCard(
                  context,
                  orderState,
                  adultCount,
                  childCount,
                  totalAmount,
                ),
                const SizedBox(height: 24),
                // Ticket holder information
                Text(
                  'Ticket Holder Information',
                  style: AppTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                // Details for each ticket
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderState.attendees.length,
                  itemBuilder: (context, index) {
                    final attendee = orderState.attendees[index];
                    return _buildAttendeeCard(
                      context,
                      attendee,
                      index,
                      orderNotifier,
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Contact information
                _buildContactInfoCard(orderState),
                const SizedBox(height: 32),
                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToSummary(context, ref),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Continue to Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Back button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Booking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(
    BuildContext context,
    TicketOrderState orderState,
    int adultCount,
    int childCount,
    double totalAmount,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.castleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.castle,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Neuschwanstein Castle',
                style: AppTheme.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date and time
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                orderState.selectedDate != null
                  ? DateFormat('EEEE, MMMM dd, yyyy').format(orderState.selectedDate!)
                  : 'No date selected',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(
                orderState.selectedTimeSlot == TimeSlot.am 
                  ? Icons.wb_sunny 
                  : Icons.wb_sunny_outlined,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                orderState.selectedTimeSlot == TimeSlot.am 
                  ? 'Morning (9:00 AM - 12:00 PM)'
                  : 'Afternoon (1:00 PM - 5:00 PM)',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Number of tickets
          Row(
            children: [
              Icon(
                Icons.people,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${orderState.attendees.length} ticket(s)',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              if (adultCount > 0) ...[
                Text(
                  ' • $adultCount adult(s)',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
              if (childCount > 0) ...[
                Text(
                  ' • $childCount child(ren)',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // Total amount
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: AppTheme.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  '€${totalAmount.toStringAsFixed(2)}',
                  style: AppTheme.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeCard(
    BuildContext context,
    Attendee attendee,
    int index,
    TicketOrderNotifier orderNotifier,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: attendee.type == AttendeeType.adult 
                      ? AppColorScheme.primary.withAlpha(26) // 0.1 opacity
                      : AppColorScheme.secondary.withAlpha(26), // 0.1 opacity
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Ticket ${index + 1} - ${attendee.type == AttendeeType.adult ? "Adult" : "Child"}',
                    style: AppTheme.labelMedium.copyWith(
                      color: attendee.type == AttendeeType.adult 
                        ? AppColorScheme.primary
                        : AppColorScheme.secondary800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  attendee.type == AttendeeType.adult ? '€21.00' : 'Free',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppColorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Name inputs
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: attendee.givenNameController,
                    decoration: const InputDecoration(
                      labelText: 'Given Name *',
                      hintText: 'Enter first name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Given name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: attendee.familyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Family Name *',
                      hintText: 'Enter last name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Family name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Passport number input
            TextFormField(
              controller: attendee.passportNumberController,
              decoration: const InputDecoration(
                labelText: 'Passport Number *',
                hintText: 'Enter passport number',
                prefixIcon: Icon(Icons.badge_outlined),
                helperText: 'Required for castle entry',
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Passport number is required';
                }
                if (value.trim().length < 6) {
                  return 'Passport number must be at least 6 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(TicketOrderState orderState) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_mail,
                  color: AppColorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: AppTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: orderState.customerEmailController,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
                helperText: 'Tickets will be sent to this email',
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
