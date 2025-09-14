import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/bundle_provider.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

class BundleOrderSummaryScreen extends ConsumerWidget {
  const BundleOrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundleOrder = ref.watch(bundleOrderProvider);
    
    if (bundleOrder.currentOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Summary')),
        body: const Center(
          child: Text('No bundle order found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: Text(
          'Order Summary',
          style: AppTheme.headlineSmall.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorScheme.neutral900),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bundle details
            _buildBundleDetailsCard(bundleOrder),
            
            const SizedBox(height: 20),
            
            // Booking details
            _buildBookingDetailsCard(bundleOrder),
            
            const SizedBox(height: 20),
            
            // Participants list
            _buildParticipantsCard(bundleOrder),
            
            const SizedBox(height: 20),
            
            // Contact information
            _buildContactCard(bundleOrder),
            
            const SizedBox(height: 32),
            
            // Total amount
            _buildTotalAmountCard(bundleOrder),
            
            const SizedBox(height: 32),
            
            // Payment button
            _buildPaymentButton(context, ref, bundleOrder),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleDetailsCard(BundleOrderState bundleOrder) {
    final bundle = bundleOrder.currentOrder!.bundle;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38), // 0.15 opacity
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bundle image placeholder
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColorScheme.neutral200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              image: DecorationImage(
                image: AssetImage(bundle.imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle image loading error silently
                },
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(77), // 0.3 opacity
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bundle.category,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bundle info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bundle.title,
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppColorScheme.neutral900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bundle.subtitle,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppColorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: AppColorScheme.neutral600,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bundle.duration,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppColorScheme.neutral600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.star,
                      color: AppColorScheme.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bundle.rating.toString(),
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppColorScheme.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard(BundleOrderState bundleOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // 0.1 opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Details',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Date',
            value: bundleOrder.currentOrder!.selectedDate != null
              ? DateFormat('EEEE, MMMM dd, yyyy').format(bundleOrder.currentOrder!.selectedDate!)
              : 'Not selected',
          ),
          
          const SizedBox(height: 12),
          
          _buildDetailRow(
            icon: Icons.people,
            label: 'Participants',
            value: '${bundleOrder.currentOrder!.participantCount} person${bundleOrder.currentOrder!.participantCount > 1 ? 's' : ''}',
          ),
          
          const SizedBox(height: 12),
          
          _buildDetailRow(
            icon: Icons.euro,
            label: 'Price per person',
            value: '€${bundleOrder.currentOrder!.bundle.price.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsCard(BundleOrderState bundleOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // 0.1 opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participants',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...bundleOrder.currentOrder!.participants.asMap().entries.map((entry) {
            final index = entry.key;
            final participant = entry.value;
            
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColorScheme.primary100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTheme.titleSmall.copyWith(
                            color: AppColorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${participant.givenName} ${participant.familyName}',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppColorScheme.neutral900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (index < bundleOrder.currentOrder!.participants.length - 1)
                  const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactCard(BundleOrderState bundleOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // 0.1 opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow(
            icon: Icons.email,
            label: 'Contact Email',
            value: bundleOrder.currentOrder!.contactEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmountCard(BundleOrderState bundleOrder) {
    final totalAmount = bundleOrder.currentOrder!.participantCount * bundleOrder.currentOrder!.bundle.price;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorScheme.primary,
            AppColorScheme.primary600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColorScheme.primary.withAlpha(77), // 0.3 opacity
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount',
                style: AppTheme.titleLarge.copyWith(
                  color: Colors.white.withAlpha(230), // 0.9 opacity
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${bundleOrder.currentOrder!.participantCount} × €${bundleOrder.currentOrder!.bundle.price.toStringAsFixed(2)}',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white.withAlpha(204), // 0.8 opacity
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

  Widget _buildPaymentButton(BuildContext context, WidgetRef ref, BundleOrderState bundleOrder) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: bundleOrder.isLoading ? null : () => _processPayment(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: bundleOrder.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Confirm Order & Pay',
                  style: AppTheme.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColorScheme.neutral600,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColorScheme.neutral600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppColorScheme.neutral900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(bundleOrderProvider.notifier).processPayment(context);
      
      // If payment is successful, navigate back to bundles list
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // Error handling is done in the provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: AppColorScheme.error,
        ),
      );
    }
  }
}
