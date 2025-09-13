import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/attendee.dart';
import '../models/time_slot.dart';
import '../providers/ticket_order_provider.dart';
import '../services/stripe_service.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';

class OrderSummaryScreen extends ConsumerWidget {
  const OrderSummaryScreen({super.key});

  Future<void> _confirmOrder(BuildContext context, WidgetRef ref) async {
    final orderNotifier = ref.read(ticketOrderProvider.notifier);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirm Order',
          style: AppTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to proceed with the payment?',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Once confirmed, you will be charged and tickets will be sent to your email.',
              style: AppTheme.bodySmall.copyWith(
                color: AppColorScheme.neutral600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColorScheme.neutral600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      // Process payment
      await orderNotifier.processPayment(context);
    }
  }

  void _backToBooking(BuildContext context) {
    // Return to first page (pop all until first)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(ticketOrderProvider);
    final orderNotifier = ref.read(ticketOrderProvider.notifier);

    final int adultCount = orderState.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = orderState.attendees.where((a) => a.type == AttendeeType.child).length;
    final double adultPrice = 23.5;
    final double childPrice = 2.5;
    final double totalAmount = orderNotifier.getTotalAmount();

    // Listen to payment status changes
    ref.listen<TicketOrderState>(ticketOrderProvider, (previous, current) {
      if (previous?.paymentStatus != current.paymentStatus) {
        if (current.paymentStatus == PaymentStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('🎉 Payment successful! Tickets sent to your email.'),
              backgroundColor: AppColorScheme.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
          // Return to first page
          _backToBooking(context);
        } else if (current.paymentStatus == PaymentStatus.failed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                current.paymentError ?? 'Payment failed. Please try again.',
              ),
              backgroundColor: AppColorScheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
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
              AppColorScheme.primary.withOpacity(0.05),
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
              // Castle information card
              _buildCastleInfoCard(orderState),
              
              const SizedBox(height: 24),

              // Ticket details
              _buildTicketDetailsCard(
                adultCount,
                childCount,
                adultPrice,
                childPrice,
              ),

              const SizedBox(height: 24),

              // Visitor information
              _buildVisitorInfoCard(orderState),

              const SizedBox(height: 24),

              // Contact information
              _buildContactCard(orderState),

              const SizedBox(height: 24),

              // Total amount card
              _buildTotalCard(totalAmount),

              const SizedBox(height: 32),

              // Button area
              _buildActionButtons(context, ref, orderState),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCastleInfoCard(TicketOrderState orderState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Neuschwanstein Castle',
                      style: AppTheme.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Hohenschwangau, Bavaria',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Visit details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.calendar_today,
                  'Date',
                  orderState.selectedDate != null
                    ? DateFormat('EEEE, MMMM dd, yyyy').format(orderState.selectedDate!)
                    : 'Not selected',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  orderState.selectedTimeSlot == TimeSlot.am 
                    ? Icons.wb_sunny 
                    : Icons.wb_sunny_outlined,
                  'Time',
                  orderState.selectedTimeSlot == TimeSlot.am 
                    ? 'Morning Session (9:00 AM - 12:00 PM)'
                    : 'Afternoon Session (1:00 PM - 5:00 PM)',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.people,
                  'Visitors',
                  '${orderState.attendees.length} ${orderState.attendees.length == 1 ? "person" : "people"}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.labelSmall.copyWith(
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketDetailsCard(
    int adultCount,
    int childCount,
    double adultPrice,
    double childPrice,
  ) {
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
                  Icons.confirmation_number,
                  color: AppColorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ticket Details',
                  style: AppTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (adultCount > 0) ...[
              _buildTicketRow(
                'Adult Ticket (18+)',
                adultCount,
                adultPrice,
                adultCount * adultPrice,
              ),
            ],
            
            if (childCount > 0) ...[
              const SizedBox(height: 12),
              _buildTicketRow(
                'Child Ticket (0-17)',
                childCount,
                childPrice,
                childCount * childPrice,
              ),
            ],
            
            const SizedBox(height: 16),
            Container(
              height: 1,
              width: double.infinity,
              color: AppColorScheme.neutral200,
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Tickets',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${adultCount + childCount}',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketRow(String type, int quantity, double unitPrice, double totalPrice) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            type,
            style: AppTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Text(
            '×$quantity',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            '€${unitPrice.toStringAsFixed(2)}',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            '€${totalPrice.toStringAsFixed(2)}',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildVisitorInfoCard(TicketOrderState orderState) {
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
                  Icons.people,
                  color: AppColorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Visitor Information',
                  style: AppTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderState.attendees.length,
              separatorBuilder: (context, index) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final attendee = orderState.attendees[index];
                return _buildVisitorRow(attendee, index + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorRow(Attendee attendee, int number) {
    final fullName = '${attendee.givenNameController.text.trim()} ${attendee.familyNameController.text.trim()}'.trim();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: attendee.type == AttendeeType.adult 
              ? AppColorScheme.primary.withOpacity(0.1)
              : AppColorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '$number',
              style: AppTheme.labelMedium.copyWith(
                color: attendee.type == AttendeeType.adult 
                  ? AppColorScheme.primary
                  : AppColorScheme.secondary800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName.isNotEmpty ? fullName : 'Name not provided',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: attendee.type == AttendeeType.adult 
                        ? AppColorScheme.primary.withOpacity(0.1)
                        : AppColorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      attendee.type == AttendeeType.adult ? 'Adult' : 'Child',
                      style: AppTheme.labelSmall.copyWith(
                        color: attendee.type == AttendeeType.adult 
                          ? AppColorScheme.primary
                          : AppColorScheme.secondary800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Passport: ${attendee.passportNumberController.text.trim()}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColorScheme.neutral600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(TicketOrderState orderState) {
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
                    orderState.customerEmailController.text.trim(),
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tickets will be sent to this email address',
              style: AppTheme.bodySmall.copyWith(
                color: AppColorScheme.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(double totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColorScheme.success700, AppColorScheme.success500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount',
                style: AppTheme.titleMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
              Text(
                'Including all taxes',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          Text(
            '€${totalAmount.toStringAsFixed(2)}',
            style: AppTheme.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, TicketOrderState orderState) {
    final isProcessing = orderState.paymentStatus == PaymentStatus.processing;
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isProcessing ? null : () => _confirmOrder(context, ref),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              backgroundColor: AppColorScheme.success,
              foregroundColor: Colors.white,
            ),
            child: isProcessing 
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Processing Payment...'),
                  ],
                )
              : const Text(
                  'Confirm Order & Pay',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isProcessing ? null : () => _backToBooking(context),
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
      ],
    );
  }
}
