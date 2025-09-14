import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bundle_provider.dart';
import '../screens/bundle_order_summary_screen.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../models/attendee.dart';
import '../services/stripe_service.dart';

class BundleParticipantScreen extends ConsumerStatefulWidget {
  const BundleParticipantScreen({super.key});

  @override
  ConsumerState<BundleParticipantScreen> createState() => _BundleParticipantScreenState();
}

class _BundleParticipantScreenState extends ConsumerState<BundleParticipantScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bundleOrder = ref.watch(bundleOrderProvider);
    final bundleNotifier = ref.read(bundleOrderProvider.notifier);
    
    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: Text(
          'Participant Information',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Participant information
              _buildParticipantSection(bundleOrder),
              
              const SizedBox(height: 32),
              
              // Contact information
              _buildContactSection(bundleOrder),
              
              const SizedBox(height: 40),
              
              // Continue button
              _buildContinueButton(bundleOrder),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantSection(BundleOrderState bundleOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          Text(
            'Participant Details',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide the full name for each participant',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColorScheme.neutral600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Participant forms
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bundleOrder.attendees.length,
            itemBuilder: (context, index) {
              final attendee = bundleOrder.attendees[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index < bundleOrder.attendees.length - 1 ? 24.0 : 0),
                child: _buildParticipantForm(index + 1, attendee),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantForm(int participantNumber, Attendee attendee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participant $participantNumber',
          style: AppTheme.titleMedium.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: attendee.givenNameController,
                decoration: InputDecoration(
                  labelText: 'Given Name',
                  hintText: 'Enter given name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColorScheme.primary),
                  ),
                ),
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
                decoration: InputDecoration(
                  labelText: 'Family Name',
                  hintText: 'Enter family name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColorScheme.primary),
                  ),
                ),
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
    );
  }

  Widget _buildContactSection(BundleOrderState bundleOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          Text(
            'Contact Information',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll send your booking confirmation to this email',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColorScheme.neutral600,
            ),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: bundleOrder.customerEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Contact Email',
              hintText: 'Enter your email address',
              prefixIcon: Icon(Icons.email, color: AppColorScheme.neutral600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColorScheme.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BundleOrderState bundleOrder) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _proceedToOrderSummary(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: bundleOrder.paymentStatus == PaymentStatus.processing
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
                Text(
                  'Review Order',
                  style: AppTheme.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 20,
                ),
              ],
            ),
      ),
    );
  }

  void _proceedToOrderSummary() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BundleOrderSummaryScreen(),
        ),
      );
    }
  }
}
