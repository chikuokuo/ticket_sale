import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/attendee.dart';
import '../models/payment_method.dart';
import '../models/payment_status.dart';
import '../models/time_slot.dart';
import '../services/stripe_service.dart';
import '../services/webhook_service.dart';

enum TicketType {
  neuschwanstein,
  museum,
}

// 1. Defines the state of the ticket order form
@immutable
class TicketOrderState {
  final Map<TicketType, TicketData> ticketData;
  final TicketType ticketType;
  final DateTime? selectedDate;
  final TimeSlot? selectedTimeSlot;
  final List<Attendee> attendees;
  final TextEditingController customerEmailController;
  final TextEditingController atmLastFiveController;
  final PaymentStatus paymentStatus;
  final String? paymentError;
  final PaymentMethod selectedPaymentMethod;

  const TicketOrderState({
    required this.ticketData,
    required this.ticketType,
    this.selectedDate,
    this.selectedTimeSlot,
    this.attendees = const [],
    required this.customerEmailController,
    required this.atmLastFiveController,
    this.paymentStatus = PaymentStatus.idle,
    this.paymentError,
    this.selectedPaymentMethod = PaymentMethod.creditCard,
  });

  // Allows creating a copy of the state with modified fields
  TicketOrderState copyWith({
    Map<TicketType, TicketData>? ticketData,
    TicketType? ticketType,
    DateTime? selectedDate,
    TimeSlot? selectedTimeSlot,
    List<Attendee>? attendees,
    PaymentStatus? paymentStatus,
    String? paymentError,
    PaymentMethod? selectedPaymentMethod,
    bool clearDate = false,
    bool clearTimeSlot = false,
    bool clearPaymentError = false,
  }) {
    return TicketOrderState(
      ticketData: ticketData ?? this.ticketData,
      ticketType: ticketType ?? this.ticketType,
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      selectedTimeSlot: clearTimeSlot ? null : (selectedTimeSlot ?? this.selectedTimeSlot),
      attendees: attendees ?? this.attendees,
      customerEmailController: customerEmailController,
      atmLastFiveController: atmLastFiveController,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentError: clearPaymentError ? null : (paymentError ?? this.paymentError),
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }
}

class TicketData {
  // This class is needed to ensure the ticketData map is initialized
  // with default values when creating a TicketOrderState.
  // It can be empty or contain default values if needed.
}

// 2. Manages the state and business logic
class TicketOrderNotifier extends StateNotifier<TicketOrderState> {
  final TicketType ticketType;
  late final double _adultTicketPrice;
  late final double _childTicketPrice;

  TicketOrderNotifier(this.ticketType)
      : super(
          TicketOrderState(
            ticketData: {
              TicketType.neuschwanstein: TicketData(),
              TicketType.museum: TicketData(),
            },
            ticketType: ticketType,
            customerEmailController: TextEditingController(),
            atmLastFiveController: TextEditingController(),
            selectedPaymentMethod: PaymentMethod.creditCard,
            paymentStatus: PaymentStatus.idle,
            attendees: [Attendee()],
          ),
        ) {
    _initializePrices();
  }

  void _initializePrices() {
    switch (ticketType) {
      case TicketType.neuschwanstein:
        _adultTicketPrice = 21.0;
        _childTicketPrice = 0.0;
        break;
      case TicketType.museum:
        _adultTicketPrice = 20.0;
        _childTicketPrice = 0.0;
        break;
    }
  }

  void addAttendee([AttendeeType? type]) {
    final newAttendee = Attendee();
    if (type != null) {
      newAttendee.type = type;
    }
    state = state.copyWith(attendees: [...state.attendees, newAttendee]);
  }

  void removeAttendee(AttendeeType type) {
    final attendees = List<Attendee>.from(state.attendees);
    final lastIndex = attendees.lastIndexWhere((attendee) => attendee.type == type);
    if (lastIndex != -1) {
      attendees.removeAt(lastIndex);
      state = state.copyWith(attendees: attendees);
    }
  }

  void updateAttendeeType(int index, AttendeeType newType) {
    final newAttendees = List<Attendee>.from(state.attendees);
    newAttendees[index].type = newType;
    state = state.copyWith(attendees: newAttendees);
  }

  void selectDate(DateTime? date) {
    state = state.copyWith(selectedDate: date);
  }

  void selectTimeSlot(TimeSlot? timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot);
  }

  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  // Calculate total amount
  double getTotalAmount() {
    final int adultCount = state.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = state.attendees.where((a) => a.type == AttendeeType.child).length;
    return (adultCount * _adultTicketPrice) + (childCount * _childTicketPrice);
  }

  // Process payment with Stripe
  Future<void> processPayment(BuildContext context) async {
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
          'date': DateFormat('yyyy-MM-dd').format(state.selectedDate!),
          'time_slot': state.selectedTimeSlot?.name.toUpperCase() ?? 'ANYTIME',
          'attendee_count': state.attendees.length.toString(),
        },
      );

      if (result.status == PaymentStatus.success) {
        // Payment successful - submit to n8n webhook
        state = state.copyWith(paymentStatus: PaymentStatus.success);
        try {
          await _submitToWebhook();
          _resetForm();
        } catch (e) {
          // If webhook submission fails, update payment status to failed
          state = state.copyWith(
            paymentStatus: PaymentStatus.failed,
            paymentError: 'Payment successful but failed to submit order: $e',
          );
        }
      } else {
        // Payment failed
        state = state.copyWith(
          paymentStatus: PaymentStatus.failed,
          paymentError: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        paymentStatus: PaymentStatus.failed,
        paymentError: 'An unexpected error occurred: $e',
      );
    }
  }

  // Submit ATM payment order to n8n webhook
  Future<void> submitAtmPayment() async {
    state = state.copyWith(paymentStatus: PaymentStatus.processing, clearPaymentError: true);

    if (state.selectedDate == null) {
      state = state.copyWith(
        paymentStatus: PaymentStatus.failed,
        paymentError: 'Please select a date before confirming.',
      );
      return;
    }

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

  // Submit order to n8n webhook after successful payment
  Future<void> _submitToWebhook({String? atmLastFive}) async {
    final int adultCount = state.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = state.attendees.where((a) => a.type == AttendeeType.child).length;
    final double totalAmount = getTotalAmount();

    // Transform attendees data
    final List<Map<String, String>> attendeesData = state.attendees.map((a) {
      final ticketType = a.type == AttendeeType.adult ? 'Adult' : 'Child';
      final fullName = '${a.givenNameController.text} ${a.familyNameController.text}'.trim();
      return {
        'name': fullName,
        'ticketType': ticketType,
      };
    }).toList();

    final webhookService = WebhookService();

    await webhookService.sendTicketOrder(
      customerEmail: state.customerEmailController.text,
      orderDate: state.selectedDate!,
      session: state.selectedTimeSlot == TimeSlot.am ? 'morning' : 'afternoon',
      totalTickets: state.attendees.length,
      adults: adultCount,
      children: childCount,
      totalAmount: totalAmount,
      bankAccountLast5: atmLastFive ?? 'N/A',
      attendees: attendeesData,
    );
  }


  // Business logic for submitting is now cleanly separated from the UI
  Future<void> submitOrder() async {
    // Further validation for date and time slot can be done here.

    final int adultCount = state.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = state.attendees.where((a) => a.type == AttendeeType.child).length;
    final double totalAmount = getTotalAmount();

    // Transform attendees data
    final List<Map<String, String>> attendeesData = state.attendees.map((a) {
      final ticketType = a.type == AttendeeType.adult ? 'Adult' : 'Child';
      final fullName = '${a.givenNameController.text} ${a.familyNameController.text}'.trim();
      return {
        'name': fullName,
        'ticketType': ticketType,
      };
    }).toList();

    // Prepare JSON data for n8n webhook
    final Map<String, dynamic> webhookData = {
      'customerEmail': state.customerEmailController.text,
      'orderDate': DateFormat('yyyy-MM-dd').format(state.selectedDate!),
      'session': state.selectedTimeSlot == TimeSlot.am ? 'morning' : 'afternoon',
      'tickets': {
        'total': state.attendees.length,
        'adults': adultCount,
        'children': childCount,
      },
      'totalAmount': {
        'value': totalAmount,
        'currency': 'EUR',
      },
      'bankAccount': {
        'last5': '12345', // Extract last 5 digits from "1234-5678-9999"
      },
      'attendees': attendeesData,
    };

    try {
      // Send POST request to n8n webhook
      final response = await http.post(
        Uri.parse('https://dream-ticket.app.n8n.cloud/webhook/ae7619b9-fbb4-496f-8876-ec5443de6b4b'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(webhookData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - webhook received the data
        _resetForm();
      } else {
        // Error - webhook call failed
        throw Exception('Webhook call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Rethrow the error to be handled by the UI
      throw Exception('Failed to submit order: $e');
    }
  }


  void _resetForm() {
    state = state.copyWith(
      selectedDate: null,
      selectedTimeSlot: null,
      attendees: [],
      paymentStatus: PaymentStatus.idle,
      clearPaymentError: true,
    );
    state.customerEmailController.clear();
    state.atmLastFiveController.clear();
  }

  @override
  void dispose() {
    // Dispose all controllers when the notifier is disposed
    for (var attendee in state.attendees) {
      attendee.dispose();
    }
    state.customerEmailController.dispose();
    state.atmLastFiveController.dispose();
    super.dispose();
  }
}

// 3. Creates a global provider to access the notifier
final ticketOrderProvider = StateNotifierProvider.autoDispose.family<TicketOrderNotifier, TicketOrderState, TicketType>(
  (ref, ticketType) => TicketOrderNotifier(ticketType),
);

