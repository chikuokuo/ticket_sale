import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/bundle.dart';
import '../models/attendee.dart';
import '../models/payment_method.dart';
import '../models/payment_status.dart';
import '../services/stripe_service.dart';

enum SubmissionStatus {
  idle,
  inProgress,
  success,
  error,
}

@immutable
class BundleOrderState {
  final Bundle? selectedBundle;
  final List<Attendee> attendees;
  final DateTime? selectedDate;
  final GlobalKey<FormState> formKey;
  final TextEditingController customerEmailController;
  final TextEditingController atmLastFiveController;
  final SubmissionStatus paymentStatus;
  final String? paymentError;
  final PaymentMethod selectedPaymentMethod;

  const BundleOrderState({
    required this.formKey,
    this.selectedBundle,
    this.selectedDate,
    this.attendees = const [],
    required this.customerEmailController,
    required this.atmLastFiveController,
    this.paymentStatus = SubmissionStatus.idle,
    this.paymentError,
    this.selectedPaymentMethod = PaymentMethod.creditCard,
  });

  BundleOrderState copyWith({
    GlobalKey<FormState>? formKey,
    Bundle? selectedBundle,
    DateTime? selectedDate,
    List<Attendee>? attendees,
    SubmissionStatus? paymentStatus,
    String? paymentError,
    PaymentMethod? selectedPaymentMethod,
    bool clearDate = false,
    bool clearPaymentError = false,
  }) {
    return BundleOrderState(
      formKey: formKey ?? this.formKey,
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
  // TODO: Replace with actual bundle prices
  final double _adultBundlePrice = 100.0;
  final double _childBundlePrice = 50.0;

  BundleOrderNotifier()
      : super(BundleOrderState(
          attendees: [Attendee()],
          formKey: GlobalKey<FormState>(),
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
    final int adultCount = state.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = state.attendees.where((a) => a.type == AttendeeType.child).length;
    return (adultCount * _adultBundlePrice) + (childCount * _childBundlePrice);
  }

  Future<void> submitAtmPayment() async {
    if (!state.formKey.currentState!.validate() || state.selectedDate == null) {
      return;
    }
    if (state.atmLastFiveController.text.length < 5) {
      state = state.copyWith(
        paymentStatus: SubmissionStatus.error,
        paymentError: 'Please enter the last 5 digits of your account.',
      );
      return;
    }

    state = state.copyWith(paymentStatus: SubmissionStatus.inProgress, clearPaymentError: true);
    try {
      await _submitToWebhook(atmLastFive: state.atmLastFiveController.text);
      state = state.copyWith(paymentStatus: SubmissionStatus.success);
      _resetForm();
    } catch (e) {
      state = state.copyWith(
        paymentStatus: SubmissionStatus.error,
        paymentError: e.toString(),
      );
    }
  }

  Future<void> processPayment(BuildContext context) async {
    if (!state.formKey.currentState!.validate() || state.selectedDate == null) {
      return;
    }
    state = state.copyWith(paymentStatus: SubmissionStatus.inProgress, clearPaymentError: true);
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

      if (result.status == SubmissionStatus.success) {
        await _submitToWebhook();
        state = state.copyWith(paymentStatus: SubmissionStatus.success);
        _resetForm();
      } else {
        state = state.copyWith(paymentStatus: SubmissionStatus.error, paymentError: result.error);
      }
    } catch (e) {
      state = state.copyWith(paymentStatus: SubmissionStatus.error, paymentError: e.toString());
    }
  }

  Future<void> _submitToWebhook({String? atmLastFive}) async {
    final List<Map<String, String>> attendeesData = state.attendees.map((a) {
      final ticketType = a.type == AttendeeType.adult ? 'Adult' : 'Child';
      final fullName = '${a.givenNameController.text} ${a.familyNameController.text}'.trim();
      return {'name': fullName, 'ticketType': ticketType};
    }).toList();

    final Map<String, dynamic> bundleData = {
      'ticketId': 'TR__22697P8',
      'tourName': 'TXXXXXXXX',
      'customerEmail': state.customerEmailController.text,
      'orderDate': DateFormat('yyyy-MM-dd').format(state.selectedDate!),
      'attendees': attendeesData,
      'paymentMethod': state.selectedPaymentMethod.name,
    };
    
    if (state.selectedPaymentMethod == PaymentMethod.atmTransfer) {
      bundleData['bankAccount'] = {'last5': atmLastFive ?? ''};
    } else {
      bundleData['totalAmount'] = {'value': getTotalAmount(), 'currency': 'EUR'};
    }

    final response = await http.post(
      Uri.parse('https://dream-ticket.app.n8n.cloud/webhook/ae7619b9-fbb4-496f-8876-ec5443de6b4b'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bundleData),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Webhook call failed with status ${response.statusCode}: ${response.body}');
    }
  }

  void _resetForm() {
    state.formKey.currentState?.reset();
    state.customerEmailController.clear();
    state.atmLastFiveController.clear();
    for (var attendee in state.attendees) {
      attendee.dispose();
    }
    state = state.copyWith(
      attendees: [Attendee()],
      paymentStatus: SubmissionStatus.idle,
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
