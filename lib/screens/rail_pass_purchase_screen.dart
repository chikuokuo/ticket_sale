import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../models/rail_pass.dart';
import '../models/payment_method.dart' as app_models;
import '../models/payment_status.dart';
import '../services/rail_pass_service.dart';
import '../services/stripe_service.dart';

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

  // User information controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // Selected options
  final TicketCategory _selectedCategory = TicketCategory.individual;
  RailPassPricing? _selectedPricing;
  app_models.PaymentMethod _selectedPaymentMethod = app_models.PaymentMethod.creditCard;
  PaymentStatus _paymentStatus = PaymentStatus.idle;
  String? _paymentError;

  @override
  void initState() {
    super.initState();
    _selectedPricing = widget.railPass.pricing.first; // Default to first option
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  double get _currentPrice {
    if (_selectedPricing == null) return 0;
    return _selectedPricing!.individualPrice;
  }

  @override
  Widget build(BuildContext context) {
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
              _buildCustomerInfoCard(),
              const SizedBox(height: 24),

              // Payment Method
              _buildPaymentMethodCard(),
              const SizedBox(height: 24),

              // Order Total
              _buildOrderTotalCard(),
              const SizedBox(height: 32),

              // Purchase Button
              _buildPurchaseButton(),
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

  Widget _buildCustomerInfoCard() {
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
                  controller: _firstNameController,
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
                  controller: _lastNameController,
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
            controller: _emailController,
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
            controller: _addressController,
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

  Widget _buildPaymentMethodCard() {
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
            'Payment Method',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          RadioListTile<app_models.PaymentMethod>(
            title: const Text('Credit Card'),
            subtitle: const Text('Pay securely with your credit card'),
            value: app_models.PaymentMethod.creditCard,
            groupValue: _selectedPaymentMethod,
            onChanged: (app_models.PaymentMethod? value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            activeColor: AppColorScheme.primary,
          ),

          RadioListTile<app_models.PaymentMethod>(
            title: const Text('Bank Transfer'),
            subtitle: const Text('Transfer to our bank account'),
            value: app_models.PaymentMethod.atmTransfer,
            groupValue: _selectedPaymentMethod,
            onChanged: (app_models.PaymentMethod? value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            activeColor: AppColorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColorScheme.primary100, AppColorScheme.primary50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorScheme.primary200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.railPass.name,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColorScheme.neutral800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedPricing?.days} days • Individual',
                style: AppTheme.bodySmall.copyWith(
                  color: AppColorScheme.neutral600,
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppTheme.titleLarge.copyWith(
                  color: AppColorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '€${_currentPrice.toStringAsFixed(2)}',
                style: AppTheme.headlineMedium.copyWith(
                  color: AppColorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _paymentStatus == PaymentStatus.processing ? null : _handlePurchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppColorScheme.neutral300,
        ),
        child: _paymentStatus == PaymentStatus.processing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Processing...',
                    style: AppTheme.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Complete Purchase',
                    style: AppTheme.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handlePurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _paymentStatus = PaymentStatus.processing;
      _paymentError = null;
    });

    try {
      if (_selectedPaymentMethod == app_models.PaymentMethod.creditCard) {
        await _processCreditCardPayment();
      } else {
        await _processAtmTransferPayment();
      }
    } catch (e) {
      setState(() {
        _paymentStatus = PaymentStatus.failed;
        _paymentError = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${_paymentError ?? 'Payment failed'}'),
            backgroundColor: AppColorScheme.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handlePurchase,
            ),
          ),
        );
      }
    }
  }

  Future<void> _processCreditCardPayment() async {
    final stripeService = StripeService();

    final result = await stripeService.processPayment(
      context: context,
      amount: _currentPrice,
      currency: 'eur',
      customerEmail: _emailController.text,
      metadata: {
        'railPass': widget.railPass.name,
        'duration': '${_selectedPricing?.days} days',
        'category': _selectedCategory.name,
        'customerName': '${_firstNameController.text} ${_lastNameController.text}',
        'address': _addressController.text,
      },
    );

    if (result.status == PaymentStatus.success) {
      setState(() {
        _paymentStatus = PaymentStatus.success;
      });

      // Send confirmation via RailPassService
      await RailPassService.sendConfirmationEmail(_buildPurchaseData());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Payment successful! Rail pass details sent to your email.'),
            backgroundColor: AppColorScheme.success,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      throw Exception(result.error ?? 'Payment failed');
    }
  }

  Future<void> _processAtmTransferPayment() async {
    // For ATM transfer, just save order and send instructions
    await RailPassService.sendAtmTransferInstructions(_buildPurchaseData());

    setState(() {
      _paymentStatus = PaymentStatus.success;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Order received! We will confirm your payment within 24 hours.'),
          backgroundColor: AppColorScheme.success,
          duration: const Duration(seconds: 5),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Map<String, dynamic> _buildPurchaseData() {
    return {
      'railPass': widget.railPass,
      'selectedPricing': _selectedPricing,
      'selectedCategory': _selectedCategory,
      'customerInfo': {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
      },
      'paymentMethod': _selectedPaymentMethod,
      'totalAmount': _currentPrice,
    };
  }
}