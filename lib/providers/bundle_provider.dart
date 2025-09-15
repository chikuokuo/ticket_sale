import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

import '../models/bundle.dart';
import '../models/attendee.dart';
import '../models/payment_method.dart';
import '../models/payment_status.dart';
import '../services/stripe_service.dart';
import '../services/webhook_service.dart';

@immutable
class BundleOrderState {
  final Bundle? selectedBundle;
  final List<Attendee> attendees;
  final DateTime? selectedDate;
  final TextEditingController customerEmailController;
  final TextEditingController atmLastFiveController;
  final PaymentStatus paymentStatus;
  final String? paymentError;
  final PaymentMethod selectedPaymentMethod;

  const BundleOrderState({
    this.selectedBundle,
    this.selectedDate,
    this.attendees = const [],
    required this.customerEmailController,
    required this.atmLastFiveController,
    this.paymentStatus = PaymentStatus.idle,
    this.paymentError,
    this.selectedPaymentMethod = PaymentMethod.creditCard,
  });

  BundleOrderState copyWith({
    Bundle? selectedBundle,
    DateTime? selectedDate,
    List<Attendee>? attendees,
    PaymentStatus? paymentStatus,
    String? paymentError,
    PaymentMethod? selectedPaymentMethod,
    bool clearDate = false,
    bool clearPaymentError = false,
  }) {
    return BundleOrderState(
      selectedBundle: selectedBundle ?? this.selectedBundle,
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      attendees: attendees ?? this.attendees,
      customerEmailController: customerEmailController,
      atmLastFiveController: atmLastFiveController,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentError: clearPaymentError ? null : (paymentError ?? this.paymentError),
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }
}

class BundleOrderNotifier extends StateNotifier<BundleOrderState> {

  BundleOrderNotifier()
      : super(BundleOrderState(
          attendees: [Attendee()],
          customerEmailController: TextEditingController(),
          atmLastFiveController: TextEditingController(),
        ));

  void selectBundle(Bundle bundle) {
    state = state.copyWith(selectedBundle: bundle);
  }

  void addAttendee() {
    state = state.copyWith(attendees: [...state.attendees, Attendee()]);
  }

  void removeAttendee(int index) {
    state.attendees[index].dispose();
    final newAttendees = List<Attendee>.from(state.attendees)..removeAt(index);
    state = state.copyWith(attendees: newAttendees);
  }

  void updateAttendeeType(int index, AttendeeType newType) {
    final newAttendees = List<Attendee>.from(state.attendees);
    newAttendees[index].type = newType;
    state = state.copyWith(attendees: newAttendees);
  }

  void selectDate(DateTime? date) {
    state = state.copyWith(selectedDate: date);
  }

  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  double getTotalAmount() {
    if (state.selectedBundle == null) {
      return 0.0;
    }
    return state.selectedBundle!.price * state.attendees.length;
  }

  Future<void> submitAtmPayment() async {
    if (state.selectedDate == null) {
      return;
    }
    if (state.atmLastFiveController.text.length < 5) {
      state = state.copyWith(
        paymentStatus: PaymentStatus.failed,
        paymentError: 'Please enter the last 5 digits of your account.',
      );
      return;
    }

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

  Future<void> processPayment(BuildContext context) async {
    if (state.selectedDate == null) {
      return;
    }
    state = state.copyWith(paymentStatus: PaymentStatus.processing, clearPaymentError: true);
    try {
      final stripeService = StripeService();
      final totalAmount = getTotalAmount();

      final result = await stripeService.processPayment(
        context: context,
        amount: totalAmount,
        currency: 'eur',
        customerEmail: state.customerEmailController.text,
        metadata: {
          'orderType': 'bundle',
          'date': DateFormat('yyyy-MM-dd').format(state.selectedDate!),
          'attendee_count': state.attendees.length.toString(),
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

  Future<void> _submitToWebhook({String? atmLastFive}) async {
    final List<Map<String, dynamic>> attendeesData = state.attendees.map((a) {
      final ticketType = a.type == AttendeeType.adult ? 'Adult' : 'Child';
      final fullName = '${a.givenNameController.text} ${a.familyNameController.text}'.trim();
      final price = state.selectedBundle?.price ?? 0.0;
      return {'name': fullName, 'ticketType': ticketType, 'price': price};
    }).toList();

    final webhookService = WebhookService();

    // Use bundle-specific information
    final ticketId = state.selectedBundle?.id ?? 'TR__22697P8';
    final tourName = state.selectedBundle?.title ?? 'Bundle Tour';

    await webhookService.sendBundleOrder(
      customerEmail: state.customerEmailController.text,
      ticketId: ticketId,
      tourName: tourName,
      orderDate: state.selectedDate!,
      attendees: attendeesData,
    );
  }

  void _resetForm() {
    state.customerEmailController.clear();
    state.atmLastFiveController.clear();
    for (var attendee in state.attendees) {
      attendee.dispose();
    }
    state = state.copyWith(
      attendees: [Attendee()],
      paymentStatus: PaymentStatus.idle,
      clearDate: true,
      clearPaymentError: true,
    );
  }

  @override
  void dispose() {
    for (var attendee in state.attendees) {
      attendee.dispose();
    }
    state.customerEmailController.dispose();
    state.atmLastFiveController.dispose();
    super.dispose();
  }
}

final bundleOrderProvider = StateNotifierProvider.autoDispose<BundleOrderNotifier, BundleOrderState>(
  (ref) => BundleOrderNotifier(),
);

// Provider to fetch all bundles from a JSON asset
final bundlesProvider = FutureProvider<List<Bundle>>((ref) async {
  final String response = await rootBundle.loadString('assets/bundles.json');
  final data = await json.decode(response) as List;
  return data.map((json) => Bundle.fromJson(json)).toList();
});
