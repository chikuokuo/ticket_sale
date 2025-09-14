import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/attendee.dart';
import '../models/bundle.dart';
import '../providers/bundle_provider.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';
import 'order_summary_screen.dart';
import '../models/order_type.dart';

class BundleParticipantScreen extends ConsumerStatefulWidget {
  final Bundle bundle;

  const BundleParticipantScreen({
    super.key,
    required this.bundle,
  });

  @override
  ConsumerState<BundleParticipantScreen> createState() =>
      _BundleParticipantScreenState();
}

class _BundleParticipantScreenState
    extends ConsumerState<BundleParticipantScreen> {
  final _formKey = GlobalKey<FormState>();

  void _navigateToSummary(BuildContext context, WidgetRef ref) {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final orderState = ref.read(bundleOrderProvider);
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
        builder: (context) => const OrderSummaryScreen(
          orderType: OrderType.bundle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(bundleOrderProvider);
    final totalAmount = orderState.attendees.length * widget.bundle.price;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participant Details'),
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
                  totalAmount,
                ),
                const SizedBox(height: 24),
                // Ticket holder information
                Text(
                  'Participant Information',
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
    BundleOrderState orderState,
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
                Icons.beach_access,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.bundle.title,
                  style: AppTheme.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
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
                    ? DateFormat('EEEE, MMMM dd, yyyy')
                        .format(orderState.selectedDate!)
                    : 'No date selected',
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
                '${orderState.attendees.length} participant(s)',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColorScheme.primary.withAlpha(26), // 0.1 opacity
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Participant ${index + 1}',
                style: AppTheme.labelMedium.copyWith(
                  color: AppColorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(BundleOrderState orderState) {
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
                helperText: 'Confirmation will be sent to this email',
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
