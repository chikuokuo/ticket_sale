import 'dart:async';

class RailPassService {
  // Send confirmation email for successful rail pass purchase
  static Future<void> sendConfirmationEmail(Map<String, dynamic> purchaseData) async {
    try {
      final customerInfo = purchaseData['customerInfo'];
      final railPass = purchaseData['railPass'];
      final selectedPricing = purchaseData['selectedPricing'];
      final selectedCategory = purchaseData['selectedCategory'];

      print('Sending confirmation email to: ${customerInfo['email']}');
      print('Rail Pass: ${railPass.name}');
      print('Duration: ${selectedPricing.days} days');
      print('Category: ${selectedCategory.displayName}');
      print('Total Amount: €${purchaseData['totalAmount']}');

      // In a real app, you would integrate with an email service
      await Future.delayed(const Duration(milliseconds: 500));

      print('✅ Confirmation email sent successfully');
    } catch (e) {
      print('Error sending confirmation email: $e');
    }
  }

  // Send ATM transfer instructions for rail pass purchase
  static Future<void> sendAtmTransferInstructions(Map<String, dynamic> purchaseData) async {
    try {
      final customerInfo = purchaseData['customerInfo'];
      final totalAmount = purchaseData['totalAmount'];

      print('Sending ATM transfer instructions to: ${customerInfo['email']}');
      print('Amount to transfer: €$totalAmount');
      print('Bank details:');
      print('Account Name: European Rail Pass Ltd');
      print('IBAN: DE89 3704 0044 0532 0130 00');
      print('BIC: COBADEFFXXX');
      print('Reference: RAILPASS-${DateTime.now().millisecondsSinceEpoch}');

      // In a real app, you would integrate with an email service
      await Future.delayed(const Duration(milliseconds: 500));

      print('✅ ATM transfer instructions sent successfully');
    } catch (e) {
      print('Error sending ATM transfer instructions: $e');
    }
  }
}