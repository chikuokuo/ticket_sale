import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/attendee.dart';
import '../models/bundle.dart';
import '../providers/bundle_provider.dart';
import '../services/stripe_service.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../widgets/attendee_info_card.dart';
import '../widgets/train_recommendation_dialog.dart';
import '../screens/main_navigation_screen.dart';

class BundleOrderSummaryScreen extends ConsumerWidget {
  const BundleOrderSummaryScreen({super.key});

  void _backToBooking(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showTrainRecommendation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TrainRecommendationDialog(
        onBookTrain: () {
          Navigator.of(context).pop(); // Close dialog
          _navigateToTrainTab(context);
        },
        onSkip: () {
          Navigator.of(context).pop(); // Close dialog
          _backToBooking(context);
        },
      ),
    );
  }

  void _navigateToTrainTab(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Navigate to MainNavigationScreen with train tab selected (index 2)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(initialTabIndex: 2),
      ),
    );
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
              duration: const Duration(seconds: 3),
            ),
          );

          // Show train recommendation after a short delay
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (context.mounted) {
              _showTrainRecommendation(context);
            }
          });
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
            if (orderState.selectedPaymentMethod == PaymentMethod.atmTransfer) ...[
              const SizedBox(height: 16),
              _buildBankDetailsCard(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: orderState.atmLastFiveController,
                  decoration: const InputDecoration(
                    labelText: '银行账户末 5 码',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance),
                    helperText: '输入末 5 码用于付款验证',
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
    const String qrData = 'Bank: $bankName\nAccount: $bankAccount\nCode: $bankCode\nRecipient: $recipientName';

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
                '转账详情',
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
                    _buildBundleBankDetailRow('银行名称', bankName),
                    const SizedBox(height: 8),
                    _buildBundleBankDetailRow('账户号码', bankAccount),
                    const SizedBox(height: 8),
                    _buildBundleBankDetailRow('银行代码', bankCode),
                    const SizedBox(height: 8),
                    _buildBundleBankDetailRow('收款人', recipientName),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Right column - QR Code
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '扫码转账',
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
                    '请在 24 小时内完成转账。付款确认可能需要 1 个工作日。',
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

  Widget _buildBundleBankDetailRow(String label, String value) {
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
