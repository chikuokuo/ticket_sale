import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_type.dart';
import '../providers/rail_pass_order_provider.dart';
import '../screens/order_summary_screen.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../models/rail_pass.dart';

class RailPassPurchaseScreen extends ConsumerStatefulWidget {
  final RailPass railPass;

  const RailPassPurchaseScreen({
    super.key,
    required this.railPass,
  });

  @override
  ConsumerState<RailPassPurchaseScreen> createState() => _RailPassPurchaseScreenState();
}

class _RailPassPurchaseScreenState extends ConsumerState<RailPassPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Selected options
  RailPassPricing? _selectedPricing;

  @override
  void initState() {
    super.initState();
    _selectedPricing = widget.railPass.pricing.first; // Default to first option
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize controllers with provider's state if needed, or clear them
      final notifier = ref.read(railPassOrderProvider.notifier);
      notifier.state.firstNameController.clear();
      notifier.state.lastNameController.clear();
      notifier.state.emailController.clear();
      notifier.state.addressController.clear();
    });
  }

  void _navigateToSummary() {
    if (!_formKey.currentState!.validate() || _selectedPricing == null) {
      return;
    }
    _formKey.currentState!.save();

    final notifier = ref.read(railPassOrderProvider.notifier);
    notifier.setOrderDetails(
      railPass: widget.railPass,
      pricing: _selectedPricing!,
      firstName: notifier.state.firstNameController.text,
      lastName: notifier.state.lastNameController.text,
      email: notifier.state.emailController.text,
      address: notifier.state.addressController.text,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OrderSummaryScreen(
          orderType: OrderType.railPass,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(railPassOrderProvider);

    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: const Text('Purchase Rail Pass'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleTextStyle: AppTheme.headlineSmall.copyWith(
          color: AppColorScheme.neutral900,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rail Pass Summary Card
              _buildPassSummaryCard(),
              const SizedBox(height: 24),

              // Pass Options Selection
              _buildPassOptionsCard(),
              const SizedBox(height: 24),

              // Customer Information
              _buildCustomerInfoCard(orderState),
              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 opacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            widget.railPass.flagIcon,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.railPass.name,
                  style: AppTheme.titleLarge.copyWith(
                    color: AppColorScheme.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.railPass.description,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColorScheme.neutral600,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.railPass.features.take(3).map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColorScheme.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColorScheme.neutral700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassOptionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 opacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pass Options',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Pass Duration Selection
          Text(
            'Pass Duration',
            style: AppTheme.titleMedium.copyWith(
              color: AppColorScheme.neutral700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.railPass.pricing.map((pricing) {
            final isSelected = _selectedPricing == pricing;
            final price = _getPriceForCategory(pricing);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPricing = pricing;
                });
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColorScheme.primary50 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${pricing.days} Flexible Days',
                      style: AppTheme.titleMedium.copyWith(
                        color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${pricing.currency}${price.toStringAsFixed(0)}',
                      style: AppTheme.titleMedium.copyWith(
                        color: isSelected ? AppColorScheme.primary : AppColorScheme.neutral700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  double _getPriceForCategory(RailPassPricing pricing) {
    return pricing.individualPrice;
  }

  Widget _buildCustomerInfoCard(RailPassOrderState orderState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 opacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Information',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Name Fields
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: orderState.firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: orderState.lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: orderState.emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Address
          TextFormField(
            controller: orderState.addressController,
            decoration: const InputDecoration(
              labelText: 'Address *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _navigateToSummary,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              backgroundColor: AppColorScheme.primary,
              foregroundColor: Colors.white,
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
              'Back',
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