import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/order_type.dart';
import '../models/payment_method.dart';
import '../models/payment_status.dart';
import '../models/time_slot.dart';
import '../providers/bundle_provider.dart';
import '../providers/ticket_order_provider.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../widgets/attendee_info_card.dart';

class OrderSummaryScreen extends ConsumerStatefulWidget {
  final OrderType orderType;
  final TicketType? ticketType;

  const OrderSummaryScreen({
    super.key,
    required this.orderType,
    this.ticketType,
  }) : assert(orderType == OrderType.ticket ? ticketType != null : true,
            'ticketType must be provided for ticket orders');

  @override
  ConsumerState<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends ConsumerState<OrderSummaryScreen> {
  final _formKey = GlobalKey<FormState>();

  void _backToBooking(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _handleConfirm(BuildContext context, WidgetRef ref) async {
    dynamic orderNotifier;

    if (widget.orderType == OrderType.ticket) {
      orderNotifier = ref.read(ticketOrderProvider(widget.ticketType!).notifier);
    } else {
      orderNotifier = ref.read(bundleOrderProvider.notifier);
    }

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    final dynamic orderState = (widget.orderType == OrderType.ticket)
        ? ref.read(ticketOrderProvider(widget.ticketType!))
        : ref.read(bundleOrderProvider);

    final paymentMethod = orderState.selectedPaymentMethod;

    if (paymentMethod == PaymentMethod.creditCard) {
      await orderNotifier.processPayment(context);
    } else {
      await orderNotifier.submitAtmPayment();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProviderListenable<dynamic> provider;
    dynamic orderNotifier;

    if (widget.orderType == OrderType.ticket) {
      provider = ticketOrderProvider(widget.ticketType!);
      orderNotifier = ref.read(ticketOrderProvider(widget.ticketType!).notifier);
    } else {
      provider = bundleOrderProvider;
      orderNotifier = ref.read(bundleOrderProvider.notifier);
    }

    ref.listen(provider, (previous, current) {
      if (previous?.paymentStatus != current.paymentStatus) {
        if (current.paymentStatus == PaymentStatus.success) {
          final isAtmTransfer = current.selectedPaymentMethod == PaymentMethod.atmTransfer;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    isAtmTransfer ? Icons.pending_actions : Icons.check_circle,
                    color: isAtmTransfer ? AppColorScheme.info : AppColorScheme.success,
                  ),
                  const SizedBox(width: 8),
                  Text(isAtmTransfer ? 'Order Received' : 'Payment Successful'),
                ],
              ),
              content: Text(
                isAtmTransfer
                    ? 'We have received your order and will confirm your payment within 24 hours. Thank you for your purchase!'
                    : 'Your payment was successful! A confirmation and your ticket details have been sent to your email.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _backToBooking(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else if (current.paymentStatus == PaymentStatus.failed && current.paymentError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${current.paymentError}'),
              backgroundColor: AppColorScheme.error,
            ),
          );
        }
      }
    });

    final dynamic orderState = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildOrderDetailsCard(orderState),
            const SizedBox(height: 16),
            AttendeeInfoCard(
              attendees: orderState.attendees,
              emailController: orderState.customerEmailController,
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(orderState, orderNotifier),
            const SizedBox(height: 16),
            _buildTotalAmountCard(orderNotifier),
            const SizedBox(height: 24),
            _buildActionButtons(context, ref, orderState),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard(dynamic orderState) {
    String title = 'Order Details';
    List<Widget> details = [];

    if (orderState is TicketOrderState) {
      title = orderState.ticketType == TicketType.museum
          ? 'Uffizi Galleries'
          : 'Neuschwanstein Castle';
      details = [
        _buildInfoRow(
          icon: Icons.calendar_today,
          label: 'Date',
          value: orderState.selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(orderState.selectedDate!)
              : 'Not selected',
        ),
      ];

      if (orderState.ticketType == TicketType.neuschwanstein) {
        details.add(
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Time',
            value: orderState.selectedTimeSlot?.displayName ?? 'Not selected',
          ),
        );
      } else if (orderState.ticketType == TicketType.museum) {
        details.add(
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Time',
            value: 'Any time during opening hours',
          ),
        );
      }
    } else if (orderState is BundleOrderState) {
      title = orderState.selectedBundle?.title ?? 'Package Details';
      details = [
         _buildInfoRow(
          icon: Icons.calendar_today,
          label: 'Date',
          value: orderState.selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(orderState.selectedDate!)
              : 'Not selected',
        ),
      ];
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.titleLarge),
            const SizedBox(height: 16),
            ...details,
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(dynamic orderState, dynamic orderNotifier) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Method', style: AppTheme.titleLarge),
            const SizedBox(height: 8),
            RadioListTile<PaymentMethod>(
              title: const Text('Credit Card'),
              value: PaymentMethod.creditCard,
              groupValue: orderState.selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) orderNotifier.selectPaymentMethod(value);
              },
            ),
            RadioListTile<PaymentMethod>(
              title: const Text('ATM Transfer'),
              value: PaymentMethod.atmTransfer,
              groupValue: orderState.selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) orderNotifier.selectPaymentMethod(value);
              },
            ),
            if (orderState.selectedPaymentMethod == PaymentMethod.atmTransfer) ...[
              const SizedBox(height: 16),
              _buildBankDetailsCard(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: TextFormField(
                  controller: orderState.atmLastFiveController,
                  decoration: const InputDecoration(
                    labelText: 'Last 5 digits of your bank account',
                    hintText: 'Required for payment confirmation',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  validator: (value) {
                    if (value == null || value.length < 5) {
                      return 'Please enter all 5 digits';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailsCard() {
    // Bank details for ATM Transfer
    const String bankName = 'Neuschwanstein Bank';
    const String bankAccount = '1234-5678-9012-3456';
    const String bankCode = 'NEUS123';
    const String recipientName = 'Castle Tour Service';

    // QR Code data for transfer
    const String qrData =
        'Bank: $bankName\nAccount: $bankAccount\nCode: $bankCode\nRecipient: $recipientName';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorScheme.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColorScheme.primary.withAlpha(77), // 0.3 opacity
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: AppColorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Transfer Details',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bank details in two columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Bank details
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBankDetailRow('Bank Name', bankName),
                    const SizedBox(height: 8),
                    _buildBankDetailRow('Account Number', bankAccount),
                    const SizedBox(height: 8),
                    _buildBankDetailRow('Bank Code', bankCode),
                    const SizedBox(height: 8),
                    _buildBankDetailRow('Recipient', recipientName),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Right column - QR Code
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Scan to Transfer',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppColorScheme.neutral600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26), // 0.1 opacity
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 120,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Important note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorScheme.warning.withAlpha(26), // 0.1 opacity
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColorScheme.warning.withAlpha(77), // 0.3 opacity
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColorScheme.warning700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please complete the transfer within 24 hours. Payment confirmation may take up to 1 business day.',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColorScheme.warning700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: AppColorScheme.neutral600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColorScheme.neutral900,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAmountCard(dynamic orderNotifier) {
    final double totalAmount = orderNotifier.getTotalAmount();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total Amount', style: AppTheme.titleLarge),
            Text(
              '€${totalAmount.toStringAsFixed(2)}',
              style: AppTheme.titleLarge.copyWith(color: AppColorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, dynamic orderState) {
    final isProcessing = orderState.paymentStatus == PaymentStatus.processing;

    final paymentMethod = orderState.selectedPaymentMethod;
    final buttonText = paymentMethod == PaymentMethod.creditCard
        ? 'Confirm & Pay'
        : 'Confirm ATM Transfer';

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isProcessing ? null : () => _handleConfirm(context, ref),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              backgroundColor: AppColorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: isProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Processing...'),
                    ],
                  )
                : Text(
                    buttonText,
                    style: const TextStyle(
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
            onPressed: isProcessing ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to Modify',
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

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label:', style: AppTheme.bodyMedium),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: AppTheme.bodyLarge, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

extension TimeSlotExtension on TimeSlot {
  String get displayName {
    switch (this) {
      case TimeSlot.am:
        return 'AM (9:00 - 12:00)';
      case TimeSlot.pm:
        return 'PM (1:00 - 5:00)';
    }
  }
}
