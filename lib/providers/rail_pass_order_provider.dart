import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendee.dart';
import '../models/payment_method.dart';
import '../models/payment_status.dart';
import '../models/rail_pass.dart';
import '../services/stripe_service.dart';
import '../services/webhook_service.dart';

@immutable
class RailPassOrderState {
  final RailPass? railPass;
  final RailPassPricing? selectedPricing;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController atmLastFiveController;
  final PaymentStatus paymentStatus;
  final String? paymentError;
  final PaymentMethod selectedPaymentMethod;

  const RailPassOrderState({
    this.railPass,
    this.selectedPricing,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.addressController,
    required this.atmLastFiveController,
    this.paymentStatus = PaymentStatus.idle,
    this.paymentError,
    this.selectedPaymentMethod = PaymentMethod.creditCard,
  });

  RailPassOrderState copyWith({
    RailPass? railPass,
    RailPassPricing? selectedPricing,
    PaymentStatus? paymentStatus,
    String? paymentError,
    PaymentMethod? selectedPaymentMethod,
    bool clearPaymentError = false,
  }) {
    return RailPassOrderState(
      railPass: railPass ?? this.railPass,
      selectedPricing: selectedPricing ?? this.selectedPricing,
      firstNameController: firstNameController,
      lastNameController: lastNameController,
      emailController: emailController,
      addressController: addressController,
      atmLastFiveController: atmLastFiveController,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentError: clearPaymentError ? null : (paymentError ?? this.paymentError),
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }

  // To maintain compatibility with AttendeeInfoCard
  List<Attendee> get attendees {
    final attendee = Attendee()
      ..givenNameController.text = firstNameController.text
      ..familyNameController.text = lastNameController.text;
    return [attendee];
  }

  TextEditingController get customerEmailController => emailController;
}

class RailPassOrderNotifier extends StateNotifier<RailPassOrderState> {
  RailPassOrderNotifier()
      : super(RailPassOrderState(
          firstNameController: TextEditingController(),
          lastNameController: TextEditingController(),
          emailController: TextEditingController(),
          addressController: TextEditingController(),
          atmLastFiveController: TextEditingController(),
        ));

  void setOrderDetails({
    required RailPass railPass,
    required RailPassPricing pricing,
    required String firstName,
    required String lastName,
    required String email,
    required String address,
  }) {
    state.firstNameController.text = firstName;
    state.lastNameController.text = lastName;
    state.emailController.text = email;
    state.addressController.text = address;
    state = state.copyWith(railPass: railPass, selectedPricing: pricing);
  }

  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  double getTotalAmount() {
    if (state.selectedPricing == null) return 0;
    return state.selectedPricing!.individualPrice;
  }

  Future<void> processPayment(BuildContext context) async {
    state = state.copyWith(paymentStatus: PaymentStatus.processing, clearPaymentError: true);
    try {
      final stripeService = StripeService();
      final totalAmount = getTotalAmount();

      final result = await stripeService.processPayment(
        context: context,
        amount: totalAmount,
        currency: 'eur',
        customerEmail: state.emailController.text,
        metadata: {
          'railPass': state.railPass?.name ?? 'N/A',
          'duration': '${state.selectedPricing?.days} days',
          'category': 'individual',
          'customerName': '${state.firstNameController.text} ${state.lastNameController.text}',
          'address': state.addressController.text,
        },
      );

      if (result.status == PaymentStatus.success) {
        await _submitToWebhook();
        state = state.copyWith(paymentStatus: PaymentStatus.success);
        _resetForm();
      } else {
        state = state.copyWith(paymentStatus: PaymentStatus.failed, paymentError: result.error);
      }
    } catch (e) {
      state = state.copyWith(paymentStatus: PaymentStatus.failed, paymentError: e.toString());
    }
  }

  Future<void> submitAtmPayment() async {
    state = state.copyWith(paymentStatus: PaymentStatus.processing, clearPaymentError: true);
    try {
      await _submitToWebhook(atmLastFive: state.atmLastFiveController.text);
      state = state.copyWith(paymentStatus: PaymentStatus.success);
      _resetForm();
    } catch (e) {
      state = state.copyWith(
        paymentStatus: PaymentStatus.failed,
        paymentError: e.toString(),
      );
    }
  }

  Future<void> _submitToWebhook({String? atmLastFive}) async {
    final webhookService = WebhookService();

    final attendees = [
      {'name': '${state.firstNameController.text} ${state.lastNameController.text}'}
    ];

    await webhookService.sendRailPassOrder(
      customerEmail: state.emailController.text,
      customerAddress: state.addressController.text,
      ticketName: state.railPass?.name ?? 'N/A',
      days: state.selectedPricing?.days.toString() ?? '0',
      attendees: attendees,
      bankAccountLast5: atmLastFive ?? 'N/A',
    );
  }

  void _resetForm() {
    state.firstNameController.clear();
    state.lastNameController.clear();
    state.emailController.clear();
    state.addressController.clear();
    state.atmLastFiveController.clear();
    state = state.copyWith(
      paymentStatus: PaymentStatus.idle,
      clearPaymentError: true,
    );
  }

  @override
  void dispose() {
    state.firstNameController.dispose();
    state.lastNameController.dispose();
    state.emailController.dispose();
    state.addressController.dispose();
    state.atmLastFiveController.dispose();
    super.dispose();
  }
}

final railPassOrderProvider =
    StateNotifierProvider.autoDispose<RailPassOrderNotifier, RailPassOrderState>(
  (ref) => RailPassOrderNotifier(),
);
