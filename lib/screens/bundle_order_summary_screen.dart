import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/attendee.dart';
import '../models/bundle.dart';
import '../providers/bundle_provider.dart';
import '../services/stripe_service.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../widgets/attendee_info_card.dart';

class BundleOrderSummaryScreen extends ConsumerWidget {
  const BundleOrderSummaryScreen({super.key});

  void _backToBooking(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _handleConfirm(BuildContext context, WidgetRef ref) async {
    final orderNotifier = ref.read(bundleOrderProvider.notifier);
    final selectedPaymentMethod = ref.read(bundleOrderProvider).selectedPaymentMethod;

    if (selectedPaymentMethod == PaymentMethod.creditCard) {
      await orderNotifier.processPayment(context);
    } else {
      await orderNotifier.submitAtmPayment();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<BundleOrderState>(bundleOrderProvider, (previous, current) {
      if (previous?.paymentStatus != current.paymentStatus) {
        if (current.paymentStatus == PaymentStatus.success) {
          final isAtmTransfer = current.selectedPaymentMethod == PaymentMethod.atmTransfer;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAtmTransfer
                    ? '✅ 订单已收到！我们将在 24 小时内确认您的付款。'
                    : '🎉 支付成功！详情已发送至您的电子邮箱。',
              ),
              backgroundColor: AppColorScheme.success,
              duration: const Duration(seconds: 5),
            ),
          );
          _backToBooking(context);
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

    final orderState = ref.watch(bundleOrderProvider);
    final orderNotifier = ref.read(bundleOrderProvider.notifier);
    final totalAmount = orderNotifier.getTotalAmount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('订单摘要'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: orderState.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildBundleDetailsCard(orderState.selectedBundle, orderState.selectedDate),
            const SizedBox(height: 16),
            AttendeeInfoCard(
              attendees: orderState.attendees,
              emailController: orderState.customerEmailController,
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(orderState, orderNotifier),
            const SizedBox(height: 16),
            _buildTotalAmountCard(totalAmount),
            const SizedBox(height: 24),
            _buildActionButtons(context, ref, orderState),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleDetailsCard(Bundle? bundle, DateTime? selectedDate) {
    if (bundle == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('未选择套餐'),
        ),
      );
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bundle.title, style: AppTheme.titleLarge),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: '日期',
              value: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate) : '未选择',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BundleOrderState orderState,
    BundleOrderNotifier orderNotifier,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('支付方式', style: AppTheme.titleLarge),
            const SizedBox(height: 8),
            RadioListTile<PaymentMethod>(
              title: const Text('信用卡'),
              value: PaymentMethod.creditCard,
              groupValue: orderState.selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) orderNotifier.selectPaymentMethod(value);
              },
            ),
            RadioListTile<PaymentMethod>(
              title: const Text('ATM 转账'),
              value: PaymentMethod.atmTransfer,
              groupValue: orderState.selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) orderNotifier.selectPaymentMethod(value);
              },
            ),
            if (orderState.selectedPaymentMethod == PaymentMethod.atmTransfer)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: orderState.atmLastFiveController,
                  decoration: const InputDecoration(
                    labelText: '银行账户末 5 码',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  validator: (value) {
                    if (value == null || value.length < 5) {
                      return '请输入 5 位数字';
                    }
                    return null;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmountCard(double totalAmount) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('总金额', style: AppTheme.titleLarge),
            Text(
              '€${totalAmount.toStringAsFixed(2)}',
              style: AppTheme.titleLarge?.copyWith(color: AppColorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, BundleOrderState orderState) {
    final isProcessing = orderState.paymentStatus == PaymentStatus.processing;
    final paymentMethod = orderState.selectedPaymentMethod;
    final buttonText = paymentMethod == PaymentMethod.creditCard ? '确认订单并支付' : '确认 ATM 转账';

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isProcessing ? null : () => _handleConfirm(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(buttonText),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: isProcessing ? null : () => Navigator.of(context).pop(),
            child: const Text('返回修改'),
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
