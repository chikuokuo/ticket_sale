import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

enum PaymentStatus { idle, processing, success, failed }

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  static String get _secretKey => dotenv.env['STRIPE_SECRET_KEY']!;

  // Create payment intent on Stripe
  Future<Map<String, dynamic>> createPaymentIntent({
    required String amount, // Amount in cents (e.g., "2350" for €23.50)
    required String currency,
    String? customerEmail,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
        if (customerEmail != null) 'receipt_email': customerEmail,
        if (metadata != null) ...{
          for (var entry in metadata.entries)
            'metadata[${entry.key}]': entry.value.toString(),
        },
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (err) {
      throw Exception('Error creating payment intent: $err');
    }
  }

  // Process payment using Stripe Payment Sheet
  Future<PaymentResult> processPayment({
    required BuildContext context,
    required double amount, // Amount in euros (e.g., 23.50)
    required String currency,
    String? customerEmail,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Convert amount to cents for Stripe
      final amountInCents = (amount * 100).round().toString();

      // Create payment intent
      final paymentIntentData = await createPaymentIntent(
        amount: amountInCents,
        currency: currency,
        customerEmail: customerEmail,
        metadata: metadata,
      );

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Neuschwanstein Castle Tickets',
          customerEphemeralKeySecret: null,
          customerId: null,
          style: ThemeMode.system,
          billingDetails: customerEmail != null
            ? BillingDetails(email: customerEmail)
            : null,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      return PaymentResult(
        status: PaymentStatus.success,
        paymentIntentId: paymentIntentData['id'],
      );
    } on StripeException catch (e) {
      String errorMessage = 'Payment failed';

      switch (e.error.code) {
        case FailureCode.Canceled:
          errorMessage = 'Payment was cancelled';
          break;
        case FailureCode.Failed:
          errorMessage = 'Payment failed: ${e.error.message}';
          break;
        default:
          errorMessage = e.error.message ?? 'Payment error occurred';
      }

      return PaymentResult(
        status: PaymentStatus.failed,
        error: errorMessage,
      );
    } catch (e) {
      return PaymentResult(
        status: PaymentStatus.failed,
        error: 'An unexpected error occurred: $e',
      );
    }
  }
}

class PaymentResult {
  final PaymentStatus status;
  final String? paymentIntentId;
  final String? error;

  PaymentResult({
    required this.status,
    this.paymentIntentId,
    this.error,
  });
}